import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/cumpleanios.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';

class CumpleaniosScreen extends StatefulWidget {
  const CumpleaniosScreen({super.key});

  @override
  State<CumpleaniosScreen> createState() => _CumpleaniosScreenState();
}

class _CumpleaniosScreenState extends State<CumpleaniosScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  DateTime? _fechaSeleccionada;
  String? _plantaSeleccionada;

  List<Map<String, String>> _empleados = [];

  final List<String> _plantas = [
    'Planta Administrativa',
    'Planta de Recursos Humanos',
    'Planta Bodega',
    'Planta Produccion',
    'Planta Ventas'
  ];

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  // ========================================================
  // MODO ARCHIVOS (Android / iOS / Desktop)
  // ========================================================
  Future<Directory> _getBaseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}/cumpleanios');
    if (!await base.exists()) await base.create(recursive: true);
    return base;
  }

  // ========================================================
  // MODO WEB STORAGE (Web)
  // ========================================================
  Future<void> _guardarCumpleWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existentes = prefs.getStringList('cumpleanios') ?? [];

    final nuevo = jsonEncode({
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'planta': _plantaSeleccionada!,
      'fecha': DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)
    });

    existentes.add(nuevo);
    await prefs.setStringList('cumpleanios', existentes);

    NotificationBanner.show(
      context,
      "🎉 Cumpleaños registrado correctamente (Web)",
      NotificationType.success,
    );

    _nombreCtrl.clear();
    _apellidoCtrl.clear();
    _correoCtrl.clear();
    _telefonoCtrl.clear();
    setState(() {
      _plantaSeleccionada = null;
      _fechaSeleccionada = null;
    });

    _cargarEmpleados();
  }

  Future<void> _cargarCumpleWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList('cumpleanios') ?? [];
    setState(() {
      _empleados = data.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
    });
  }

  // ========================================================
  // GUARDAR (detecta entorno automáticamente)
  // ========================================================
  Future<void> _guardarCumpleanios() async {
    if (!_formKey.currentState!.validate() ||
        _fechaSeleccionada == null ||
        _plantaSeleccionada == null) {
      NotificationBanner.show(
        context,
        "⚠️ Completa todos los campos y selecciona una fecha.",
        NotificationType.error,
      );
      return;
    }

    if (kIsWeb) {
      await _guardarCumpleWeb();
      return;
    }

    try {
      final baseDir = await _getBaseDir();
      final plantaDir = Directory('${baseDir.path}/${_plantaSeleccionada!.replaceAll(' ', '_')}');
      if (!await plantaDir.exists()) await plantaDir.create(recursive: true);

      final nombreCompleto =
          "${_nombreCtrl.text.trim()}_${_apellidoCtrl.text.trim()}".replaceAll(' ', '_');
      final empleadoDir = Directory('${plantaDir.path}/$nombreCompleto');
      if (!await empleadoDir.exists()) await empleadoDir.create(recursive: true);

      final archivo = File('${empleadoDir.path}/datos.txt');

      final data = Cumpleanios(
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        planta: _plantaSeleccionada!,
        fechaNacimiento: _fechaSeleccionada!,
      );

      await archivo.writeAsString(data.toText());

      NotificationBanner.show(
        context,
        "🎉 Cumpleaños registrado correctamente",
        NotificationType.success,
      );

      _nombreCtrl.clear();
      _apellidoCtrl.clear();
      _correoCtrl.clear();
      _telefonoCtrl.clear();
      setState(() {
        _plantaSeleccionada = null;
        _fechaSeleccionada = null;
      });

      _cargarEmpleados();
    } catch (e) {
      NotificationBanner.show(
        context,
        "❌ Error al guardar: ${e.toString()}",
        NotificationType.error,
      );
    }
  }

  // ========================================================
  // CARGAR (detecta entorno automáticamente)
  // ========================================================
  Future<void> _cargarEmpleados() async {
    if (kIsWeb) {
      await _cargarCumpleWeb();
      return;
    }

    final baseDir = await _getBaseDir();
    final List<Map<String, String>> lista = [];

    for (var planta in _plantas) {
      final plantaDir = Directory('${baseDir.path}/${planta.replaceAll(' ', '_')}');
      if (!await plantaDir.exists()) continue;

      final carpetas = plantaDir.listSync().whereType<Directory>();
      for (var carpeta in carpetas) {
        final archivo = File('${carpeta.path}/datos.txt');
        if (await archivo.exists()) {
          final contenido = await archivo.readAsString();
          final lineas = contenido.split('\n');
          String nombre = '', plantaTxt = '', fecha = '';
          for (var linea in lineas) {
            if (linea.startsWith('Nombre:')) nombre = linea.replaceFirst('Nombre:', '').trim();
            if (linea.startsWith('Planta:')) plantaTxt = linea.replaceFirst('Planta:', '').trim();
            if (linea.startsWith('Fecha de nacimiento:')) {
              fecha = linea.replaceFirst('Fecha de nacimiento:', '').trim();
            }
          }
          lista.add({'nombre': nombre, 'planta': plantaTxt, 'fecha': fecha});
        }
      }
    }

    setState(() => _empleados = lista);
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          "🎂 Registrar Cumpleaños",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campoTexto("Nombre", _nombreCtrl, Icons.person),
              const SizedBox(height: 12),
              _campoTexto("Apellido", _apellidoCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _campoTexto("Correo", _correoCtrl, Icons.email),
              const SizedBox(height: 12),
              _campoTexto("Teléfono", _telefonoCtrl, Icons.phone),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _plantaSeleccionada,
                items: _plantas.map((planta) {
                  return DropdownMenuItem(
                    value: planta,
                    child: Text(planta),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: "Planta / Departamento",
                  prefixIcon: Icon(Icons.apartment, color: Colors.teal.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (valor) => setState(() => _plantaSeleccionada = valor),
                validator: (valor) => valor == null ? "Selecciona una planta" : null,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeleccionada == null
                          ? "📅 Selecciona la fecha de nacimiento"
                          : "Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _seleccionarFecha,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardarCumpleanios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Guardar Información",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                "🎉 Cumpleaños registrados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _empleados.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          "No hay cumpleaños registrados en tu planta.",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _empleados.length,
                      itemBuilder: (context, i) {
                        final e = _empleados[i];
                        return Card(
                          color: Colors.grey.shade100,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.cake,
                                color: Colors.pinkAccent, size: 28),
                            title: Text(e['nombre'] ?? ''),
                            subtitle: Text(
                              "🏢 ${e['planta']}\n📅 ${e['fecha']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? "Campo requerido" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
