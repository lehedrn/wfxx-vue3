package com.ruoyi.gen.cli;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;
import com.ruoyi.generator.config.GenConfig;
import com.ruoyi.generator.domain.GenTable;

/**
 * 独立代码生成 CLI
 * <p>
 * 从 DDL SQL 文件直接生成代码（ZIP），无需 MySQL/Redis 等外部依赖。
 * <p>
 * 用法：
 * <pre>
 * # 简单模式 — 命令行参数快速生成
 * java -jar ruoyi-gen-cli.jar --sql=create_tables.sql --output=./generated.zip
 *
 * # 配置文件模式 — 精细控制每张表、每个字段的生成行为
 * java -jar ruoyi-gen-cli.jar --sql=create_tables.sql --config=gen-config.yml --output=./generated.zip
 *
 * 命令行参数（简单模式，优先级高于 generator.yml 默认值）：
 *   --sql=&lt;文件路径&gt;            必填，DDL SQL 文件路径
 *   --output=&lt;文件路径&gt;         输出 ZIP 路径（默认 ./generated.zip）
 *   --author=ruoyi              作者名
 *   --package=com.ruoyi.system  包名
 *   --prefix=sys_               表前缀，自动去除
 *   --web=element-plus          前端类型: element-ui / element-plus
 *
 * 配置文件模式（--config 指定 YAML，优先级最高）：
 *   支持全局默认、表级覆盖（基本信息+生成信息）、列级覆盖（字段信息）。
 *   完整配置说明见 GenTableConfig.java 类注释。
 * </pre>
 */
@SpringBootApplication(
    scanBasePackages = { "com.ruoyi.gen.cli", "com.ruoyi.generator.config" },
    exclude = { DataSourceAutoConfiguration.class }
)
public class GenCliApplication implements CommandLineRunner
{
    private static final Logger log = LoggerFactory.getLogger(GenCliApplication.class);

    public static void main(String[] args)
    {
        SpringApplication app = new SpringApplication(GenCliApplication.class);
        app.setWebApplicationType(org.springframework.boot.WebApplicationType.NONE);
        app.setBannerMode(Banner.Mode.OFF);
        app.run(args);
    }

    @Override
    public void run(String... args) throws Exception
    {
        // 解析命令行参数
        String sqlFile = null;
        String outputPath = null;
        String configFile = null;
        String author = null;
        String packageName = null;
        String prefix = null;
        String webType = null;

        for (String arg : args)
        {
            if (arg.startsWith("--sql="))
            {
                sqlFile = arg.substring("--sql=".length());
            }
            else if (arg.startsWith("--output="))
            {
                outputPath = arg.substring("--output=".length());
            }
            else if (arg.startsWith("--config="))
            {
                configFile = arg.substring("--config=".length());
            }
            else if (arg.startsWith("--author="))
            {
                author = arg.substring("--author=".length());
            }
            else if (arg.startsWith("--package="))
            {
                packageName = arg.substring("--package=".length());
            }
            else if (arg.startsWith("--prefix="))
            {
                prefix = arg.substring("--prefix=".length());
            }
            else if (arg.startsWith("--web="))
            {
                webType = arg.substring("--web=".length());
            }
        }

        // 校验必填参数
        if (sqlFile == null)
        {
            System.err.println("错误：请指定 --sql 参数，如 --sql=create_tables.sql");
            System.err.println();
            printUsage();
            System.exit(1);
        }
        if (outputPath == null)
        {
            outputPath = "./generated.zip";
        }

        File file = new File(sqlFile);
        if (!file.exists())
        {
            System.err.println("错误：SQL 文件不存在: " + file.getAbsolutePath());
            System.exit(1);
        }

        // ==================== 加载配置 ====================

        GenTableConfig config = null;

        // 1) 加载 YAML 配置文件（如果指定了 --config）
        if (configFile != null)
        {
            log.info("加载配置文件: {}", new File(configFile).getAbsolutePath());
            config = ConfigLoader.load(configFile);
            // 将全局配置写入 GenConfig 静态字段（影响后续 DdlParser 中 GenUtils.initTable 的行为）
            ConfigLoader.applyGlobalToGenConfig(config);
        }

        // 2) 命令行参数覆盖（优先级高于 YAML 全局配置）
        if (author != null)
        {
            GenConfig.author = author;
        }
        if (packageName != null)
        {
            GenConfig.packageName = packageName;
        }
        if (prefix != null)
        {
            GenConfig.autoRemovePre = true;
            GenConfig.tablePrefix = prefix;
        }

        // ==================== 解析 DDL ====================

        String ddlSql = Files.readString(file.toPath(), StandardCharsets.UTF_8);
        log.info("正在解析 DDL 文件: {}", file.getAbsolutePath());

        String operName = GenConfig.getAuthor();
        List<GenTable> tables = DdlParser.parse(ddlSql, operName);

        if (tables.isEmpty())
        {
            System.err.println("警告：未在 SQL 文件中找到 CREATE TABLE 语句");
            System.exit(1);
        }

        log.info("解析到 {} 张表", tables.size());

        // ==================== 应用配置覆盖 ====================

        // 命令行 --web 参数作为全局默认
        if (webType != null)
        {
            for (GenTable table : tables)
            {
                table.setTplWebType(webType);
            }
        }

        // YAML 配置覆盖（表级/列级配置优先级高于命令行）
        if (config != null)
        {
            ConfigLoader.applyConfig(tables, config);
        }

        // ==================== 生成代码 ====================

        CodeGenerator.generateToZip(tables, outputPath);

        File outputFile = new File(outputPath);
        log.info("代码生成完成！输出文件: {}", outputFile.getAbsolutePath());
        log.info("生成表清单：");
        for (GenTable table : tables)
        {
            log.info("  - {} ({}) → {} [tpl={}, web={}, pkg={}]",
                    table.getTableName(),
                    table.getTableComment(),
                    table.getClassName(),
                    table.getTplCategory(),
                    table.getTplWebType(),
                    table.getPackageName());
        }
    }

    private void printUsage()
    {
        System.err.println("用法: java -jar ruoyi-gen-cli.jar --sql=<DDL文件> [选项]");
        System.err.println();
        System.err.println("必填参数:");
        System.err.println("  --sql=<文件路径>              DDL SQL 文件路径");
        System.err.println();
        System.err.println("可选参数:");
        System.err.println("  --output=<文件路径>           输出 ZIP 路径（默认 ./generated.zip）");
        System.err.println("  --config=<YAML文件路径>       配置文件，精细控制表/字段级生成行为");
        System.err.println("  --author=<作者名>             作者名（默认 ruoyi）");
        System.err.println("  --package=<包名>              包名（默认 com.ruoyi.system）");
        System.err.println("  --prefix=<表前缀>             表前缀，自动去除（默认不去除）");
        System.err.println("  --web=<前端类型>              element-ui / element-plus（默认 element-plus）");
        System.err.println();
        System.err.println("优先级: 命令行参数 > YAML 全局配置 > generator.yml 默认值");
        System.err.println("        YAML 表级/列级配置为最高优先级覆盖");
        System.err.println();
        System.err.println("配置文件示例:");
        System.err.println("  global:");
        System.err.println("    author: ruoyi");
        System.err.println("    packageName: com.ruoyi.system");
        System.err.println("    tplCategory: crud");
        System.err.println("    tplWebType: element-plus");
        System.err.println("    autoRemovePre: true");
        System.err.println("    tablePrefix: sys_");
        System.err.println("    parentMenuId: 3");
        System.err.println("  tables:");
        System.err.println("    sys_product:");
        System.err.println("      functionName: 产品管理");
        System.err.println("      columns:");
        System.err.println("        product_type:");
        System.err.println("          dictType: sys_product_type");
        System.err.println("          htmlType: select");
    }
}