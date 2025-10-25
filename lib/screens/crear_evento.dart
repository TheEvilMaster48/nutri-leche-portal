import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  File? _archivo;
  String? _horaSeleccionada;

  final List<String> _horasDisponibles = [
    "08H30", "09H00", "09H30", "10H00", "10H30", "11H00",
    "11H30", "12H00", "12H30", "13H00", "13H30", "14H00",
    "14H30", "15H00", "15H30", "16H00", "16H30"
  ];

  @override
  void initState() {
    super.initState();
    _fechaController.text = DateTime.now().toString().split(' ')[0];
  }

  // Seleccionar archivo PDF o DOC
  Future<void> _seleccionarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _archivo = File(result.files.single.path!));
      NotificationBanner.show(
        context,
        '📎 Archivo seleccionado correctamente',
        NotificationType.success,
      );
    }
  }

  // Seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _fechaController.text = picked.toString().split(' ')[0];
      });
    }
  }

  // Guardar evento
  Future<void> _guardarEvento() async {
    if (_tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _fechaController.text.isEmpty ||
        _horaSeleccionada == null) {
      NotificationBanner.show(
        context,
        '⚠️ Por favor completa todos los campos requeridos.',
        NotificationType.error,
      );
      return;
    }

    final eventoService = context.read<EventoService>();
    final notificacionService = context.read<NotificacionService>();
    final authService = context.read<AuthService>();
    final Usuario? usuarioActual = authService.currentUser;

    if (usuarioActual == null) {
      NotificationBanner.show(
        context,
        'Error: No hay sesión activa.',
        NotificationType.error,
      );
      return;
    }

    const rolesPermitidos = ['admin', 'recursos', 'bodega', 'produccion', 'ventas'];
    if (!rolesPermitidos.contains(usuarioActual.rol)) {
      NotificationBanner.show(
        context,
        'Acceso denegado. No tienes permisos para crear eventos.',
        NotificationType.error,
      );
      return;
    }

    final nuevoEvento = evento_model.Evento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: "${_fechaController.text} - $_horaSeleccionada",
      // ✅ Incluimos el nombre y planta del usuario
      creadoPor:
          '${usuarioActual.nombreCompleto} - ${usuarioActual.planta}',
      imagenPath: null, // imagen eliminada
      archivoPath: _archivo?.path,
    );

    try {
      await eventoService.crearEvento(nuevoEvento, usuarioActual);
      await eventoService.recargarEventos(usuario: usuarioActual);

      notificacionService.agregarNotificacion(
        'Nuevo evento creado',
        '📅 Se ha creado el evento "${nuevoEvento.titulo}" por ${usuarioActual.nombreCompleto} (${usuarioActual.planta}) para la fecha ${nuevoEvento.fecha}',
        'evento',
      );

      if (!mounted) return;

      NotificationBanner.show(
        context,
        '✅ Evento creado exitosamente',
        NotificationType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      NotificationBanner.show(
        context,
        'Error al guardar el evento: ${e.toString()}',
        NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final usuario = auth.currentUser;
    const rolesPermitidos = ['admin', 'recursos', 'bodega', 'produccion', 'ventas'];
    final bool tienePermiso = rolesPermitidos.contains(usuario?.rol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: tienePermiso
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                          borderRadius: BorderRadius.circular(12)),
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
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _horaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Hora del Evento *',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    items: _horasDisponibles.map((hora) {
                      return DropdownMenuItem(value: hora, child: Text(hora));
                    }).toList(),
                    onChanged: (valor) =>
                        setState(() => _horaSeleccionada = valor),
                  ),
                  const SizedBox(height: 24),
                  // 🔹 Eliminamos botón de imagen
                  OutlinedButton.icon(
                    onPressed: _seleccionarArchivo,
                    icon: const Icon(Icons.attach_file),
                    label: Text(_archivo == null
                        ? 'Añadir Documento'
                        : 'Documento seleccionado'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _guardarEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Crear Evento',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                'Acceso denegado.\nSolo roles autorizados pueden crear eventos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.red),
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
