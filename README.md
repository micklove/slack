### SimpleSlackWebhookClient
Simple slack webhook client, built in java

Using json template, created on https://app.slack.com/block-kit-builder
(details below)

---

Required ENV Properties

```json
export SLACK_WEBHOOK_URL='SLACK_WEBHOOK_URL=https://hooks.slack.com/services/SOMEVALUE/SOMEOTHERVALUE/SOMETOKENLOOKINGVALUE
export SLACK_MESSAGE_ICON='https://avatars2.githubusercontent.com/u/459687?s=200&v=4'
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
