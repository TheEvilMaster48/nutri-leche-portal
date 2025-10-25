import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/agenda.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  List<Agenda> _citas = [];
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _horaInicioCtrl = TextEditingController();
  final _horaFinCtrl = TextEditingController();
  final _recordatorioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('agenda');
    if (data != null) {
      final lista = jsonDecode(data) as List;
      setState(() {
        _citas = lista.map((e) => Agenda.fromJson(e)).toList();
      });
    }
  }

  Future<void> _guardarCitas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'agenda',
      jsonEncode(_citas.map((e) => e.toJson()).toList()),
    );
  }

  void _agregarCita() async {
    final nueva = Agenda(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: _tituloCtrl.text,
      descripcion: _descripcionCtrl.text,
      fecha: DateTime.now(),
      horaInicio: _horaInicioCtrl.text,
      horaFin: _horaFinCtrl.text,
      recordatorio: _recordatorioCtrl.text,
    );

    setState(() => _citas.add(nueva));
    await _guardarCitas();

    _tituloCtrl.clear();
    _descripcionCtrl.clear();
    _horaInicioCtrl.clear();
    _horaFinCtrl.clear();
    _recordatorioCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita añadida a la agenda')),
    );
  }

  void _eliminarCita(int id) async {
    setState(() => _citas.removeWhere((a) => a.id == id));
    await _guardarCitas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗓️ Mi Agenda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExpansionTile(
              title: const Text('Agregar nueva cita'),
              children: [
                TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
                TextField(controller: _descripcionCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
                TextField(controller: _horaInicioCtrl, decoration: const InputDecoration(labelText: 'Hora de inicio')),
                TextField(controller: _horaFinCtrl, decoration: const InputDecoration(labelText: 'Hora de fin')),
                TextField(controller: _recordatorioCtrl, decoration: const InputDecoration(labelText: 'Recordatorio')),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _agregarCita,
                  child: const Text('Guardar Cita'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _citas.isEmpty
                  ? const Center(child: Text('No tienes citas registradas'))
                  : ListView.builder(
                      itemCount: _citas.length,
                      itemBuilder: (context, i) {
                        final c = _citas[i];
                        return Card(
                          child: ListTile(
                            title: Text(c.titulo),
                            subtitle: Text('${c.descripcion}\n${c.horaInicio} - ${c.horaFin}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _eliminarCita(c.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
