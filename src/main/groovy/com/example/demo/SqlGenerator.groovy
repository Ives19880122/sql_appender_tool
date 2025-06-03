package com.example.demo

import groovy.text.SimpleTemplateEngine
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.core.io.ClassPathResource

import java.nio.file.Files
import java.nio.file.Paths

class SqlGenerator {

    private static final Logger log = LoggerFactory.getLogger(SqlGenerator.class);

    static void generateSql(InputArgs args) {
        log.info("開始產生SQL檔案，輸入參數為{}", args)
        try {
            // 讀取資源模板
            String templateContent = new ClassPathResource("templates/normalSqlTemplate.gtpl")
                    .inputStream.getText('UTF-8')

            // 使用 Groovy 的 SimpleTemplateEngine
            def engine = new SimpleTemplateEngine()
            def template = engine.createTemplate(templateContent)

            def inputFilePath = args.sqlFilePath + "/"+ args.sqlFileName
            File inputSqlFile = new File(inputFilePath)

            if(!inputSqlFile.exists()) {
                throw new FileNotFoundException("SQL file not found: ${inputFilePath}")
            }

            String appendSql = inputSqlFile.getText('UTF-8')

            // 準備模板參數
            def binding = [
                    serialNum : args.serialNum,
                    filePath : args.filePath,
                    caseNum : args.caseNum,
                    fileName : args.fileName,
                    userName : args.userName,
                    sqlFileName : args.sqlFileName,
                    appendSql : appendSql
            ]

            // 將參數注入模板
            String sqlFile = template.make(binding).toString()

            // 確認輸出資料夾是否存在，若不存在則建立
            def outputFilePath = args.sqlFilePath + "/out/"+ args.sqlFileName
            File file = new File(outputFilePath)
            if (!file.parentFile.exists()) {
                file.parentFile.mkdirs()
            }

            // 輸出檔案
            Files.write(Paths.get(outputFilePath), sqlFile.bytes)

            log.info("SQL已成功產生，路徑為{}", outputFilePath)
        } catch (Exception e) {
            log.error("SQL產生時發生錯誤{}", e.message, e)
        }
    }
}
