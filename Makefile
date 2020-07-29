
# See https://stackoverflow.com/a/41115011/178808
PROJECT_NAME=$(shell xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' pom.xml)
PROJECT_VERSION=$(shell xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml)
OUTPUT_FILE_PREFIX=target/$(PROJECT_NAME)-$(PROJECT_VERSION)
JAR:=$(OUTPUT_FILE_PREFIX).jar
ZIP:=$(OUTPUT_FILE_PREFIX).zip
JAR_WITH_DEPENDENCIES:=$(OUTPUT_FILE_PREFIX)-jar-with-dependencies.jar

# Assumes the main class is the same as the project name from pom.xml
APP_MAIN_CLASS=$(PROJECT_NAME)

# message contents for testing
TITLE=my title
SUMMARY=my summary
STATUS=success
MSG_TEXT ?= hello world

-include ./lib/help.mk

dump:
	@echo PROJECT_VERSION: $(PROJECT_VERSION)
	@echo JAR: $(JAR)
	@echo ZIP: $(ZIP)
	@echo APP_MAIN_CLASS: $(APP_MAIN_CLASS)


all: validate-args clean $(JAR) run

run: validate-args $(JAR) ## Build and execute the program e.g. AWS_PROFILE=some make run MSG_TEXT=/my/file/path TITLE=my-bucket-name ROLE_TO_ASSUME_NAME=my-role
	mvn exec:java \
		-Dexec.args="'$(TITLE)' '$(SUMMARY)' '$(STATUS)' '$(MSG_TEXT)' " \
		-Dexec.commandLineArgs="$(TITLE)" \
		-Dexec.mainClass="$(APP_MAIN_CLASS)" \
		-Dexec.cleanupDaemonThreads=false

#nb: To use, use the jar-with-dependencies assembly config in the pom.xml
# Run as standard jar (added config to make jar with deps file, in the target folder)
run-with-deps: validate-args $(JAR) $(MSG_TEXT) ## Build and execute the program make run-with-deps MSG_TEXT=/my/file/path TITLE=my-bucket-name ROLE_TO_ASSUME_NAME=my-role
	java -cp $(JAR_WITH_DEPENDENCIES) \
		$(APP_MAIN_CLASS) \
		$(MSG_TEXT) \
		$(TITLE)

.PHONY: install
install: clean dump
	mvn install
	@ls -al $(ZIP)
	@ls -al $(JAR)
	echo "::set-output name=zip_output_path::$(ZIP)"

$(JAR): pom.xml src/main/java/*.java install

dump-classpath: ## Show dependencies (classpath)
	mvn dependency:build-classpath \
		| grep -vE "\[.*\]" \
		| grep -v "mvn dependency" \
		| tr ":" "\n"

dump-cp: ## Dump classpath to file
	mvn dependency:build-classpath \
	-Dmdep.pathSeparator="@REPLACEWITHCOMMA" \
	-Dmdep.prefix='' \
	-Dmdep.fileSeparator="@" \
	-Dmdep.outputFile=classpath

dump-cp-list:
	mvn dependency:list \
		-Dmdep.outputFile=classpath

validate-args:
	$(if $(strip $(SUMMARY)),,$(error SUMMARY required, [$(SUMMARY)] is invalid))
	$(if $(strip $(STATUS)),,$(error STATUS required, [$(STATUS)] is invalid))
	$(if $(strip $(TITLE)),,$(error TITLE required, [$(TITLE)] is invalid))


clean:
	@mvn clean
