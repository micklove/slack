
# See https://stackoverflow.com/a/41115011/178808
PROJECT_NAME=$(shell xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' pom.xml)
PROJECT_VERSION=$(shell xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml)
JAR:=target/$(PROJECT_NAME)-$(PROJECT_VERSION).jar
JAR_WITH_DEPENDENCIES:=target/$(PROJECT_NAME)-$(PROJECT_VERSION)-jar-with-dependencies.jar
APP_MAIN_CLASS=$(PROJECT_NAME)

MSG_TEXT ?= "hello world"
TITLE="my title"

-include ./lib/help.mk

dump:
	@echo PROJECT_VERSION: $(PROJECT_VERSION)
	@echo JAR: $(JAR)
	@echo APP_MAIN_CLASS: $(APP_MAIN_CLASS)


all: validate-args clean $(JAR) run

run: validate-args $(JAR) '$(MSG_TEXT)' ## Build and execute the program e.g. AWS_PROFILE=some make run MSG_TEXT=/my/file/path TITLE=my-bucket-name ROLE_TO_ASSUME_NAME=my-role
	mvn exec:java \
		-Dexec.args="$(MSG_TEXT) $(TITLE)" \
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
install:
	mvn clean install

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
	$(if $(strip $($(MSG_TEXT))),,$(error MSG_TEXT required, [$($(MSG_TEXT))] is invalid))
	$(if $(strip $(TITLE)),,$(error TITLE required, [$(TITLE)] is invalid))

# Upload a dummy file (with just the date in it) if MSG_TEXT is not provided
$(FILE_TO_UPLOAD):
	date > $@

clean:
	@mvn clean
	@-rm -rf $(FILE_TO_UPLOAD)