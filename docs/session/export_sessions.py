#!/usr/bin/env python3
"""Export Claude Code session history to markdown files."""

import json
import os
from datetime import datetime
from collections import defaultdict

PROJECT_PATH = "/home/workspace/com/wfxx-vue3"
SESSION_DIR = "/root/.claude/projects/-home-workspace-com-wfxx-vue3"
HISTORY_FILE = "/root/.claude/history.jsonl"
OUTPUT_DIR = "/home/workspace/com/wfxx-vue3/docs/session"

def parse_ts(ts):
    """Parse timestamp to HH:MM:SS string."""
    if not ts:
        return "??"
    try:
        if isinstance(ts, str):
            if "T" in ts:
                return datetime.fromisoformat(ts.replace("Z", "+00:00")).strftime("%H:%M:%S")
            return datetime.fromtimestamp(int(ts) / 1000).strftime("%H:%M:%S")
        return datetime.fromtimestamp(int(ts) / 1000).strftime("%H:%M:%S")
    except:
        return "??"

def parse_date(ts):
    """Parse timestamp to YYYY-MM-DD HH:MM string."""
    if not ts:
        return "unknown"
    try:
        if isinstance(ts, str):
            if "T" in ts:
                return datetime.fromisoformat(ts.replace("Z", "+00:00")).strftime("%Y-%m-%d %H:%M")
            return datetime.fromtimestamp(int(ts) / 1000).strftime("%Y-%m-%d %H:%M")
        return datetime.fromtimestamp(int(ts) / 1000).strftime("%Y-%m-%d %H:%M")
    except:
        return "unknown"

def extract_content_text(content):
    """Extract readable text from message content."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                btype = block.get("type", "")
                if btype == "text":
                    parts.append(block.get("text", ""))
                elif btype == "thinking":
                    parts.append(f"[思考]\n{block.get('thinking', '')}")
                elif btype == "tool_use":
                    tool = block.get("name", "?")
                    inp = block.get("input", {})
                    parts.append(f"[工具调用: {tool}]")
                elif btype == "tool_result":
                    cid = block.get("tool_use_id", "")[:8]
                    c = block.get("content", "")
                    if isinstance(c, list):
                        for cb in c:
                            if isinstance(cb, dict) and cb.get("type") == "text":
                                txt = cb["text"]
                                if len(txt) > 300:
                                    txt = txt[:300] + "..."
                                parts.append(f"[工具结果: {cid}] {txt}")
                    elif isinstance(c, str):
                        txt = c if len(c) < 300 else c[:300] + "..."
                        parts.append(f"[工具结果: {cid}] {txt}")
                elif btype == "image":
                    parts.append("[图片]")
        return "\n".join(p for p in parts if p.strip())
    return str(content)


def extract_first_user_prompt(messages):
    """Get the first meaningful user prompt from a session."""
    for msg in messages:
        display = msg.get("display", "")
        if display and not display.startswith("/"):
            return display[:120]
    return "(空会话)"


def export_session(session_id, messages, output_dir):
    """Export a single session to markdown."""
    # Filter meaningful messages
    meaningful = []
    for msg in messages:
        mtype = msg.get("type")
        if mtype in ("user", "assistant", "system"):
            meaningful.append(msg)

    if not meaningful:
        return None

    # Get timestamp
    first_ts = None
    for msg in meaningful:
        if msg.get("timestamp"):
            first_ts = msg["timestamp"]
            break

    date_str = parse_date(first_ts)

    # Build filename
    prompt = extract_first_user_prompt([m for m in messages if m.get("display")])
    safe_prompt = "".join(c if c.isalnum() or c in "-_ " else "_" for c in prompt[:50]).strip()
    safe_prompt = "_".join(safe_prompt.split())  # replace spaces with underscores
    filename = f"{date_str.replace(' ', '_')}_{session_id[:8]}_{safe_prompt}.md"

    # Write markdown
    os.makedirs(output_dir, exist_ok=True)
    filepath = os.path.join(output_dir, filename)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(f"# Session {session_id[:12]}...\n\n")
        f.write(f"- **日期**: {date_str}\n")
        f.write(f"- **消息数**: {len(meaningful)}\n")
        f.write(f"- **首个消息**: {prompt}\n\n")
        f.write("---\n\n")

        for msg in meaningful:
            mtype = msg.get("type", "unknown")
            timestamp = msg.get("timestamp")
            ts_str = parse_ts(timestamp)

            if mtype == "user":
                message_data = msg.get("message", {})
                content = message_data.get("content", "")
                text = extract_content_text(content)
                if not text.strip():
                    # Fallback to display field
                    text = msg.get("display", "(空)")
                f.write(f"## [{ts_str}] 用户\n\n{text}\n\n")

            elif mtype == "assistant":
                message_data = msg.get("message", {})
                content = message_data.get("content", "")
                text = extract_content_text(content)
                if text.strip():
                    f.write(f"## [{ts_str}] 助手\n\n{text}\n\n")

            elif mtype == "system":
                message_data = msg.get("message", {})
                content = message_data.get("content", "")
                text = extract_content_text(content)
                if text.strip() and len(text) < 2000:
                    f.write(f"## [{ts_str}] 系统\n\n{text}\n\n")

        f.write("---\n\n*文件自动生成，请勿手动编辑*\n")

    return filepath, len(meaningful)


def main():
    print("=== Claude Code Session Export ===\n")

    # Step 1: Load all session messages
    all_sessions = defaultdict(list)

    for fname in sorted(os.listdir(SESSION_DIR)):
        if not fname.endswith(".jsonl"):
            continue
        session_id = fname.replace(".jsonl", "")
        filepath = os.path.join(SESSION_DIR, fname)

        with open(filepath, "r", encoding="utf-8") as f:
            for line in f:
                try:
                    rec = json.loads(line)
                    all_sessions[session_id].append(rec)
                except json.JSONDecodeError:
                    continue

    # Step 2: Load history for display text
    history_by_session = defaultdict(list)
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE) as f:
            for line in f:
                try:
                    rec = json.loads(line)
                    if rec.get("project") == PROJECT_PATH:
                        sid = rec.get("sessionId")
                        if sid:
                            history_by_session[sid].append(rec)
                except json.JSONDecodeError:
                    continue

    # Step 3: Enrich session messages with display text
    for sid, hist_msgs in history_by_session.items():
        if sid in all_sessions:
            # Attach display text to user messages
            hist_idx = 0
            for msg in all_sessions[sid]:
                if msg.get("type") == "user" and hist_idx < len(hist_msgs):
                    if "display" not in msg:
                        msg["display"] = hist_msgs[hist_idx].get("display", "")
                    hist_idx += 1

    # Step 4: Export each session
    exported = []
    for session_id in sorted(all_sessions.keys()):
        messages = all_sessions[session_id]
        result = export_session(session_id, messages, OUTPUT_DIR)
        if result:
            filepath, msg_count = result
            exported.append((session_id, filepath, msg_count))

    # Step 5: Create index
    index_path = os.path.join(OUTPUT_DIR, "README.md")
    with open(index_path, "w", encoding="utf-8") as f:
        f.write("# 历史会话索引\n\n")
        f.write(f"共导出 **{len(exported)}** 个会话。\n\n")
        f.write("| 序号 | 会话ID | 日期 | 消息数 | 首个消息 |\n")
        f.write("|------|--------|------|--------|----------|\n")
        for i, (sid, filepath, msg_count) in enumerate(exported, 1):
            fname = os.path.basename(filepath)
            # Filename format: YYYY-MM-DD_HH:MM_sessionId_prompt.md
            # Split: first 2 parts are date+time, 3rd is sessionId, rest is prompt
            parts = fname.replace(".md", "").split("_")
            if len(parts) >= 4:
                date_part = f"{parts[0]} {parts[1]}"
                # sessionId is parts[2], prompt is the rest
                prompt_part = " ".join(parts[3:])
            elif len(parts) >= 1:
                date_part = parts[0]
                prompt_part = " ".join(parts[1:])
            else:
                date_part = "?"
                prompt_part = ""
            f.write(f"| {i} | `{sid[:12]}...` | {date_part} | {msg_count} | {prompt_part[:60]} |\n")
        f.write(f"\n---\n\n*自动生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n")

    print(f"导出完成！")
    print(f"输出目录: {OUTPUT_DIR}")
    print(f"会话数量: {len(exported)}")
    print(f"索引文件: {index_path}")


if __name__ == "__main__":
    main()
