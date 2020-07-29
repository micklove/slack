### SimpleSlackWebhookClient
Simple slack webhook client, built in java. (Using no external libs)

Using json template, created on https://app.slack.com/block-kit-builder
(details below)

---

### Github Actions build
![Java CI with Maven](https://github.com/micklove/slack/workflows/Java%20CI%20with%20Maven/badge.svg)

---

### Branches
* `main` branch uses jdk 11
* `java18` branch for jdk 1.8

### Help
```bash
make help
```

### Required ENV Properties
The app expects the following properties to be loaded from the `Env`

```json
export SLACK_WEBHOOK_URL='SLACK_WEBHOOK_URL=https://hooks.slack.com/services/SOMEVALUE/SOMEOTHERVALUE/SOMETOKENLOOKINGVALUE'
export SLACK_MESSAGE_ICON='https://avatars2.githubusercontent.com/u/459687?s=200&v=4'
```
Running from the command line: (if built locally, by Maven. If not, adapt to suit)

```json
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/SOMEVALUE/SOMEOTHERVALUE/SOMETOKENLOOKINGVALUE \
   SLACK_MESSAGE_ICON="https://avatars2.githubusercontent.com/u/459687?s=200&v=4" \
      java -cp target/classes \
        SimpleSlackWebhookClient \
        "Talend" \
        "Load data from Member preferences" \
        "Failure" \
        "Job complete"
```

Run, using make (which uses mvn exec. nb: Ensure env vars are exported ,see above)
```
make run

# Using overridden values
make run TITLE="BLAH" SUMMARY="my-summary" MSG_TEXT="Hello-World" STATUS="failure" 
```
### Message template
A very basic json message template is used to create the slack json message structure, using the [Slack Block Kit Builder](https://app.slack.com/block-kit-builder)

To use, simply paste the contents of [slack-message.json](./src/main/resources/slack-message.json) into the [Slack Block Kit Builder](https://app.slack.com/block-kit-builder), modify to suit and replace the local copy.

---

### Other
[jenv](https://github.com/jenv/jenv) was used locally to set the required jdk version, 1.8.0.242. See [.java-version](.java-version)

---

### References
nb: There is a 
[Slack SDK for Java](https://slack.dev/java-slack-sdk/guides/web-api-basics), however, my requirement was to build this without the need to use external libraries.
