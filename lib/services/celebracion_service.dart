import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/celebracion.dart';

class CelebracionService {
  static const _key = 'celebraciones';

  Future<List<Celebracion>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final lista = jsonDecode(data) as List;
    return lista.map((e) => Celebracion.fromJson(e)).toList();
  }

  Future<void> guardar(List<Celebracion> celebraciones) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(celebraciones.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(Celebracion nuevo) async {
    final lista = await listar();
    lista.add(nuevo);
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
