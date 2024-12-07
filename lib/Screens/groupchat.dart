import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late io.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> messages = [];
  String? clientId;

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  void connectToSocket() {
    socket = io.io('https://a71c-103-104-58-131.ngrok-free.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      clientId = socket.id;
      print('Client ID: $clientId');
    });

    socket.onConnectError((error) {
      print('Connection error: $error');
    });

    socket.on('receiveMessage', (data) {
      setState(() {
        messages.insert(0, {
          'sender': data['sender'],
          'message': data['message'],
          'isSender': data['isSender'] == clientId ? 'true' : 'false',
        });
      });
    });
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      socket.emit('sendMessage', {
        'sender': 'User',
        'message': _messageController.text,
        'client_id': clientId
      });
      _messageController.clear();
    }
  }

  Widget buildMessageWidget(Map<String, String> message) {
    bool isSender = message['isSender'] == 'true';

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message['message']!,
          style: TextStyle(color: isSender ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessageWidget(messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
