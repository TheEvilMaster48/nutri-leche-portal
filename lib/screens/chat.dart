import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import 'chat_detalle.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4ADE80),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatService.getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes conversaciones'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4ADE80),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(chat.userName),
                subtitle: Text(chat.lastMessage ?? 'Sin mensajes'),
                trailing: chat.lastMessageTime != null
                    ? Text(
                        TimeOfDay.fromDateTime(chat.lastMessageTime!)
                            .format(context),
                        style: const TextStyle(fontSize: 12),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetalleScreen(
                        chatId: chat.id,
                        contactoNombre: chat.userName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
