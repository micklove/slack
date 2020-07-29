import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;

public class SimpleSlackWebhookClient {

	public static void main(String[] args) {
		loadAndSendSimpleSlackMessage(args);
	}

	public static void loadAndSendSimpleSlackMessage(String[] args) {
		String title = args[0];
		String summary = args[1];
		String status = args[2];
		String msg = args[3];

		String webhookUrl = getEnv("SLACK_WEBHOOK_URL");
		String messageIconUrl = getEnv("SLACK_MESSAGE_ICON");

		System.out.println("SLACK_WEBHOOK_URL=" + webhookUrl);
		System.out.println("SLACK_MESSAGE_ICON=" + messageIconUrl);
		sendSimpleSlackMessage(title, summary, status, msg, webhookUrl, messageIconUrl);

	}

	public static String getEnv(String envVar) {
		String envValue = System.getenv(envVar);
		if (envValue == null || envValue.isEmpty()) {
			throw new IllegalArgumentException(envVar + " must be available as an ENV variable");
		}
		return envValue;
	}

	private static String loadFileToString() throws IOException {
		ClassLoader classLoader = SimpleSlackWebhookClient.class.getClassLoader();

		String slackMessage = "slack-message.json";
		File file = new File(classLoader.getResource(slackMessage).getFile());
		String content = new String(Files.readAllBytes(file.toPath()));
		return content;
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
		for (Map.Entry<String, String> val : vals.entrySet()) {
			result = slackTemplate.replace(val.getKey(), val.getValue());
			slackTemplate = result;
		}
		return result;
	}

	public static void sendSimpleSlackMessage(String title, String summary, String status, String message, String webhookUrl, String messageIconUrl ) {
		try {
			String requestBody = getTemplatedMessage(title, summary, status, message, messageIconUrl);
			System.out.println(requestBody);

			URL url = new URL(webhookUrl);
			URLConnection con = url.openConnection();
			HttpURLConnection http = (HttpURLConnection) con;
			http.setRequestMethod("POST");
			http.setDoOutput(true);

			byte [] out = requestBody.getBytes(StandardCharsets.UTF_8);
			int length = out.length;
			http.setFixedLengthStreamingMode(length);
			http.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			http.connect();
			try(OutputStream os = http.getOutputStream()) {
				os.write(out);
			}
			dumpResponse(http);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void dumpResponse(HttpURLConnection http) {
		try(BufferedReader br = new BufferedReader(
				new InputStreamReader(http.getInputStream(), "utf-8"))) {
			StringBuilder response = new StringBuilder();
			String responseLine = null;
			while ((responseLine = br.readLine()) != null) {
				response.append(responseLine.trim());
			}
			System.out.println(response.toString());
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
