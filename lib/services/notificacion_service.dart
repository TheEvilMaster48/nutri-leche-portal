import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_item.dart';

/// Servicio local de notificaciones
class NotificacionService extends ChangeNotifier {
  List<NotificationItem> _notificaciones = [];

  List<NotificationItem> get notificaciones => _notificaciones;

  NotificacionService() {
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notificaciones');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      _notificaciones = decoded.map((n) => NotificationItem.fromJson(n)).toList();
    } else {
      _notificaciones = [];
    }
    notifyListeners();
  }

  Future<void> _guardarNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notificaciones',
      jsonEncode(_notificaciones.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> agregarNotificacion(
      String titulo, String detalle, String tipo) async {
    final nueva = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      detalle: detalle,
      tipo: tipo,
      fecha: DateTime.now(),
    );

    _notificaciones.insert(0, nueva);
    await _guardarNotificaciones();
    notifyListeners();
  }

  Future<List<NotificationItem>> obtenerNotificaciones() async {
    await _cargarNotificaciones();
    return _notificaciones;
  }

  Future<void> eliminarNotificacion(String id) async {
    _notificaciones.removeWhere((n) => n.id == id);
    await _guardarNotificaciones();
    notifyListeners();
  }

  Future<void> limpiarNotificaciones() async {
    _notificaciones.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notificaciones');
    notifyListeners();
  }
}
