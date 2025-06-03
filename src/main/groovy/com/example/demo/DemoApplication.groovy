package com.example.demo

import groovy.json.JsonSlurper
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class DemoApplication {

	static void main(String[] args) {
		def ctx = SpringApplication.run(DemoApplication, args)
		def appArgs = ctx.getBean(ApplicationArguments)
		if (appArgs.containsOption("inputFile")) {
			def jsonPath = appArgs.getOptionValues("inputFile").get(0)
			def jsonText = new File(jsonPath).text
			def jsonArray = new JsonSlurper().parseText(jsonText)

			// 使用json file 輸出
			jsonArray.each { item ->
				def input = item as InputArgs
				SqlGenerator.generateSql(input)
			}

		} else {
			// 使用單一資料
			InputArgs inputArgs = ctx.getBean(InputArgsFactory).fromArgs()
			SqlGenerator.generateSql(inputArgs)
		}
		ctx.close()
	}
}
