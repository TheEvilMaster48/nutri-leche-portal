import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/usuario.dart';

class AuthService extends ChangeNotifier {
  Usuario? _currentUser;
  List<Usuario> _usuarios = [];
  Map<String, dynamic>? _currentNotification;

  Usuario? get currentUser => _currentUser;
  List<Usuario> get usuarios => _usuarios;
  Map<String, dynamic>? get currentNotification => _currentNotification;

  AuthService() {
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final usuariosJson = prefs.getString('usuarios');
    if (usuariosJson != null) {
      final List<dynamic> decoded = json.decode(usuariosJson);
      _usuarios = decoded.map((u) => Usuario.fromJson(u)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final usuariosJson =
        json.encode(_usuarios.map((u) => u.toJson()).toList());
    await prefs.setString('usuarios', usuariosJson);
  }

  Future<bool> login(String username, String password) async {
    final usuario = _usuarios.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => Usuario(
        id: '',
        username: '',
        password: '',
        nombreCompleto: '',
        correo: '',
        codigoEmpleado: '',
        telefono: '',
        cargo: '',
        planta: '',
        fechaRegistro: DateTime.now(),
      ),
    );

    if (usuario.id.isNotEmpty) {
      _currentUser = usuario;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', usuario.id);
      showNotification('Inicio de sesión exitoso', 'success');
      notifyListeners();
      return true;
    } else {
      showNotification('Usuario o contraseña incorrectos', 'error');
      return false;
    }
  }

  Future<bool> register(Usuario usuario) async {
    // Validar que el usuario no exista
    final existe = _usuarios.any((u) => u.username == usuario.username);
    if (existe) {
      showNotification('El usuario ya existe', 'error');
      return false;
    }

    _usuarios.add(usuario);
    await _saveUsuarios();
    showNotification('Usuario registrado exitosamente', 'success');
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    showNotification('Sesión cerrada', 'success');
    notifyListeners();
  }

  void showNotification(String message, String type) {
    _currentNotification = {'message': message, 'type': type};
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      clearNotification();
    });
  }

  void clearNotification() {
    _currentNotification = null;
    notifyListeners();
  }
}
