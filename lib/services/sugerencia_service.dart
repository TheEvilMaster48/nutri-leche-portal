import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sugerencia.dart';

class SugerenciaService {
  bool get isWeb => kIsWeb;

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/sugerencias.json');
  }

  // 🔹 Cargar todas las sugerencias
  Future<List<Sugerencia>> cargarSugerencias() async {
    try {
      if (isWeb) {
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getString('sugerencias') ?? '[]';
        final jsonList = jsonDecode(data) as List;
        return jsonList.map((e) => Sugerencia.fromJson(e)).toList();
      } else {
        final file = await _getLocalFile();
        if (!await file.exists()) return [];
        final contenido = await file.readAsString();
        final jsonList = jsonDecode(contenido) as List;
        return jsonList.map((e) => Sugerencia.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error al cargar sugerencias: $e');
      return [];
    }
  }

  // 🔹 Guardar sugerencia nueva
  Future<void> guardarSugerencia(Sugerencia sugerencia) async {
    final lista = await cargarSugerencias();
    lista.removeWhere((e) => e.id == sugerencia.id); // evita duplicados
    lista.add(sugerencia);
    final jsonString = jsonEncode(lista.map((e) => e.toJson()).toList());

    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sugerencias', jsonString);
    } else {
      final file = await _getLocalFile();
      await file.writeAsString(jsonString);
    }
  }

  // 🔹 Limpiar todas las sugerencias (opcional)
  Future<void> limpiarSugerencias() async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sugerencias');
    } else {
      final file = await _getLocalFile();
      if (await file.exists()) await file.delete();
    }
  }
}
