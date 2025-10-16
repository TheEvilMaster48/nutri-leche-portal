import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/usuario_service.dart';
import '../services/notificacion_service.dart';
import '../core/notification_banner.dart';
import '../models/usuario.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cargoController = TextEditingController();
  final _plantaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = context.read<UsuarioService>().usuarioActual;
      if (usuario != null) {
        _nombreController.text = usuario.nombreCompleto;
        _correoController.text = usuario.correo;
        _telefonoController.text = usuario.telefono;
        _cargoController.text = usuario.cargo;
        _plantaController.text = usuario.planta;
      }
    });
  }

  void _guardarCambios() async {
    final usuarioService = context.read<UsuarioService>();
    final notificacionService = context.read<NotificacionService>();
    final usuarioActual = usuarioService.usuarioActual;

    if (usuarioActual == null) return;

    final usuarioActualizado = Usuario(
      id: usuarioActual.id,
      username: usuarioActual.username,
      password: usuarioActual.password,
      nombreCompleto: _nombreController.text,
      correo: _correoController.text,
      codigoEmpleado: usuarioActual.codigoEmpleado,
      telefono: _telefonoController.text,
      cargo: _cargoController.text,
      planta: _plantaController.text,
      fechaRegistro: usuarioActual.fechaRegistro,
    );

    await usuarioService.actualizarUsuario(usuarioActualizado);
    
    notificacionService.agregarNotificacion(
      'Perfil actualizado',
      'Tu información personal ha sido actualizada correctamente',
      'perfil',
    );

    if (mounted) {
      NotificationBanner.show(
        context,
        'Perfil actualizado exitosamente',
        NotificationType.success,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFA78BFA),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cargoController,
              decoration: InputDecoration(
                labelText: 'Cargo',
                prefixIcon: const Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plantaController,
              decoration: InputDecoration(
                labelText: 'Planta',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA78BFA),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cargoController.dispose();
    _plantaController.dispose();
    super.dispose();
  }
}
