import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificacionService = context.watch<NotificacionService>();
    final notificaciones = notificacionService.notificaciones;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFF6B6B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (notificaciones.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                notificacionService.marcarTodasComoLeidas();
              },
              tooltip: 'Marcar todas como leídas',
            ),
        ],
      ),
      body: notificaciones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notificaciones.length,
              itemBuilder: (context, index) {
                final notif = notificaciones[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: notif.leida ? 0 : 2,
                  color: notif.leida ? Colors.grey[100] : Colors.white,
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getColorByType(notif.tipo).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconByType(notif.tipo),
                        color: _getColorByType(notif.tipo),
                      ),
                    ),
                    title: Text(
                      notif.titulo,
                      style: TextStyle(
                        fontWeight: notif.leida ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.mensaje),
                        const SizedBox(height: 4),
                        Text(
                          notif.fecha,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: !notif.leida
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      notificacionService.marcarComoLeida(notif.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconByType(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'chat':
        return Icons.chat;
      case 'recurso':
        return Icons.folder;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorByType(String tipo) {
    switch (tipo) {
      case 'evento':
        return const Color(0xFF3B82F6);
      case 'chat':
        return const Color(0xFF4ADE80);
      case 'recurso':
        return const Color(0xFFA78BFA);
      default:
        return const Color(0xFFFF6B6B);
    }
  }
}
