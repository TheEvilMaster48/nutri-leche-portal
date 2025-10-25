import '../models/chat.dart';
import '../models/mensaje.dart';

/// Servicio de chat 100 % local (sin Firebase)
/// Guarda datos temporalmente en memoria.
class ChatService {
  final List<Chat> _chats = [];
  final Map<String, List<Mensaje>> _mensajesPorChat = {};

  /// Crear un nuevo chat local
  Future<void> createChat(Chat chat) async {
    _chats.add(chat);
  }

  /// Obtener lista de chats locales
  Stream<List<Chat>> getChats() async* {
    yield _chats;
  }

  /// Obtener mensajes de un chat específico
  Stream<List<Mensaje>> getMensajes(String chatId) async* {
    yield _mensajesPorChat[chatId] ?? [];
  }

  /// Enviar un mensaje
  Future<void> sendMensaje(Mensaje mensaje) async {
    final lista = _mensajesPorChat[mensaje.chatId] ?? [];
    lista.insert(0, mensaje);
    _mensajesPorChat[mensaje.chatId] = lista;

    // Actualizar info del chat
    final chatIndex = _chats.indexWhere((c) => c.id == mensaje.chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: mensaje.content,
        lastMessageTime: mensaje.timestamp,
      );
    }
  }

  /// Eliminar un chat y sus mensajes
  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((c) => c.id == chatId);
    _mensajesPorChat.remove(chatId);
  }
}
