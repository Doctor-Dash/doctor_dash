import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:doctor_dash/models/chatbot/chatbot_model.dart';

class ChatController {
  final ChatModel _model;

  ChatController(this._model);

  ChatUser get currentUser => _model.currentUser;
  ChatUser get gptChatUser => _model.gptChatUser;
  List<ChatMessage> get messages => _model.messages;
  List<ChatUser> get typingUsers => _model.typingUsers;

  Future<void> sendMessage(ChatMessage message) async {
    _model.addMessage(message);
    try {
      await _model.getChatResponse(message);
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
