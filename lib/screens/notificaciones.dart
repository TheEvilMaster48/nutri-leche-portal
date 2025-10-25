import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_item.dart';
import '../services/notificacion_service.dart';
import '../services/auth_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  late Future<List<NotificationItem>> _futureNotificaciones;

  @override
  void initState() {
    super.initState();
    _futureNotificaciones = _cargarNotificaciones();
  }

  Future<List<NotificationItem>> _cargarNotificaciones() async {
    final notificacionService =
        Provider.of<NotificacionService>(context, listen: false);
    final lista = notificacionService.notificaciones;
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF6B6B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _futureNotificaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notificaciones = snapshot.data ?? [];
          if (notificaciones.isEmpty) {
            return const Center(child: Text('No hay notificaciones recientes'));
          }
          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notif = notificaciones[index];
              return ListTile(
                leading: Icon(
                  notif.tipo.contains("evento")
                      ? Icons.event
                      : notif.tipo.contains("chat")
                          ? Icons.chat
                          : Icons.notifications,
                  color: notif.tipo.contains("evento")
                      ? Colors.blue
                      : notif.tipo.contains("chat")
                          ? Colors.green
                          : Colors.grey,
                ),
                title: Text(notif.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${notif.detalle}\n${_formatearFecha(notif.fecha)}",
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
  }
}
