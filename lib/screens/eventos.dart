import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/evento_service.dart';
import '../services/notificacion_service.dart';
import '../core/notification_banner.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  @override
  Widget build(BuildContext context) {
    final eventoService = context.watch<EventoService>();
    final eventos = eventoService.eventos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: eventos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No hay eventos',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Crea un nuevo evento para comenzar',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.event, color: Color(0xFF3B82F6)),
                    ),
                    title: Text(evento.titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(evento.descripcion),
                        const SizedBox(height: 4),
                        Text('📅 ${evento.fecha}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('👤 Creado por: ${evento.creadoPor} (#${evento.id})',
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                                fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/crear_evento',
                          arguments: evento,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/crear_evento');
        },
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Evento',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
