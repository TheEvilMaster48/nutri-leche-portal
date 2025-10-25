import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/evento.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';

class CalendarioEventosScreen extends StatefulWidget {
  const CalendarioEventosScreen({super.key});

  @override
  State<CalendarioEventosScreen> createState() =>
      _CalendarioEventosScreenState();
}

class _CalendarioEventosScreenState extends State<CalendarioEventosScreen> {
  final Map<DateTime, List<Evento>> _eventosPorFecha = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Color _colorPorPlanta(String planta) {
    switch (planta.toLowerCase()) {
      case 'planta administrativa':
        return Colors.blue.shade600;
      case 'planta de recursos humanos':
      case 'recursos humanos':
        return Colors.purple.shade500;
      case 'planta bodega':
        return Colors.orange.shade600;
      case 'planta produccion':
      case 'planta de produccion':
        return Colors.green.shade600;
      case 'planta ventas':
        return Colors.red.shade500;
      default:
        return Colors.grey.shade600;
    }
  }

  // 🔹 Cargar eventos + cumpleaños
  Future<void> _cargarEventos() async {
    try {
      if (!mounted) return;
      final auth = context.read<AuthService>();
      final usuario = auth.currentUser;
      final eventoService = context.read<EventoService>();

      if (usuario == null) {
        if (mounted) {
          NotificationBanner.show(
            context,
            '⚠️ No hay sesión activa.',
            NotificationType.error,
          );
        }
        return;
      }

      await eventoService.recargarEventos(usuario: usuario);
      final eventos = eventoService.eventos;

      // Roles
      final rolesAccesoTotal = [
        'admin',
        'recursos',
        'bodega',
        'produccion',
        'ventas'
      ];

      final bool esEmpleado = usuario.rol.toLowerCase() == 'empleado';
      final bool tieneAccesoTotal =
          rolesAccesoTotal.contains(usuario.rol.toLowerCase());

      List<Evento> eventosFiltrados;
      if (esEmpleado || tieneAccesoTotal) {
        eventosFiltrados = eventos;
      } else {
        eventosFiltrados = eventos
            .where((e) =>
                e.creadoPor.toLowerCase().contains(usuario.planta.toLowerCase()))
            .toList();
      }

      // 🔹 Añadir cumpleaños de la planta
      final cumpleanios = await _cargarCumpleaniosPorPlanta(usuario.planta);
      final todosLosEventos = [...eventosFiltrados, ...cumpleanios];

      // 🔹 Agrupar todo por fecha
      final Map<DateTime, List<Evento>> agrupados = {};
      for (var evento in todosLosEventos) {
        try {
          final partes = evento.fecha.split(' - ');
          final fechaStr = partes[0];
          final horaStr = partes.length > 1 ? partes[1] : '00H00';
          final horaParseada = horaStr.replaceAll('H', ':');
          final fechaCompleta =
              DateFormat('yyyy-MM-dd HH:mm').parse('$fechaStr $horaParseada');

          final dia = DateTime(
            fechaCompleta.year,
            fechaCompleta.month,
            fechaCompleta.day,
          );

          agrupados.putIfAbsent(dia, () => []);
          agrupados[dia]!.add(evento);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _eventosPorFecha
            ..clear()
            ..addAll(agrupados);
        });
      }
    } catch (e) {
      if (mounted) {
        NotificationBanner.show(
          context,
          'Error al cargar eventos: ${e.toString()}',
          NotificationType.error,
        );
      }
    }
  }

  // 🔸 Leer cumpleaños guardados localmente
  Future<List<Evento>> _cargarCumpleaniosPorPlanta(String planta) async {
    final List<Evento> lista = [];
    try {
      final dir = await getApplicationDocumentsDirectory();
      final base = Directory('${dir.path}/cumpleanios/${planta.replaceAll(' ', '_')}');
      if (!await base.exists()) return [];

      final carpetas = base.listSync().whereType<Directory>();
      for (var carpeta in carpetas) {
        final archivo = File('${carpeta.path}/datos.txt');
        if (await archivo.exists()) {
          final contenido = await archivo.readAsString();
          final lineas = contenido.split('\n');
          String nombre = '', fecha = '', plantaTxt = '';
          for (var l in lineas) {
            if (l.startsWith('Nombre:')) nombre = l.replaceFirst('Nombre:', '').trim();
            if (l.startsWith('Fecha de nacimiento:')) {
              fecha = l.replaceFirst('Fecha de nacimiento:', '').trim();
            }
            if (l.startsWith('Planta:')) plantaTxt = l.replaceFirst('Planta:', '').trim();
          }

          if (nombre.isNotEmpty && fecha.isNotEmpty) {
            final fechaCumple = DateFormat('dd/MM/yyyy').parse(fecha);
            final evento = Evento(
              id: DateTime.now().millisecondsSinceEpoch.toString(), // ✅ convertido a String
              titulo: "🎂 Cumpleaños de $nombre",
              descripcion: "Festejo de cumpleaños en $plantaTxt",
              fecha: DateFormat('yyyy-MM-dd - HH:mm').format(fechaCumple),
              creadoPor: plantaTxt,
              archivoPath: '',
            );
            lista.add(evento);
          }
        }
      }
    } catch (e) {
      debugPrint("Error leyendo cumpleaños: $e");
    }
    return lista;
  }

  List<Evento> _obtenerEventos(DateTime day) {
    return _eventosPorFecha[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final usuario = auth.currentUser;
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          'Calendario de Eventos y Cumpleaños 🎉',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (tieneAccesoTotal)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'Añadir evento',
              onPressed: () {
                NotificationBanner.show(
                  context,
                  '📝 Funcionalidad de añadir evento (solo acceso total)',
                  NotificationType.info,
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendario(),
          const Divider(thickness: 1, height: 1),
          Expanded(child: _buildEventosDelDia(tieneAccesoTotal)),
        ],
      ),
    );
  }

  Widget _buildCalendario() {
    return TableCalendar<Evento>(
      focusedDay: _focusedDay,
      firstDay: DateTime(2023),
      lastDay: DateTime(2030),
      locale: 'es_ES',
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.all,
      eventLoader: _obtenerEventos,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.teal.shade300,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.teal.shade700,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.teal.shade700),
        rightChevronIcon:
            Icon(Icons.chevron_right, color: Colors.teal.shade700),
      ),
      calendarBuilders: CalendarBuilders<Evento>(
        markerBuilder: (context, date, eventos) {
          if (eventos.isEmpty) return const SizedBox();
          return Wrap(
            spacing: 2,
            children: eventos
                .map((Evento e) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: e.titulo.contains('Cumpleaños')
                            ? Colors.pinkAccent
                            : _colorPorPlanta(e.creadoPor),
                        shape: BoxShape.circle,
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildEventosDelDia(bool tieneAccesoTotal) {
    final eventos = _obtenerEventos(_selectedDay ?? DateTime.now());

    if (eventos.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos en esta fecha.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventos.length,
      itemBuilder: (context, index) {
        final e = eventos[index];
        return GestureDetector(
          onTap: () => _mostrarDetallesEvento(e, tieneAccesoTotal),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: e.titulo.contains('Cumpleaños')
                      ? Colors.pinkAccent
                      : _colorPorPlanta(e.creadoPor),
                  width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: e.titulo.contains('Cumpleaños')
                    ? Colors.pinkAccent
                    : _colorPorPlanta(e.creadoPor),
                child: Icon(
                  e.titulo.contains('Cumpleaños')
                      ? Icons.cake
                      : Icons.event,
                  color: Colors.white,
                ),
              ),
              title: Text(
                e.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${e.descripcion}\n📅 ${e.fecha}\n🏢 ${e.creadoPor}',
                style: const TextStyle(color: Colors.black87),
              ),
              isThreeLine: true,
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetallesEvento(Evento evento, bool tieneAccesoTotal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(evento.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(evento.descripcion),
            const SizedBox(height: 8),
            Text('📅 Fecha: ${evento.fecha}'),
            Text('🏢 ${evento.creadoPor}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
