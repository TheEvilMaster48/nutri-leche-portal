import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class UsuarioService extends ChangeNotifier {
  Usuario? _usuarioActual;

  Usuario? get usuarioActual => _usuarioActual;

  Future<void> cargarUsuarioActual(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usuariosJson = prefs.getString('usuarios');
    
    if (usuariosJson != null) {
      final List<dynamic> decoded = json.decode(usuariosJson);
      final usuarios = decoded.map((e) => Usuario.fromJson(e)).toList();
      _usuarioActual = usuarios.firstWhere(
        (u) => u.username == username,
        orElse: () => usuarios.first,
      );
      notifyListeners();
    }
  }

  Future<void> actualizarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usuariosJson = prefs.getString('usuarios');
    
    if (usuariosJson != null) {
      final List<dynamic> decoded = json.decode(usuariosJson);
      List<Usuario> usuarios = decoded.map((e) => Usuario.fromJson(e)).toList();
      
      final index = usuarios.indexWhere((u) => u.id == usuario.id);
      if (index != -1) {
        usuarios[index] = usuario;
        final String encoded = json.encode(usuarios.map((e) => e.toJson()).toList());
        await prefs.setString('usuarios', encoded);
        _usuarioActual = usuario;
        notifyListeners();
      }
    }
  }

  void cerrarSesion() {
    _usuarioActual = null;
    notifyListeners();
  }
}
