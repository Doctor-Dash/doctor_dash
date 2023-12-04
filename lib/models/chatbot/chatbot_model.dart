import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:doctor_dash/OpenAI_API.dart';

class ChatModel {
  late final OpenAI _openAI;
  final ChatUser currentUser;
  final ChatUser gptChatUser;
  List<ChatMessage> messages = [];
  List<ChatUser> typingUsers = [];

  ChatModel(this.currentUser, this.gptChatUser) {
    _openAI = OpenAI.instance.build(
      token: OPEN_AI_API_KEY,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 5),
      ),
      enableLog: true,
    );
  }

  void addMessage(ChatMessage message) {
    messages.insert(0, message);
  }

  void addTypingUser(ChatUser user) {
    typingUsers.add(user);
  }

  void removeTypingUser(ChatUser user) {
    typingUsers.remove(user);
  }

  Future<void> getChatResponse(ChatMessage message) async {
    addTypingUser(gptChatUser);
    try {
      List<Messages> _messagesHistory = messages.reversed.map((chatMessage) {
          return chatMessage.user == currentUser
              ? Messages(role: Role.user, content: chatMessage.text)
              : Messages(role: Role.assistant, content: chatMessage.text);
      }).toList();

      final request = ChatCompleteText(
        model: GptTurbo0301ChatModel(),
        messages: _messagesHistory,
        maxToken: 200,
      );

      final response = await _openAI.onChatCompletion(request: request);

      for (var element in response!.choices) {
        if (element.message != null) {
          addMessage(
            ChatMessage(
              user: gptChatUser,
              createdAt: DateTime.now(),
              text: element.message!.content,
            ),
          );
        }
      }
    } catch (e) {
      print('Error getting chat response: $e');
    } finally {
      removeTypingUser(gptChatUser);
    }
  }
}
