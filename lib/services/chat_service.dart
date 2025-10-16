import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart';
import '../models/mensaje.dart';

class ChatService {
  static const String _chatsKey = 'chats';
  static const String _mensajesKey = 'mensajes';

  // Obtener todos los chats
  Future<List<Chat>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    final chatsJson = prefs.getString(_chatsKey);
    
    if (chatsJson == null) return [];
    
    final List<dynamic> chatsList = json.decode(chatsJson);
    return chatsList.map((json) => Chat.fromJson(json)).toList();
  }

  // Crear un nuevo chat
  Future<void> createChat(Chat chat) async {
    final prefs = await SharedPreferences.getInstance();
    final chats = await getChats();
    
    chats.add(chat);
    
    final chatsJson = json.encode(chats.map((c) => c.toJson()).toList());
    await prefs.setString(_chatsKey, chatsJson);
  }

  // Obtener mensajes de un chat
  Future<List<Mensaje>> getMensajes(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final mensajesJson = prefs.getString('$_mensajesKey\_$chatId');
    
    if (mensajesJson == null) return [];
    
    final List<dynamic> mensajesList = json.decode(mensajesJson);
    return mensajesList.map((json) => Mensaje.fromJson(json)).toList();
  }

  // Enviar un mensaje
  Future<void> sendMensaje(Mensaje mensaje) async {
    final prefs = await SharedPreferences.getInstance();
    final mensajes = await getMensajes(mensaje.chatId);
    
    mensajes.add(mensaje);
    
    final mensajesJson = json.encode(mensajes.map((m) => m.toJson()).toList());
    await prefs.setString('$_mensajesKey\_${mensaje.chatId}', mensajesJson);
    
    // Actualizar último mensaje del chat
    await _updateLastMessage(mensaje.chatId, mensaje.content, mensaje.timestamp);
  }

  // Actualizar último mensaje del chat
  Future<void> _updateLastMessage(String chatId, String message, DateTime time) async {
    final chats = await getChats();
    final chatIndex = chats.indexWhere((c) => c.id == chatId);
    
    if (chatIndex != -1) {
      final updatedChat = Chat(
        id: chats[chatIndex].id,
        userId: chats[chatIndex].userId,
        userName: chats[chatIndex].userName,
        userRole: chats[chatIndex].userRole,
        lastMessage: message,
        lastMessageTime: time,
        isOnline: chats[chatIndex].isOnline,
      );
      
      chats[chatIndex] = updatedChat;
      
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = json.encode(chats.map((c) => c.toJson()).toList());
      await prefs.setString(_chatsKey, chatsJson);
    }
  }

  // Eliminar un chat
  Future<void> deleteChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final chats = await getChats();
    
    chats.removeWhere((c) => c.id == chatId);
    
    final chatsJson = json.encode(chats.map((c) => c.toJson()).toList());
    await prefs.setString(_chatsKey, chatsJson);
    
    // Eliminar mensajes del chat
    await prefs.remove('$_mensajesKey\_$chatId');
  }
}
