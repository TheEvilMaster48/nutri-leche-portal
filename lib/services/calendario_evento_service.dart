import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendario_evento.dart';

class CalendarioEventoService {
  static const _key = 'eventos';

  Future<List<CalendarioEvento>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final lista = jsonDecode(data) as List;
    return lista.map((e) => CalendarioEvento.fromJson(e)).toList();
  }

  Future<void> guardar(List<CalendarioEvento> eventos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(eventos.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(CalendarioEvento nuevo) async {
    final lista = await listar();
    lista.add(nuevo);
    await guardar(lista);
  }

  Future<void> eliminar(int id) async {
    final lista = await listar();
    lista.removeWhere((e) => e.id == id);
    await guardar(lista);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> confirmarAsistencia(int id, bool confirmado) async {
    final lista = await listar();
    final index = lista.indexWhere((e) => e.id == id);
    if (index != -1) {
      lista[index] = CalendarioEvento(
        id: lista[index].id,
        titulo: lista[index].titulo,
        descripcion: lista[index].descripcion,
        fechaInicio: lista[index].fechaInicio,
        fechaFin: lista[index].fechaFin,
        lugar: lista[index].lugar,
        organizador: lista[index].organizador,
        asistenciaConfirmada: confirmado,
      );
      await guardar(lista);
    }
  }
}
