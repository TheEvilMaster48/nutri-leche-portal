import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _mensajeCtrl = TextEditingController();
  final List<Mensaje> _mensajes = [];
  String _usuario = '';

  @override
  void initState() {
    super.initState();
    _usuario = 'User-${const Uuid().v4().substring(0, 4)}';
    _chatService.conectar(_usuario);
    _chatService.onMensaje((msg) {
      setState(() {
        _mensajes.insert(0, msg);
      });
    });
  }

  void _enviar() {
    final texto = _mensajeCtrl.text.trim();
    if (texto.isEmpty) return;

    final mensaje = Mensaje(
      usuario: _usuario,
      contenido: texto,
      fechaHora: DateTime.now(),
      esPropio: true,
    );

    setState(() {
      _mensajes.insert(0, mensaje);
      _mensajeCtrl.clear();
    });

    _chatService.enviarMensaje(mensaje);
  }

  @override
  void dispose() {
    _chatService.desconectar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat en tiempo real ($_usuario)'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esMio = msg.esPropio;
                return Align(
                  alignment:
                      esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: esMio ? Colors.teal[300] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${msg.usuario}: ${msg.contenido}",
                      style: TextStyle(
                        color: esMio ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensajeCtrl,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _enviar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
