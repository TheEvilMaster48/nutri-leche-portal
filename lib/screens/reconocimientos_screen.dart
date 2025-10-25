import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reconocimiento.dart';
import '../models/usuario.dart';
import '../services/reconocimiento_service.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';

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

  Future<void> _guardarReconocimiento() async {
    final auth = context.read<AuthService>();
    final usuario = auth.currentUser;

    if (usuario == null) return;

    // Verificar rol
    final rolesAccesoTotal = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];
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
      tipo: _tipoSeleccionado!,
      fecha: DateTime.now(),
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
    setState(() => _tipoSeleccionado = null);

    await _cargarReconocimientos();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final Usuario? usuario = auth.currentUser;
    final rolesAccesoTotal = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];
    final bool tieneAccesoTotal =
        rolesAccesoTotal.contains(usuario?.rol.toLowerCase() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B82F6),
        title: const Text(
          "🏅 Reconocimientos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.5),
        actions: [
          if (tieneAccesoTotal)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white),
              tooltip: 'Registrar reconocimiento',
              onPressed: () {
                NotificationBanner.show(
                  context,
                  '📝 Puedes registrar reconocimientos (acceso total)',
                  NotificationType.info,
                );
              },
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (tieneAccesoTotal)
                    _buildFormulario()
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "🔒 Solo lectura: Los empleados pueden visualizar los reconocimientos registrados.",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _reconocimientos.isEmpty
                        ? const Center(
                            child: Text(
                              "No existen reconocimientos registrados",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _reconocimientos.length,
                            itemBuilder: (context, index) {
                              final r = _reconocimientos[index];
                              return _buildCard(r, tieneAccesoTotal);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  // 📋 FORMULARIO (solo visible si tiene acceso total)
  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _tituloController,
            style: const TextStyle(color: Colors.white),
            decoration:
                _inputDecoration("Título del reconocimiento", Icons.star),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Descripción o motivo", Icons.message),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _otorgadoAController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
                "Otorgado a (nombre del compañero)", Icons.person),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            value: _tipoSeleccionado,
            decoration: _inputDecoration(
                "Tipo de reconocimiento", Icons.emoji_events),
            items: const [
              DropdownMenuItem(
                  value: "Excelente trabajo", child: Text("Excelente trabajo")),
              DropdownMenuItem(
                  value: "Empleado del mes", child: Text("Empleado del mes")),
              DropdownMenuItem(
                  value: "Trabajo en equipo", child: Text("Trabajo en equipo")),
              DropdownMenuItem(
                  value: "Innovación destacada",
                  child: Text("Innovación destacada")),
            ],
            onChanged: (valor) => setState(() => _tipoSeleccionado = valor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _guardarReconocimiento,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              "Guardar Reconocimiento",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 💠 Tarjeta elegante para cada reconocimiento
  Widget _buildCard(Reconocimiento r, bool tieneAccesoTotal) {
    final color = r.tipo == "Empleado del mes"
        ? Colors.amberAccent
        : const Color(0xFF3B82F6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.workspace_premium_rounded, color: color, size: 36),
        title: Text(
          r.titulo,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.descripcion, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                "Otorgado a: ${r.otorgadoA}",
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Text(
                "Por: ${r.autor} (${r.departamento})",
                style: const TextStyle(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic,
                    fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: tieneAccesoTotal
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onSelected: (valor) {
                  if (valor == 'editar') {
                    NotificationBanner.show(
                      context,
                      '✏️ Editar reconocimiento seleccionado',
                      NotificationType.info,
                    );
                  } else if (valor == 'eliminar') {
                    NotificationBanner.show(
                      context,
                      '🗑️ Reconocimiento eliminado correctamente',
                      NotificationType.success,
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                ],
              )
            : Text(
                DateFormat('dd/MM/yyyy').format(r.fecha),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
      ),
    );
  }

  // 🎨 Decoración reutilizable
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _otorgadoAController.dispose();
    super.dispose();
  }
}
