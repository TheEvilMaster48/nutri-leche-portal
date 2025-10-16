import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../models/usuario.dart';

class EventoService extends ChangeNotifier {
  List<Evento> _eventos = [];

  List<Evento> get eventos => _eventos;

  EventoService() {
    _loadEventosPorPlanta('todos');
  }

  // Devuelve el nombre correcto del archivo según la planta
  String _nombreArchivoPorPlanta(String planta) {
    final normalizado = planta.toLowerCase().trim();
    if (normalizado.contains('administrativa')) return 'eventos_admin';
    if (normalizado.contains('recursos')) return 'eventos_recursos';
    if (normalizado.contains('bodega')) return 'eventos_bodega';
    if (normalizado.contains('produccion') ||
        normalizado.contains('producción')) {
      return 'eventos_produccion';
    }
    if (normalizado.contains('ventas')) return 'eventos_ventas';
    return 'eventos_todos';
  }

  // Cargar eventos según la planta
  Future<void> _loadEventosPorPlanta(String planta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _nombreArchivoPorPlanta(planta);
    final eventosJson = prefs.getString(key);

    if (eventosJson != null && eventosJson.isNotEmpty) {
      try {
        final List decoded = json.decode(eventosJson);
        _eventos = decoded.map((e) => Evento.fromJson(e)).toList();
      } catch (e) {
        _eventos = [];
      }
    } else {
      _eventos = [];
    }
    notifyListeners();
  }

  // Guardar eventos por planta
  Future<void> _saveEventosPorPlanta(String planta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _nombreArchivoPorPlanta(planta);
    final data = json.encode(_eventos.map((e) => e.toJson()).toList());
    await prefs.setString(key, data);
    debugPrint('💾 Guardado en $key (${_eventos.length} eventos)');
  }

  // Roles con acceso total
  bool _tieneAccesoTotal(Usuario usuario) {
    const rolesPermitidos = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];
    return rolesPermitidos.contains(usuario.rol);
  }

  // CREAR EVENTO
  Future<void> crearEvento(Evento nuevo, Usuario usuarioActual) async {
    if (!_tieneAccesoTotal(usuarioActual)) {
      throw Exception('Solo los roles autorizados pueden crear eventos');
    }

    // Cargar eventos de la planta correcta
    await _loadEventosPorPlanta(usuarioActual.planta);

    final eventoConPlanta = Evento(
      id: nuevo.id,
      titulo: nuevo.titulo,
      descripcion: nuevo.descripcion,
      fecha: nuevo.fecha,
      creadoPor: '${usuarioActual.nombreCompleto} (${usuarioActual.planta})',
      imagenPath: nuevo.imagenPath,
      archivoPath: nuevo.archivoPath,
    );

    _eventos.add(eventoConPlanta);
    await _saveEventosPorPlanta(usuarioActual.planta);
    await recargarEventos(usuario: usuarioActual);
    notifyListeners();
  }

  // EDITAR EVENTO
  Future<void> editarEvento(
      String id, Evento actualizado, Usuario usuarioActual) async {
    if (!_tieneAccesoTotal(usuarioActual)) {
      throw Exception('Solo los roles autorizados pueden editar eventos');
    }

    await _loadEventosPorPlanta(usuarioActual.planta);

    final index = _eventos.indexWhere((e) => e.id == id);
    if (index != -1) {
      _eventos[index] = actualizado;
      await _saveEventosPorPlanta(usuarioActual.planta);
      await recargarEventos(usuario: usuarioActual);
      notifyListeners();
    }
  }

  // ELIMINAR EVENTO
  Future<void> eliminarEvento(String id, Usuario usuarioActual) async {
    if (!_tieneAccesoTotal(usuarioActual)) {
      throw Exception('Solo los roles autorizados pueden eliminar eventos');
    }

    await _loadEventosPorPlanta(usuarioActual.planta);
    _eventos.removeWhere((e) => e.id == id);
    await _saveEventosPorPlanta(usuarioActual.planta);
    await recargarEventos(usuario: usuarioActual);
    notifyListeners();
  }

  // RECARGAR EVENTOS
  Future<void> recargarEventos({Usuario? usuario}) async {
    if (usuario == null) {
      await _loadEventosPorPlanta('todos');
    } else if (_tieneAccesoTotal(usuario)) {
      await _loadEventosPorPlanta(usuario.planta);
    } else {
      await _loadEventosPorPlanta('todos');
    }
  }

  // OBTENER TODOS LOS EVENTOS (VISUALIZACIÓN GLOBAL)
  Future<List<Evento>> obtenerTodosLosEventos() async {
    final prefs = await SharedPreferences.getInstance();
    List<Evento> todos = [];

    final claves = [
      'eventos_admin',
      'eventos_recursos',
      'eventos_bodega',
      'eventos_produccion',
      'eventos_ventas'
    ];

    for (final key in claves) {
      final data = prefs.getString(key);
      if (data != null && data.isNotEmpty) {
        try {
          final List decoded = json.decode(data);
          todos.addAll(decoded.map((e) => Evento.fromJson(e)).toList());
        } catch (e) {
          debugPrint('⚠️ Error cargando $key: $e');
        }
      }
    }

    debugPrint('📦 Total eventos combinados: ${todos.length}');
    return todos;
  }
}
