import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat.dart';

/// ChatService maneja la conexión WebSocket en tiempo real
class ChatService {
  late IO.Socket _socket;
  final List<Function(Mensaje)> _listeners = [];

  /// Conecta al servidor Socket.IO
  void conectar(String usuario) {
    _socket = IO.io(
      'https://socket-io-chat-h9jt.herokuapp.com/', // servidor público de prueba
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      print('✅ Conectado al servidor WebSocket');
      _socket.emit('join', usuario);
    });

    _socket.on('message', (data) {
      final mensaje = Mensaje.fromJson(Map<String, dynamic>.from(data));
      for (var fn in _listeners) {
        fn(mensaje);
      }
    });

    _socket.onDisconnect((_) => print('❌ Desconectado del servidor'));
  }

  /// Enviar mensaje al servidor
  void enviarMensaje(Mensaje mensaje) {
    _socket.emit('message', mensaje.toJson());
  }

  /// Escuchar mensajes entrantes
  void onMensaje(Function(Mensaje) listener) {
    _listeners.add(listener);
  }

  /// Desconectar del servidor
  void desconectar() {
    _socket.disconnect();
  }
}
