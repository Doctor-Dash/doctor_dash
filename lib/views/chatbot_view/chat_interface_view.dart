import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:doctor_dash/controllers/chatbot/chat_controller.dart';
import 'package:doctor_dash/models/chatbot/chatbot_model.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({Key? key}) : super(key: key);

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  late final ChatController controller;
  late final List<ChatMessage> messages;
  late final ChatUser currentUser;
  bool isLoading = false;
  bool showPresetQuestions = true;

  final List<String> presetQuestions = [
    "Tell me a fun fact about the human body",
    "What should I eat to lower my blood pressure?",
    "Recommendations for stress relief",
    "General tips for healthy living",
  ];

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(id: '1', firstName: 'Patient', lastName: 'User');
    ChatUser gptChatUser = ChatUser(id: '2', firstName: 'Medical', lastName: 'GPT');
    ChatModel model = ChatModel(currentUser, gptChatUser);
    controller = ChatController(model);
    messages = controller.messages;
  }

  void onSend(ChatMessage message) {
    setState(() => isLoading = true);
    
    controller.sendMessage(message).catchError((error) {
      showErrorDialog(error.toString());
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  void sendPresetQuestion(String question) {
    setState(() => showPresetQuestions = false);
    onSend(ChatMessage(text: question, user: currentUser, createdAt: DateTime.now()));
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred'),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx). pop(),
          ),
        ],
      ),
    );
  }

  void clearChat() {
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 5), 
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 41, 86, 143),
              border: Border.all(
                color: Color.fromARGB(255, 35, 25, 52),
                width: 4,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Text(
              'Medical GPT',
              style: TextStyle(
                color: Color.fromARGB(255, 234, 225, 235),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: clearChat, 
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.refresh, size: 24.0),
              ),
            ),
          ),
          if (showPresetQuestions) 
            buildPresetQuestions(),
          Expanded(
            child: DashChat(
              key: ValueKey(showPresetQuestions),
              currentUser: currentUser,
              onSend: onSend,
              messages: messages,
            ),
          ),
          if (isLoading)
            const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget buildPresetQuestions() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 8,
          runSpacing: 4,
          children: presetQuestions.map((question) => ElevatedButton(
            onPressed: () => sendPresetQuestion(question),
            child: Text(question),
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[200],
              onPrimary: Colors.black,
              elevation: 3, 
              onSurface: Colors.grey, 
            ),
          )).toList(),
        ),
      ),
    );
  }
}
