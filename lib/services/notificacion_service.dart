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
    final String encoded =
        json.encode(_notificaciones.map((e) => e.toJson()).toList());
    await prefs.setString('notificaciones', encoded);
  }

  // 🔹 Versión antigua (compatibilidad total)
  void agregarNotificacion(String titulo, String mensaje, String tipo) {
    _agregarInterno(titulo, mensaje, tipo, null, null);
  }

  // 🔹 Nueva versión opcional (sin romper nada)
  void agregarNotificacionAvanzada({
    required String titulo,
    required String mensaje,
    required String tipo,
    String? categoria,
    String? creadoPor,
  }) {
    _agregarInterno(titulo, mensaje, tipo, categoria, creadoPor);
  }

  // 🔹 Lógica común
  void _agregarInterno(String titulo, String mensaje, String tipo,
      String? categoria, String? creadoPor) {
    final notificacion = Notificacion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      mensaje: mensaje,
      fecha: DateTime.now().toString().substring(0, 16),
      tipo: tipo,
      leida: false,
      categoria: categoria,
      creadoPor: creadoPor,
    );

    _notificaciones.insert(0, notificacion);
    _guardarNotificaciones();
    notifyListeners();
  }

  void marcarComoLeida(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = _notificaciones[index];
      _notificaciones[index] = Notificacion(
        id: n.id,
        titulo: n.titulo,
        mensaje: n.mensaje,
        fecha: n.fecha,
        tipo: n.tipo,
        leida: true,
        categoria: n.categoria,
        creadoPor: n.creadoPor,
      );
      _guardarNotificaciones();
      notifyListeners();
    }
  }

  void marcarTodasComoLeidas() {
    _notificaciones = _notificaciones
        .map((n) => Notificacion(
              id: n.id,
              titulo: n.titulo,
              mensaje: n.mensaje,
              fecha: n.fecha,
              tipo: n.tipo,
              leida: true,
              categoria: n.categoria,
              creadoPor: n.creadoPor,
            ))
        .toList();
    _guardarNotificaciones();
    notifyListeners();
  }

  void eliminarNotificacion(String id) {
    _notificaciones.removeWhere((n) => n.id == id);
    _guardarNotificaciones();
    notifyListeners();
  }
}
