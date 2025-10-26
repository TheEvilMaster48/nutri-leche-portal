import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notification_banner.dart';

class CumpleaniosScreen extends StatefulWidget {
  const CumpleaniosScreen({super.key});

  @override
  State<CumpleaniosScreen> createState() => _CumpleaniosScreenState();
}

class _CumpleaniosScreenState extends State<CumpleaniosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  DateTime? _fechaSeleccionada;
  String? _plantaSeleccionada;

  final List<String> _plantas = [
    'Planta Administrativa',
    'Planta de Recursos Humanos',
    'Planta Bodega',
    'Planta de Producción',
    'Planta de Ventas',
  ];

  List<Map<String, dynamic>> _cumpleanios = [];

  @override
  void initState() {
    super.initState();
    _cargarCumpleanios();
  }

  // 🔹 Cargar cumpleaños desde almacenamiento
  Future<void> _cargarCumpleanios() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cumpleanios') ?? [];

    final listaConvertida = data.map<Map<String, dynamic>>((e) {
      return Map<String, dynamic>.from(jsonDecode(e));
    }).toList();

    if (!mounted) return;
    setState(() {
      _cumpleanios = listaConvertida;
    });
  }

  // 🔹 Guardar cumpleaños y redirigir al calendario
  Future<void> _guardarCumpleanio() async {
    if (!_formKey.currentState!.validate() || _fechaSeleccionada == null) {
      NotificationBanner.show(
          context, 'Completa todos los campos.', NotificationType.error);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cumpleanios') ?? [];

    final nuevo = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'correo': _correoController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'planta': _plantaSeleccionada ?? '',
      'fecha': DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!),
    };

    // ✅ Agregar al almacenamiento local
    data.add(jsonEncode(nuevo));
    await prefs.setStringList('cumpleanios', data);

    // ✅ Mostrar mensaje de éxito
    NotificationBanner.show(
      context,
      '🎉 Cumpleaños registrado correctamente (Web)',
      NotificationType.success,
    );

    // ✅ Limpiar campos
    _nombreController.clear();
    _apellidoController.clear();
    _correoController.clear();
    _telefonoController.clear();
    _plantaSeleccionada = null;
    _fechaSeleccionada = null;

    await _cargarCumpleanios();

    // 🔁 Redirigir al calendario para que recargue y muestre el nuevo cumpleaños
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/calendario_eventos');
    }
  }

  // 🔹 Eliminar cumpleaños (opcional)
  Future<void> _eliminarCumpleanio(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cumpleanios') ?? [];
    data.removeAt(index);
    await prefs.setStringList('cumpleanios', data);
    _cargarCumpleanios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          '🎂 Registrar Cumpleaños',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Planta / Departamento',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                    value: _plantaSeleccionada,
                    items: _plantas.map((planta) {
                      return DropdownMenuItem(
                        value: planta,
                        child: Text(planta),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _plantaSeleccionada = v),
                    validator: (v) => v == null ? 'Selecciona una planta' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fechaSeleccionada == null
                              ? 'Selecciona la fecha de nacimiento'
                              : 'Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (fecha != null) {
                            setState(() => _fechaSeleccionada = fecha);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _guardarCumpleanio,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Guardar Información'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              '🎉 Cumpleaños registrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_cumpleanios.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'No hay cumpleaños registrados.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            if (_cumpleanios.isNotEmpty)
              ..._cumpleanios.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.cake, color: Colors.pink),
                    title: Text('${c['nombre']} ${c['apellido']}'),
                    subtitle: Text(
                      '${c['planta']}\n${c['fecha']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarCumpleanio(index),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
