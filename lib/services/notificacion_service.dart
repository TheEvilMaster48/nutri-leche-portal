import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notificacion.dart';

class NotificacionService extends ChangeNotifier {
  List<Notificacion> _notificaciones = [];
  
  List<Notificacion> get notificaciones => _notificaciones;
  
  int get notificacionesNoLeidas => 
      _notificaciones.where((n) => !n.leida).length;

  NotificacionService() {
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificacionesJson = prefs.getString('notificaciones');
    
    if (notificacionesJson != null) {
      final List<dynamic> decoded = json.decode(notificacionesJson);
      _notificaciones = decoded.map((e) => Notificacion.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _guardarNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      _notificaciones.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('notificaciones', encoded);
  }

  void agregarNotificacion(String titulo, String mensaje, String tipo) {
    final notificacion = Notificacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      mensaje: mensaje,
      fecha: DateTime.now().toString().substring(0, 16),
      tipo: tipo,
      leida: false,
    );
    
    _notificaciones.insert(0, notificacion);
    _guardarNotificaciones();
    notifyListeners();
  }

  void marcarComoLeida(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificaciones[index] = Notificacion(
        id: _notificaciones[index].id,
        titulo: _notificaciones[index].titulo,
        mensaje: _notificaciones[index].mensaje,
        fecha: _notificaciones[index].fecha,
        tipo: _notificaciones[index].tipo,
        leida: true,
      );
      _guardarNotificaciones();
      notifyListeners();
    }
  }

  void marcarTodasComoLeidas() {
    _notificaciones = _notificaciones.map((n) => Notificacion(
      id: n.id,
      titulo: n.titulo,
      mensaje: n.mensaje,
      fecha: n.fecha,
      tipo: n.tipo,
      leida: true,
    )).toList();
    _guardarNotificaciones();
    notifyListeners();
  }

  void eliminarNotificacion(String id) {
    _notificaciones.removeWhere((n) => n.id == id);
    _guardarNotificaciones();
    notifyListeners();
  }
}
