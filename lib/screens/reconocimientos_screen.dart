import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../models/reconocimiento.dart';
import '../models/usuario.dart';
import '../services/reconocimiento_service.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';
import 'menu.dart';
import 'dart:html' as html;

class ReconocimientosScreen extends StatefulWidget {
  const ReconocimientosScreen({super.key});

  @override
  State<ReconocimientosScreen> createState() => _ReconocimientosScreenState();
}

class _ReconocimientosScreenState extends State<ReconocimientosScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _otorgadoAController = TextEditingController();
  String? _tipoSeleccionado;

  List<Reconocimiento> _reconocimientos = [];
  bool _cargando = true;
  final List<Map<String, dynamic>> _archivosAdjuntos = [];

  @override
  void initState() {
    super.initState();
    _cargarReconocimientos();
  }

  Future<void> _cargarReconocimientos() async {
    try {
      final servicio = ReconocimientoService();
      final lista = await servicio.listar();
      setState(() {
        _reconocimientos = lista.reversed.toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      NotificationBanner.show(
        context,
        'Error al cargar reconocimientos: $e',
        NotificationType.error,
      );
    }
  }

  Future<void> _adjuntarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      withData: kIsWeb,
    );

    if (resultado != null && resultado.files.isNotEmpty) {
      for (final f in resultado.files) {
        if (kIsWeb && f.bytes != null) {
          _archivosAdjuntos.add({
            'nombre': f.name,
            'base64': base64Encode(f.bytes!),
          });
        } else if (!kIsWeb && f.path != null) {
          _archivosAdjuntos.add({
            'nombre': f.name,
            'path': f.path,
          });
        }
      }
      setState(() {});
      NotificationBanner.show(
        context,
        "📎 ${resultado.files.length} archivo(s) agregado(s)",
        NotificationType.success,
      );
    }
  }

  /// Detectar MIME según la extensión
  String _obtenerMimeType(String nombre) {
    final ext = nombre.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _abrirArchivo(Map<String, dynamic> archivo) async {
    try {
      if (kIsWeb) {
        if (archivo['base64'] != null) {
          final bytes = base64Decode(archivo['base64']);
          final mimeType = _obtenerMimeType(archivo['nombre']);
          final blob = html.Blob([bytes], mimeType);
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, "_blank");
          html.Url.revokeObjectUrl(url);
        } else {
          throw "Archivo no disponible en memoria.";
        }
      } else {
        final ruta = archivo['path'];
        if (ruta != null && await File(ruta).exists()) {
          await OpenFilex.open(ruta);
        } else {
          throw "No se pudo abrir el archivo (no existe o fue movido)";
        }
      }
    } catch (e) {
      NotificationBanner.show(
        context,
        "⚠️ Error al abrir el archivo: $e",
        NotificationType.error,
      );
    }
  }

  Future<void> _guardarReconocimiento() async {
    final auth = context.read<AuthService>();
    final usuario = auth.currentUser;
    if (usuario == null) return;

    final rolesAccesoTotal = ['admin', 'recursos', 'bodega', 'produccion', 'ventas'];
    final bool tieneAccesoTotal =
        rolesAccesoTotal.contains(usuario.rol.toLowerCase());

    if (!tieneAccesoTotal) {
      NotificationBanner.show(
        context,
        "⛔ No tienes permisos para registrar reconocimientos.",
        NotificationType.error,
      );
      return;
    }

    if (_tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _otorgadoAController.text.isEmpty ||
        _tipoSeleccionado == null) {
      NotificationBanner.show(
        context,
        "⚠️ Completa todos los campos antes de guardar.",
        NotificationType.error,
      );
      return;
    }

    final nuevo = Reconocimiento(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      autor: usuario.nombreCompleto,
      otorgadoA: _otorgadoAController.text.trim(),
      departamento: usuario.planta,
      tipo: _tipoSeleccionado ?? '',
      fecha: DateTime.now(),
      archivos: _archivosAdjuntos.map((a) => jsonEncode(a)).toList(),
    );

    final servicio = ReconocimientoService();
    await servicio.agregar(nuevo);

    NotificationBanner.show(
      context,
      "🏅 Reconocimiento registrado correctamente",
      NotificationType.success,
    );

    _tituloController.clear();
    _descripcionController.clear();
    _otorgadoAController.clear();
    _archivosAdjuntos.clear();
    setState(() => _tipoSeleccionado = null);

    await _cargarReconocimientos();
  }

  /// 🗑️ Eliminar un reconocimiento específico
  Future<void> _eliminarReconocimiento(int id) async {
    final servicio = ReconocimientoService();
    await servicio.eliminar(id);
    await _cargarReconocimientos();

    NotificationBanner.show(
      context,
      "🗑️ Reconocimiento eliminado correctamente",
      NotificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final Usuario? usuario = auth.currentUser;
    final rolesAccesoTotal = ['admin', 'recursos', 'bodega', 'produccion', 'ventas'];
    final bool tieneAccesoTotal =
        rolesAccesoTotal.contains(usuario?.rol.toLowerCase() ?? '');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFFFFFFF), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      if (tieneAccesoTotal)
                        _buildFormulario()
                      else
                        _buildSoloLectura(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _reconocimientos.isEmpty
                            ? const Center(
                                child: Text(
                                  "No existen reconocimientos registrados",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _reconocimientos.length,
                                itemBuilder: (context, index) {
                                  final r = _reconocimientos[index];
                                  return _buildCard(r);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF03A9F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              tooltip: 'Regresar al menú',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MenuScreen()),
              ),
            ),
            const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Reconocimientos",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );

  Widget _buildSoloLectura() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withOpacity(0.5)),
        ),
        child: const Text(
          "🔒 Solo lectura: Los empleados pueden visualizar los reconocimientos registrados.",
          style: TextStyle(color: Colors.black87, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildFormulario() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration:
                  _inputDecoration("Título del reconocimiento", Icons.star),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              maxLines: 3,
              decoration:
                  _inputDecoration("Descripción o motivo", Icons.message),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otorgadoAController,
              decoration: _inputDecoration(
                  "Otorgado a (nombre del compañero)", Icons.person),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration:
                  _inputDecoration("Tipo de reconocimiento", Icons.emoji_events),
              items: const [
                DropdownMenuItem(value: "Excelente trabajo", child: Text("Excelente trabajo")),
                DropdownMenuItem(value: "Empleado del mes", child: Text("Empleado del mes")),
                DropdownMenuItem(value: "Trabajo en equipo", child: Text("Trabajo en equipo")),
                DropdownMenuItem(value: "Innovación destacada", child: Text("Innovación destacada")),
              ],
              onChanged: (valor) => setState(() => _tipoSeleccionado = valor),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _adjuntarArchivo,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4DB6AC)),
              icon: const Icon(Icons.attach_file, color: Colors.white),
              label: const Text("Adjuntar archivo", style: TextStyle(color: Colors.white)),
            ),
            if (_archivosAdjuntos.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _archivosAdjuntos
                    .map((a) => Chip(
                          label: Text(a['nombre'],
                              style: const TextStyle(fontSize: 12)),
                          onDeleted: () =>
                              setState(() => _archivosAdjuntos.remove(a)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarReconocimiento,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB6AC),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Guardar Reconocimiento",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  Widget _buildCard(Reconocimiento r) {
    final archivos = r.archivos.map((e) => jsonDecode(e)).toList();
    final color =
        r.tipo == "Empleado del mes" ? Colors.amber[600]! : const Color(0xFF4DB6AC);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.workspace_premium_rounded, color: color, size: 36),
          title: Text(
            r.titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "${r.descripcion}\n👤 Otorgado a: ${r.otorgadoA}\n🏅 Tipo de Reconocimiento: ${r.tipo}",
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: "Eliminar reconocimiento",
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar eliminación"),
                      content: const Text(
                        "¿Deseas eliminar este reconocimiento? Esta acción no se puede deshacer.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Eliminar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmar == true) {
                    await _eliminarReconocimiento(r.id);
                  }
                },
              ),
              const Icon(Icons.expand_more, color: Colors.black54), // ✅ flecha visible
            ],
          ),
          children: archivos.isEmpty
              ? [const Padding(padding: EdgeInsets.all(8), child: Text("Sin archivos adjuntos"))]
              : archivos
                  .map((a) => ListTile(
                        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                        title: Text(a['nombre'], style: const TextStyle(fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new, color: Colors.teal),
                          onPressed: () => _abrirArchivo(a),
                        ),
                      ))
                  .toList(),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF03A9F4)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF03A9F4), width: 2),
        ),
      );

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _otorgadoAController.dispose();
    super.dispose();
  }
}
