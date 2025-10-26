import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

import '../models/sugerencia.dart';
import '../services/sugerencia_service.dart';

class SugerenciaScreen extends StatefulWidget {
  const SugerenciaScreen({super.key});

  @override
  State<SugerenciaScreen> createState() => _SugerenciaScreenState();
}

class _SugerenciaScreenState extends State<SugerenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _categoria;
  String? _archivoNombre;
  String? _archivoLocalPath;
  Uint8List? _archivoBytes;
  bool _enviando = false;

  final _service = SugerenciaService();
  List<Sugerencia> _lista = [];

  final _categorias = [
    'Clima laboral',
    'Producción',
    'Administración',
    'Recursos Humanos',
    'Distribución y Ventas',
    'Innovación',
  ];

  @override
  void initState() {
    super.initState();
    _cargarSugerencias();
  }

  Future<void> _cargarSugerencias() async {
    final data = await _service.cargarSugerencias();
    setState(() => _lista = data.reversed.toList());
  }

  // ✅ Versión corregida del selector — segura para Web
  Future<void> _seleccionarArchivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'xls', 'xlsx', 'jpg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;

      if (kIsWeb) {
        setState(() {
          _archivoNombre = file.name;
          _archivoBytes = file.bytes;
          _archivoLocalPath = null;
        });
      } else {
        setState(() {
          _archivoNombre = file.name;
          _archivoBytes = file.bytes;
          _archivoLocalPath = file.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al seleccionar archivo: $e')),
      );
    }
  }

  Future<String?> _guardarArchivoLocal(String nombre, Uint8List? bytes) async {
    if (bytes == null) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final carpeta = Directory('${dir.path}/sugerencias');
      if (!await carpeta.exists()) await carpeta.create(recursive: true);

      final archivo = File('${carpeta.path}/$nombre');
      await archivo.writeAsBytes(bytes);
      return archivo.path;
    } catch (e) {
      debugPrint('Error al guardar archivo local: $e');
      return null;
    }
  }

  Future<void> _enviarSugerencia() async {
    if (!_formKey.currentState!.validate()) return;
    if (_archivoBytes == null && _archivoLocalPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Por favor adjunta un archivo.')),
      );
      return;
    }

    setState(() => _enviando = true);

    String? pathGuardado;
    if (!kIsWeb) {
      pathGuardado = await _guardarArchivoLocal(
        _archivoNombre ?? 'archivo_${DateTime.now().millisecondsSinceEpoch}',
        _archivoBytes ?? await File(_archivoLocalPath!).readAsBytes(),
      );
    }

    final nueva = Sugerencia(
      id: const Uuid().v4(),
      categoria: _categoria ?? 'Sin categoría',
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
      imagenPath: _archivoNombre,
      fecha: DateTime.now(),
      base64: kIsWeb && _archivoBytes != null
          ? base64Encode(_archivoBytes!)
          : null,
      rutaLocal: pathGuardado,
    );

    await _service.guardarSugerencia(nueva);
    await _cargarSugerencias();

    setState(() {
      _tituloCtrl.clear();
      _descCtrl.clear();
      _archivoNombre = null;
      _archivoBytes = null;
      _archivoLocalPath = null;
      _categoria = null;
      _enviando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Sugerencia enviada correctamente'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> _abrirArchivo(Sugerencia s) async {
    try {
      if (kIsWeb) {
        if (s.base64 != null && s.imagenPath != null) {
          final bytes = base64Decode(s.base64!);
          final blob = html.Blob([bytes], _mimeType(s.imagenPath!));
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.window.open(url, "_blank");
          html.Url.revokeObjectUrl(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No hay archivo disponible')),
          );
        }
      } else {
        final path = s.rutaLocal;
        if (path != null && await File(path).exists()) {
          final result = await OpenFilex.open(path);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('⚠️ No se pudo abrir el archivo: ${result.message}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo no encontrado')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }
  }

  String _mimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: AppBar(
        title: const Text('Buzón de sugerencias'),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '🗳️ Envío anónimo',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tu opinión es confidencial. Nutri Leche valora tus ideas.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 25),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categorias
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v),
                    validator: (v) =>
                        v == null ? 'Seleccione una categoría' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingrese un título' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Ingrese una descripción'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _seleccionarArchivo,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Añadir archivo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_archivoNombre != null)
                        Expanded(
                          child: Text(
                            _archivoNombre!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: _enviando ? null : _enviarSugerencia,
                    icon: _enviando
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Icon(Icons.send),
                    label: Text(_enviando ? 'Enviando...' : 'Enviar sugerencia'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      textStyle: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1.5, height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📋 Sugerencias enviadas',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
            ),
            const SizedBox(height: 10),
            if (_lista.isEmpty)
              const Text('Aún no hay sugerencias enviadas.',
                  style: TextStyle(color: Colors.black54))
            else
              ListView.builder(
                itemCount: _lista.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final s = _lista[index];
                  return InkWell(
                    onTap: () => _abrirArchivo(s),
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.person_off, color: Colors.white),
                        ),
                        title: Text(
                          s.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.descripcion),
                            const SizedBox(height: 6),
                            Text('Categoría: ${s.categoria}',
                                style: const TextStyle(color: Colors.grey)),
                            Text(
                              'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(s.fecha)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                            if (s.imagenPath != null)
                              Row(
                                children: [
                                  const Icon(Icons.insert_drive_file,
                                      color: Colors.teal),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      s.imagenPath!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
