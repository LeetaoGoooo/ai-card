import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:word_to_card/api/client_extension.dart';
import 'package:word_to_card/share_prefs.dart';
import 'package:http/io_client.dart';

class Claude {
  final int maxTokens = 4096;
  static SharedPrefs prefs = SharedPrefs();

  init() async {
    OpenAI.apiKey = prefs.apiKey ?? "";
    OpenAI.baseUrl = prefs.baseUrl ?? "https://api.anthropic.com/v1";
    var httpClient =  await HttpClient().autoProxy();
    httpClient.connectionTimeout = const Duration(seconds: 10);
    final proxyClient = IOClient(httpClient);
    return proxyClient;
  }

  Future<String?> post(String prompt,String userInput) async {
    final client = await init();
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "$prompt, 输出要求: 要输出svg内容",

        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          userInput
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "claude-3-5-sonnet-20240620",
      responseFormat: {"type": "json_object"},
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: maxTokens,
      // client: client
    );
    return chatCompletion.choices.first.message.content?[0].text;
  }
}