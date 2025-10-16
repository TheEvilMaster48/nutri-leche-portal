import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../models/evento.dart' as evento_model;
import '../models/usuario.dart';
import '../services/evento_service.dart';
import '../services/notificacion_service.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';

class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaController = TextEditingController();
  File? _imagen;
  File? _archivo;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateTime.now().toString().split(' ')[0];
  }

  Future<void> _seleccionarImagen() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagen = File(image.path);
      });
      NotificationBanner.show(
        context,
        'Imagen seleccionada correctamente',
        NotificationType.success,
      );
    }
  }

  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _archivo = File(result.files.single.path!);
      });
      NotificationBanner.show(
        context,
        'Archivo seleccionado correctamente',
        NotificationType.success,
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _guardarEvento() {
    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty) {
      NotificationBanner.show(
        context,
        'Por favor completa todos los campos requeridos',
        NotificationType.error,
      );
      return;
    }

    final eventoService = context.read<EventoService>();
    final notificacionService = context.read<NotificacionService>();
    final authService = context.read<AuthService>();

    // ✅ Obtener usuario actual del AuthService
    final Usuario? usuarioActual = authService.currentUser;

    // Si no hay usuario, mostramos error
    if (usuarioActual == null) {
      NotificationBanner.show(
        context,
        'No se encontró usuario logueado. Inicia sesión nuevamente.',
        NotificationType.error,
      );
      return;
    }

    final String nombreCreador = usuarioActual.nombreCompleto.isNotEmpty
        ? usuarioActual.nombreCompleto
        : 'Usuario Desconocido';
    final String codigoEmpleado = usuarioActual.codigoEmpleado.isNotEmpty
        ? usuarioActual.codigoEmpleado
        : 'N/A';

    // ✅ Crear el objeto Evento
    final nuevoEvento = evento_model.Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: _fechaController.text.trim(),
      creadoPor: '$nombreCreador (#$codigoEmpleado)',
      imagenPath: _imagen?.path,
      archivoPath: _archivo?.path,
    );

    // ✅ Guardar evento
    eventoService.agregarEvento(nuevoEvento);

    // ✅ Crear notificación
    notificacionService.agregarNotificacion(
      'Nuevo evento creado',
      'Se ha creado el evento "${nuevoEvento.titulo}" por $nombreCreador para la fecha ${nuevoEvento.fecha}',
      'evento',
    );

    NotificationBanner.show(
      context,
      'Evento creado exitosamente',
      NotificationType.success,
    );

    // 🔁 Redirigir a la lista de eventos
    Navigator.pushReplacementNamed(context, '/eventos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fechaController,
              readOnly: true,
              onTap: _seleccionarFecha,
              decoration: InputDecoration(
                labelText: 'Fecha *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _seleccionarImagen,
              icon: const Icon(Icons.image),
              label: Text(_imagen == null
                  ? 'Añadir Imagen'
                  : 'Imagen seleccionada'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _seleccionarArchivo,
              icon: const Icon(Icons.attach_file),
              label: Text(_archivo == null
                  ? 'Añadir Documento'
                  : 'Documento seleccionado'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardarEvento,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Crear Evento',
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
    _tituloController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
