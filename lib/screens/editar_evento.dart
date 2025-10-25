import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../models/evento.dart';
import '../models/usuario.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';

class EditarEventoScreen extends StatefulWidget {
  final Evento evento;

  const EditarEventoScreen({super.key, required this.evento});

  @override
  State<EditarEventoScreen> createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaController;
  String? _horaSeleccionada;
  File? _archivo;

  final List<String> _horasDisponibles = [
    "08H30", "09H00", "09H30", "10H00", "10H30", "11H00",
    "11H30", "12H00", "12H30", "13H00", "13H30", "14H00",
    "14H30", "15H00", "15H30", "16H00", "16H30"
  ];

  @override
  void initState() {
    super.initState();
    final partesFecha = widget.evento.fecha.split(' - ');
    _fechaController = TextEditingController(text: partesFecha[0]);
    _horaSeleccionada = partesFecha.length > 1 ? partesFecha[1] : null;
    _tituloController = TextEditingController(text: widget.evento.titulo);
    _descripcionController = TextEditingController(text: widget.evento.descripcion);
  }

  // 📎 Seleccionar archivo adjunto (PDF / DOC)
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
        '📎 Archivo actualizado correctamente',
        NotificationType.success,
      );
    }
  }

  // 📅 Seleccionar nueva fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fechaController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && mounted) {
      setState(() {
        _fechaController.text = picked.toString().split(' ')[0];
      });
    }
  }

  // 💾 Guardar cambios del evento
  Future<void> _guardarCambios() async {
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
    final authService = context.read<AuthService>();
    final Usuario? usuario = authService.currentUser;

    if (usuario == null) {
      NotificationBanner.show(
        context,
        'Error: No hay sesión activa.',
        NotificationType.error,
      );
      return;
    }

    // 🏭 Mostrar nombre de la planta según el rol
    String planta = 'Planta Administrativa';
    if (usuario.planta.toLowerCase().contains('recursos')) {
      planta = 'Planta de Recursos Humanos';
    } else if (usuario.planta.toLowerCase().contains('bodega')) {
      planta = 'Planta Bodega';
    } else if (usuario.planta.toLowerCase().contains('produccion') ||
        usuario.planta.toLowerCase().contains('producción')) {
      planta = 'Planta Producción';
    } else if (usuario.planta.toLowerCase().contains('ventas')) {
      planta = 'Planta Ventas';
    }

    final eventoActualizado = Evento(
      id: widget.evento.id,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      fecha: "${_fechaController.text} - $_horaSeleccionada",
      creadoPor: planta,
      imagenPath: widget.evento.imagenPath,
      archivoPath: _archivo?.path ?? widget.evento.archivoPath,
    );

    await eventoService.editarEvento(widget.evento.id, eventoActualizado, usuario);

    if (!mounted) return;

    NotificationBanner.show(
      context,
      '✅ Evento actualizado correctamente',
      NotificationType.success,
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento', style: TextStyle(color: Colors.white)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _horaSeleccionada,
              decoration: InputDecoration(
                labelText: 'Hora del Evento *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.access_time),
              ),
              items: _horasDisponibles.map((hora) {
                return DropdownMenuItem(value: hora, child: Text(hora));
              }).toList(),
              onChanged: (valor) => setState(() => _horaSeleccionada = valor),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _seleccionarArchivo,
              icon: const Icon(Icons.attach_file),
              label: Text(_archivo == null
                  ? 'Actualizar Documento'
                  : 'Documento seleccionado'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    _tituloController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }
}
