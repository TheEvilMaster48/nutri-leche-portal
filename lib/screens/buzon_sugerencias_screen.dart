import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sugerencia.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class BuzonSugerenciasScreen extends StatefulWidget {
  const BuzonSugerenciasScreen({super.key});

  @override
  State<BuzonSugerenciasScreen> createState() =>
      _BuzonSugerenciasScreenState();
}

class _BuzonSugerenciasScreenState extends State<BuzonSugerenciasScreen> {
  List<Sugerencia> _sugerencias = [];
  final _tituloCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  bool _anonimo = false;

  @override
  void initState() {
    super.initState();
    _cargarSugerencias();
  }

  Future<void> _cargarSugerencias() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('sugerencias');
    if (data != null) {
      final lista = jsonDecode(data) as List;
      setState(() {
        _sugerencias = lista.map((e) => Sugerencia.fromJson(e)).toList();
      });
    }
  }

  Future<void> _guardarSugerencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'sugerencias',
      jsonEncode(_sugerencias.map((e) => e.toJson()).toList()),
    );
  }

  void _enviarSugerencia() async {
    final auth = context.read<AuthService>();
    final usuario = auth.currentUser;
    final autor = _anonimo ? 'Anónimo' : (usuario?.nombreCompleto ?? 'Empleado');

    final nueva = Sugerencia(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: _tituloCtrl.text,
      mensaje: _mensajeCtrl.text,
      autor: autor,
      anonimo: _anonimo,
      fecha: DateTime.now(),
      estado: 'pendiente',
    );

    setState(() => _sugerencias.add(nueva));
    await _guardarSugerencias();

    _tituloCtrl.clear();
    _mensajeCtrl.clear();
    setState(() => _anonimo = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sugerencia enviada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📬 Buzón de Sugerencias')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título')),
            TextField(controller: _mensajeCtrl, decoration: const InputDecoration(labelText: 'Mensaje')),
            SwitchListTile(
              title: const Text('Enviar de forma anónima'),
              value: _anonimo,
              onChanged: (v) => setState(() => _anonimo = v),
            ),
            ElevatedButton(onPressed: _enviarSugerencia, child: const Text('Enviar sugerencia')),
            const Divider(),
            Expanded(
              child: _sugerencias.isEmpty
                  ? const Center(child: Text('Sin sugerencias enviadas'))
                  : ListView.builder(
                      itemCount: _sugerencias.length,
                      itemBuilder: (context, i) {
                        final s = _sugerencias[i];
                        return Card(
                          child: ListTile(
                            title: Text(s.titulo),
                            subtitle: Text('${s.mensaje}\nEstado: ${s.estado}'),
                            trailing: Text(
                                '${s.fecha.day}/${s.fecha.month}/${s.fecha.year}'),
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
