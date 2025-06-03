package com.example.demo

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.boot.ApplicationArguments
import org.springframework.stereotype.Component


@Component
class InputArgsFactory {

    private static final Logger log = LoggerFactory.getLogger(InputArgs.class);
    private final ApplicationArguments args;

    InputArgsFactory(ApplicationArguments args) {
        this.args = args;
    }

    InputArgs fromArgs() {
        validArgs()
        return new InputArgs(
                serialNum: args.getOptionValues("serialNum")?.first(),
                filePath: args.getOptionValues("filePath")?.first(),
                caseNum: args.getOptionValues("caseNum")?.first(),
                fileName: args.getOptionValues("fileName")?.first(),
                userName: args.getOptionValues("userName")?.first(),
                sqlFileName: args.getOptionValues("sqlFileName")?.first(),
                sqlFilePath: args.getOptionValues("sqlFilePath")?.first()
        )
    }

    private void validArgs() {
        if(!args.containsOption("serialNum")) {
            log.error("serialNum is required");
            throw new IllegalArgumentException("serialNum is required");
        }
        if(!args.containsOption("filePath")) {
            log.error("filePath is required");
            throw new IllegalArgumentException("filePath is required");
        }
        if(!args.containsOption("caseNum")) {
            log.error("caseNum is required");
            throw new IllegalArgumentException("caseNum is required");
        }
        if(!args.containsOption("fileName")) {
            log.error("fileName is required");
            throw new IllegalArgumentException("fileName is required");
        }
        if(!args.containsOption("userName")) {
            log.error("userName is required");
            throw new IllegalArgumentException("userName is required");
        }
        if(!args.containsOption("sqlFileName")) {
            log.error("sqlFileName is required");
            throw new IllegalArgumentException("sqlFileName is required");
        }
        if(!args.containsOption("sqlFilePath")) {
            log.error("sqlFilePath is required");
            throw new IllegalArgumentException("sqlFilePath is required");
        }
    }
}
