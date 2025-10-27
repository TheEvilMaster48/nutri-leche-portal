import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reconocimiento.dart';

class ReconocimientoService {
  static const _key = 'reconocimientos';

  Future<List<Reconocimiento>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];

    try {
      final lista = jsonDecode(data) as List;
      return lista.map((e) {
        final item = Map<String, dynamic>.from(e);
        if (item['archivos'] == null || item['archivos'] is! List) {
          item['archivos'] = <String>[];
        }
        return Reconocimiento.fromJson(item);
      }).toList();
    } catch (e) {
      await prefs.remove(_key);
      return [];
    }
  }

  Future<void> guardar(List<Reconocimiento> reconocimientos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(reconocimientos.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(Reconocimiento nuevo) async {
    final lista = await listar();
    lista.add(nuevo);
    await guardar(lista);
  }

  Future<void> eliminar(int id) async {
    final lista = await listar();
    lista.removeWhere((r) => r.id == id);
    await guardar(lista);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> actualizar(Reconocimiento actualizado) async {
    final lista = await listar();
    final index = lista.indexWhere((r) => r.id == actualizado.id);
    if (index != -1) {
      lista[index] = actualizado;
      await guardar(lista);
    }
  }
}
