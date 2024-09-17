import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:word_to_card/api/client_extension.dart';
import 'package:word_to_card/share_prefs.dart';
import 'package:http/io_client.dart';

class Claude {
  late final AnthropicClient client;
  final int maxTokens = 1024;
  final Model model = const Model.model(Models.claude35Sonnet20240620);
  static SharedPrefs prefs = SharedPrefs();

  init() async {
    var httpClient =  await HttpClient().autoProxy();
    httpClient.connectionTimeout = const Duration(seconds: 10);
    final proxyClient = IOClient(httpClient);
    client = AnthropicClient(
        apiKey: prefs.apiKey,
        baseUrl: prefs.baseUrl,
        client: proxyClient
    );
  }

  Future<String> post(String prompt,String userInput) async {
    await init();
    final res = await client.createMessage(request:
      CreateMessageRequest(model:
          model ,
          messages: [
            Message(content: 
                MessageContent.text(prompt),
                role: MessageRole.assistant),
            Message(content:  MessageContent.text(userInput), role: MessageRole.user)
          ],
          maxTokens: maxTokens)
    );
    return res.content.text;
  }
}