import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/beneficio.dart';

class BeneficioService {
  static const _key = 'beneficios';

  Future<List<Beneficio>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final lista = jsonDecode(data) as List;
    return lista.map((e) => Beneficio.fromJson(e)).toList();
  }

  Future<void> guardar(List<Beneficio> beneficios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(beneficios.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> agregar(Beneficio nuevo) async {
    final lista = await listar();
    lista.add(nuevo);
    await guardar(lista);
  }

  Future<void> eliminar(int id) async {
    final lista = await listar();
    lista.removeWhere((b) => b.id == id);
    await guardar(lista);
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
