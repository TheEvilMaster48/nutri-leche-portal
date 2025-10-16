import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recurso.dart';

class RecursoService {
  static const String _recursosKey = 'recursos';

  // Obtener todos los recursos
  Future<List<Recurso>> getRecursos() async {
    final prefs = await SharedPreferences.getInstance();
    final recursosJson = prefs.getString(_recursosKey);
    
    if (recursosJson == null) {
      // Crear recursos por defecto
      return _createDefaultRecursos();
    }
    
    final List<dynamic> recursosList = json.decode(recursosJson);
    return recursosList.map((json) => Recurso.fromJson(json)).toList();
  }

  // Crear recursos por defecto
  Future<List<Recurso>> _createDefaultRecursos() async {
    final recursos = [
      Recurso(
        id: '1',
        titulo: 'Manual del Empleado',
        descripcion: 'Guía completa para empleados de Nutri Leche',
        tipo: 'pdf',
        contenido: 'Manual del Empleado - Nutri Leche Ecuador\n\nBienvenido a Nutri Leche...',
        fechaCreacion: DateTime.now(),
      ),
      Recurso(
        id: '2',
        titulo: 'Políticas de la Empresa',
        descripcion: 'Políticas y procedimientos internos',
        tipo: 'pdf',
        contenido: 'Políticas de la Empresa\n\n1. Código de Conducta...',
        fechaCreacion: DateTime.now(),
      ),
      Recurso(
        id: '3',
        titulo: 'Procedimientos de Seguridad',
        descripcion: 'Normas de seguridad en planta',
        tipo: 'pdf',
        contenido: 'Procedimientos de Seguridad\n\nNormas generales...',
        fechaCreacion: DateTime.now(),
      ),
    ];
    
    await saveRecursos(recursos);
    return recursos;
  }

  // Guardar recursos
  Future<void> saveRecursos(List<Recurso> recursos) async {
    final prefs = await SharedPreferences.getInstance();
    final recursosJson = json.encode(recursos.map((r) => r.toJson()).toList());
    await prefs.setString(_recursosKey, recursosJson);
  }

  // Actualizar contenido de un recurso
  Future<void> updateRecurso(String id, String nuevoContenido) async {
    final recursos = await getRecursos();
    final index = recursos.indexWhere((r) => r.id == id);
    
    if (index != -1) {
      final recursoActualizado = Recurso(
        id: recursos[index].id,
        titulo: recursos[index].titulo,
        descripcion: recursos[index].descripcion,
        tipo: recursos[index].tipo,
        contenido: nuevoContenido,
        fechaCreacion: recursos[index].fechaCreacion,
      );
      
      recursos[index] = recursoActualizado;
      await saveRecursos(recursos);
    }
  }

  // Obtener recurso por ID
  Future<Recurso?> getRecursoById(String id) async {
    final recursos = await getRecursos();
    try {
      return recursos.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
