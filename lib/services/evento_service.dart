import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/evento.dart'; // 👈 usa el modelo existente

class EventoService extends ChangeNotifier {
  List<Evento> _eventos = [];
  List<Map<String, dynamic>> _notificaciones = [];

  List<Evento> get eventos => _eventos;
  List<Map<String, dynamic>> get notificaciones => _notificaciones;

  EventoService() {
    _loadEventos();
    _loadNotificaciones();
  }

  Future<void> _loadEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final eventosJson = prefs.getString('eventos');
    if (eventosJson != null) {
      final List<dynamic> decoded = json.decode(eventosJson);
      _eventos = decoded.map((e) => Evento.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final eventosJson = json.encode(_eventos.map((e) => e.toJson()).toList());
    await prefs.setString('eventos', eventosJson);
  }

  Future<void> _loadNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final notifJson = prefs.getString('notificaciones');
    if (notifJson != null) {
      _notificaciones = List<Map<String, dynamic>>.from(json.decode(notifJson));
      notifyListeners();
    }
  }

  Future<void> _saveNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificaciones', json.encode(_notificaciones));
  }

  // ✅ Método único para agregar evento
  Future<void> agregarEvento(Evento evento) async {
    _eventos.add(evento);
    await _saveEventos();

    // Crear notificación
    final notificacion = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tipo': 'evento_creado',
      'titulo': 'Nuevo evento creado',
      'mensaje':
          'Se ha creado el evento "${evento.titulo}" para la fecha ${evento.fecha}. Descripción: ${evento.descripcion}',
      'fecha': DateTime.now().toIso8601String(),
      'leido': false,
    };
    _notificaciones.insert(0, notificacion);
    await _saveNotificaciones();

    notifyListeners();
  }

  Future<void> eliminarEvento(String id) async {
    final evento = _eventos.firstWhere((e) => e.id == id);
    _eventos.removeWhere((e) => e.id == id);
    await _saveEventos();

    // Crear notificación
    final notificacion = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tipo': 'evento_eliminado',
      'titulo': 'Evento eliminado',
      'mensaje': 'Se ha eliminado el evento "${evento.titulo}"',
      'fecha': DateTime.now().toIso8601String(),
      'leido': false,
    };
    _notificaciones.insert(0, notificacion);
    await _saveNotificaciones();

    notifyListeners();
  }

  Future<void> marcarNotificacionLeida(String id) async {
    final index = _notificaciones.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notificaciones[index]['leido'] = true;
      await _saveNotificaciones();
      notifyListeners();
    }
  }
}
