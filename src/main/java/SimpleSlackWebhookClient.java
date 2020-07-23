import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

import static java.net.http.HttpRequest.BodyPublishers.ofString;

public class SimpleSlackWebhookClient {

	public static void main(String[] args) {
		String title = args[0];
		String summary = args[1];
		String status = args[2];
		String msg = args[3];

		String webhookUrl = System.getenv("SLACK_WEBHOOK_URL");
		String messageIconUrl = System.getenv("SLACK_MESSAGE_ICON");

		System.out.println("SLACK_WEBHOOK_URL=" + webhookUrl);
		System.out.println("SLACK_MESSAGE_ICON=" + messageIconUrl);
		simpleSlackMessage(title, summary, status, msg, webhookUrl, messageIconUrl);
	}

	private static String loadFileToString() throws IOException {
		ClassLoader classLoader = new SimpleSlackWebhookClient().getClass().getClassLoader();

		String slackMessage = "slack-message.json";
		File file = new File(classLoader.getResource(slackMessage).getFile());
		return Files.readString(file.toPath());
	}

	private static String getTemplatedMessage(String title, String summary, String status, String message, String messageIconUrl) throws IOException {
		String slackTemplate = loadFileToString();
		String result = "";
		String statusEmoji = ":white_check_mark:";
		if (!"success".equalsIgnoreCase(status)) {
			statusEmoji = ":boom::boom::boom::boom:";
		}
		Map<String, String> vals = new HashMap<>();
		vals.put("${TITLE}", title.toUpperCase());
		vals.put("${SUMMARY}", summary);
		vals.put("${STATUS}", status);
		vals.put("${STATUS_EMOJI}", statusEmoji);
		vals.put("${MESSAGE}", message);
		vals.put("${ICON_URL}", messageIconUrl);
		for (var val : vals.entrySet()) {
			result = slackTemplate.replace(val.getKey(), val.getValue());
			slackTemplate = result;
		}
		return result;
	}

	private static void simpleSlackMessage(String title, String summary, String status, String message, String webhookUrl, String messageIconUrl ) {
		try {
			var requestBody = getTemplatedMessage(title, summary, status, message, messageIconUrl);
			System.out.println(requestBody);

			var client = HttpClient.newHttpClient();
			HttpRequest request = HttpRequest.newBuilder()
					.method("POST", ofString(requestBody))
					.uri(URI.create(webhookUrl))
					.build();

			HttpResponse<String> response = null;

			response = client.send(request,
					HttpResponse.BodyHandlers.ofString());
			System.out.println(response.body());
		} catch (IOException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}
}
