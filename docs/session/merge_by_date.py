#!/usr/bin/env python3
"""Merge session files by date."""

import os
import re

SESSION_DIR = "/home/workspace/com/wfxx-vue3/docs/session"

def extract_header(filepath):
    """Extract the header section (before first --- separator)."""
    with open(filepath, encoding="utf-8") as f:
        content = f.read()
    # Split by --- separator
    parts = content.split("---\n\n", 1)
    if len(parts) == 2:
        return parts[0], parts[1]
    return "", content

def merge_by_date():
    files = [f for f in os.listdir(SESSION_DIR) if f.endswith('.md') and not f == 'README.md']

    # Group by date
    dates = {}
    for f in sorted(files):
        date = f[:10]  # YYYY-MM-DD
        dates.setdefault(date, []).append(f)

    for date, fnames in sorted(dates.items()):
        # Build merged content
        output = f"# {date} 会话记录\n\n"
        output += f"共 **{len(fnames)}** 个会话。\n\n"
        output += "---\n\n"

        total_messages = 0
        for fname in fnames:
            filepath = os.path.join(SESSION_DIR, fname)
            header, body = extract_header(filepath)

            # Extract session info from header
            sid_match = re.search(r'# Session ([^\n]+)', header)
            date_match = re.search(r'- \*\*日期\*\*: ([^\n]+)', header)
            msg_match = re.search(r'- \*\*消息数\*\*: (\d+)', header)
            prompt_match = re.search(r'- \*\*首个消息\*\*: ([^\n]+)', header)

            sid = sid_match.group(1).strip() if sid_match else "?"
            date_val = date_match.group(1).strip() if date_match else date
            msg_count = int(msg_match.group(1)) if msg_match else 0
            prompt = prompt_match.group(1).strip() if prompt_match else "(空)"

            total_messages += msg_count

            # Extract time from filename (YYYY-MM-DD_HH:MM_...)
            time_match = re.search(r'^\d{4}-\d{2}-\d{2}_(\d{2}:\d{2})_', fname)
            time_str = time_match.group(1) if time_match else "??"

            output += f"## [{time_str}] {prompt}\n\n"
            output += f"> **会话**: `{sid}` | **消息数**: {msg_count}\n\n"

            # Append body (strip trailing separator)
            body = body.rstrip()
            if body.endswith("---"):
                body = body.rsplit("---", 1)[0].rstrip()
            if body.endswith("*文件自动生成，请勿手动编辑*"):
                body = body.rsplit("*文件自动生成，请勿手动编辑*", 1)[0].rstrip()

            output += body + "\n\n"
            output += "---\n\n"

        # Add summary
        output += f"**当日合计**: {len(fnames)} 个会话, {total_messages} 条消息\n"

        # Write merged file
        merged_path = os.path.join(SESSION_DIR, f"{date}.md")
        with open(merged_path, "w", encoding="utf-8") as f:
            f.write(output)
        print(f"  {date}.md - {len(fnames)} sessions merged")

    print(f"\nMerged into {len(dates)} date files.")

merge_by_date()
