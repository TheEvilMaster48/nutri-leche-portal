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
    _borrarTodoYReiniciar(); // Limpia los datos viejos al iniciar (temporal)
    _loadUsuarios();
  }

  // Limpia completamente SharedPreferences y fuerza la regeneración de usuarios
  Future<void> _borrarTodoYReiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint(
        '🔄 Preferencias locales limpiadas. Se regenerarán los usuarios por defecto.');
  }

  // CARGAR USUARIOS DESDE MEMORIA LOCAL O CREARLOS POR DEFECTO
  Future<void> _loadUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final usuariosJson = prefs.getString('usuarios');

    if (usuariosJson == null || usuariosJson.isEmpty) {
      await _crearUsuariosPorDefecto();
    } else {
      try {
        final List<dynamic> decoded = json.decode(usuariosJson);
        _usuarios = decoded.map((u) => Usuario.fromJson(u)).toList();
      } catch (e) {
        await _crearUsuariosPorDefecto();
      }
    }
    notifyListeners();
  }

  // CREAR USUARIOS POR DEFECTO (5 ROLES CON ACCESO TOTAL)
  Future<void> _crearUsuariosPorDefecto() async {
    _usuarios = [
      Usuario(
        id: '1',
        username: 'admin',
        password: '1234',
        nombreCompleto: 'Administrador General',
        correo: 'admin@nutrileche.ec',
        codigoEmpleado: 'ADM001',
        telefono: '0999999999',
        cargo: 'Administrador',
        planta: 'Administrativa',
        fechaRegistro: DateTime.now(),
        rol: 'admin',
      ),
      Usuario(
        id: '2',
        username: 'recursos',
        password: '1234',
        nombreCompleto: 'María López',
        correo: 'mlopez@nutrileche.ec',
        codigoEmpleado: 'RRHH002',
        telefono: '0998888888',
        cargo: 'Jefa de Recursos Humanos',
        planta: 'Recursos Humanos',
        fechaRegistro: DateTime.now(),
        rol: 'recursos',
      ),
      Usuario(
        id: '3',
        username: 'bodega',
        password: '1234',
        nombreCompleto: 'Carlos Pérez',
        correo: 'cperez@nutrileche.ec',
        codigoEmpleado: 'BOD003',
        telefono: '0997777777',
        cargo: 'Encargado de Bodega',
        planta: 'Bodega',
        fechaRegistro: DateTime.now(),
        rol: 'bodega',
      ),
      Usuario(
        id: '4',
        username: 'produccion',
        password: '1234',
        nombreCompleto: 'Andrea Torres',
        correo: 'atorres@nutrileche.ec',
        codigoEmpleado: 'PRO004',
        telefono: '0996666666',
        cargo: 'Supervisora de Producción',
        planta: 'Producción',
        fechaRegistro: DateTime.now(),
        rol: 'produccion',
      ),
      Usuario(
        id: '5',
        username: 'ventas',
        password: '1234',
        nombreCompleto: 'Jorge Herrera',
        correo: 'jherrera@nutrileche.ec',
        codigoEmpleado: 'VEN005',
        telefono: '0995555555',
        cargo: 'Coordinador de Ventas',
        planta: 'Ventas',
        fechaRegistro: DateTime.now(),
        rol: 'ventas',
      ),
    ];

    await _saveUsuarios();
    debugPrint('✅ Usuarios por defecto creados correctamente.');
  }

  // GUARDAR USUARIOS EN MEMORIA LOCAL
  Future<void> _saveUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final usuariosJson = json.encode(_usuarios.map((u) => u.toJson()).toList());
    await prefs.setString('usuarios', usuariosJson);
  }

  // LOGIN (MANTIENE ROL ORIGINAL)
  Future<bool> login(String username, String password) async {
    if (_usuarios.isEmpty) {
      await _loadUsuarios();
    }

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
        rol: 'empleado',
      ),
    );

    if (usuario.id.isNotEmpty) {
      _currentUser = usuario;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserId', usuario.id);

      showNotification(
        'Bienvenido ${usuario.nombreCompleto} (${usuario.planta})',
        'success',
      );
      notifyListeners();
      return true;
    } else {
      showNotification('Usuario o contraseña incorrectos', 'error');
      return false;
    }
  }

  // REGISTRO NUEVO (ROL EMPLEADO RESTRINGIDO)
  Future<bool> register(Usuario usuario) async {
    final existe = _usuarios.any((u) => u.username == usuario.username);
    if (existe) {
      showNotification('El usuario ya existe', 'error');
      return false;
    }

    final nuevo = Usuario(
      id: usuario.id,
      username: usuario.username,
      password: usuario.password,
      nombreCompleto: usuario.nombreCompleto,
      correo: usuario.correo,
      codigoEmpleado: usuario.codigoEmpleado,
      telefono: usuario.telefono,
      cargo: usuario.cargo,
      planta: usuario.planta,
      fechaRegistro: usuario.fechaRegistro,
      rol: 'empleado',
    );

    _usuarios.add(nuevo);
    await _saveUsuarios();
    showNotification('Usuario registrado exitosamente', 'success');
    notifyListeners();
    return true;
  }

  // LOGOUT
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
    showNotification('Sesión cerrada correctamente', 'success');
    notifyListeners();
  }

  // NOTIFICACIONES TEMPORALES
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

  // VERIFICACIÓN GLOBAL DE ACCESO
  bool tieneAccesoTotal() {
    if (_currentUser == null) return false;
    const rolesAutorizados = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];
    return rolesAutorizados.contains(_currentUser!.rol);
  }
}