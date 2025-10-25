import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sugerencia.dart';

class SugerenciaService {
  static const _key = 'sugerencias';

  Future<List<Sugerencia>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final lista = jsonDecode(data) as List;
    return lista.map((e) => Sugerencia.fromJson(e)).toList();
  }

  Future<void> guardar(List<Sugerencia> sugerencias) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sugerencias.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(Sugerencia nueva) async {
    final lista = await listar();
    lista.add(nueva);
    await guardar(lista);
  }

  Future<void> actualizarEstado(int id, String nuevoEstado) async {
    final lista = await listar();
    final index = lista.indexWhere((s) => s.id == id);
    if (index != -1) {
      lista[index] = Sugerencia(
        id: lista[index].id,
        titulo: lista[index].titulo,
        mensaje: lista[index].mensaje,
        autor: lista[index].autor,
        anonimo: lista[index].anonimo,
        fecha: lista[index].fecha,
        estado: nuevoEstado,
      );
      await guardar(lista);
    }
  }

  Future<void> eliminar(int id) async {
    final lista = await listar();
    lista.removeWhere((s) => s.id == id);
    await guardar(lista);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
