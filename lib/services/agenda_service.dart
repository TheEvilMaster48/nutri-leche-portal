import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agenda.dart';

class AgendaService {
  static const _key = 'agenda';

  Future<List<Agenda>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final lista = jsonDecode(data) as List;
    return lista.map((e) => Agenda.fromJson(e)).toList();
  }

  Future<void> guardar(List<Agenda> citas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(citas.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(Agenda nueva) async {
    final lista = await listar();
    lista.add(nueva);
    await guardar(lista);
  }

  Future<void> eliminar(int id) async {
    final lista = await listar();
    lista.removeWhere((c) => c.id == id);
    await guardar(lista);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
