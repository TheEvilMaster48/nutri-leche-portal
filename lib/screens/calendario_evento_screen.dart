import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class _CalendarioEventosScreenState extends State<CalendarioEventosScreen>
    with SingleTickerProviderStateMixin {
  final Map<DateTime, List<Evento>> _eventosPorFecha = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _panelVisible = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _cargarEventos() async {
    try {
      final auth = context.read<AuthService>();
      final usuario = auth.currentUser;
      final eventoService = context.read<EventoService>();
      await eventoService.recargarEventos(usuario: usuario);
      final eventos = eventoService.eventos;
      final cumpleanios = await _cargarCumpleaniosUnicos();

      final todos = [...eventos, ...cumpleanios];
      final sinDuplicados = {
        for (var e in todos) '${e.titulo}-${e.fecha}': e
      }.values.toList();

      final Map<DateTime, List<Evento>> agrupados = {};
      for (var evento in sinDuplicados) {
        try {
          DateTime fecha;
          if (evento.fecha.contains('/')) {
            fecha = DateFormat('dd/MM/yyyy').parse(evento.fecha);
          } else {
            fecha = DateFormat('yyyy-MM-dd').parse(evento.fecha);
          }
          final hoy = DateTime.now();
          final dia = DateTime(hoy.year, fecha.month, fecha.day);
          agrupados.putIfAbsent(dia, () => []);
          agrupados[dia]!.add(evento);
        } catch (_) {}
      }

      setState(() {
        _eventosPorFecha
          ..clear()
          ..addAll(agrupados);
      });
    } catch (e) {
      NotificationBanner.show(
        context,
        'ERROR AL CARGAR EVENTOS: ${e.toString()}',
        NotificationType.error,
      );
    }
  }

  Future<List<Evento>> _cargarCumpleaniosUnicos() async {
    final List<Evento> lista = [];
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('cumpleanios') ?? [];

    for (var item in data) {
      final registro = jsonDecode(item);
      final nombre = registro['nombre'] ?? '';
      final apellido = registro['apellido'] ?? '';
      final planta = registro['planta'] ?? 'Sin planta';
      final nombreCompleto = '$nombre $apellido'.trim();
      if (nombreCompleto.isEmpty) continue;

      final fechaBase =
          DateFormat('dd/MM/yyyy').parse(registro['fecha'] ?? '01/01/2000');
      final fechaCumple =
          DateTime(DateTime.now().year, fechaBase.month, fechaBase.day);

      lista.add(Evento(
        id: '${nombreCompleto}_${fechaCumple.year}',
        titulo: '🎂 Cumpleaños de $nombreCompleto',
        descripcion: 'Festejo de cumpleaños en $planta',
        fecha: DateFormat('yyyy-MM-dd').format(fechaCumple),
        creadoPor: planta,
        archivoPath: '',
      ));
    }
    return lista;
  }

  List<Evento> _obtenerEventos(DateTime day) {
    final hoy = DateTime.now();
    final normalizado = DateTime(hoy.year, day.month, day.day);
    return _eventosPorFecha[normalizado] ?? [];
  }

  void _togglePanel() {
    setState(() {
      _panelVisible = !_panelVisible;
      if (_panelVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthService>().currentUser;
    final planta = usuario?.planta ?? "Administrativa";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: Text(
          'CALENDARIO - $planta',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarEventos,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 🔹 Calendario grande
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCalendario(),
                ),
              ),
              // 🔹 Leyenda
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.event_note, color: Colors.blue, size: 22),
                    SizedBox(width: 6),
                    Text('Eventos'),
                    SizedBox(width: 20),
                    Icon(Icons.cake, color: Colors.pinkAccent, size: 22),
                    SizedBox(width: 6),
                    Text('Cumpleaños'),
                  ],
                ),
              ),
              const SizedBox(height: 80), // espacio para el panel inferior
            ],
          ),

          // 🔹 Panel inferior deslizante
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: _panelVisible ? 0 : -250, // sube o baja
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Botón de control del panel
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _panelVisible
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.teal.shade700,
                        size: 28,
                      ),
                      onPressed: _togglePanel,
                    ),
                  ),
                  Expanded(child: _buildEventosDelDia()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendario() {
    return TableCalendar<Evento>(
      focusedDay: _focusedDay,
      firstDay: DateTime(1900),
      lastDay: DateTime(4000),
      locale: 'es_ES',
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      eventLoader: _obtenerEventos,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
          _panelVisible = true; // 🔹 abre el panel automáticamente
          _controller.forward();
        });
      },
      calendarStyle: CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Colors.teal.shade300, shape: BoxShape.circle),
        selectedDecoration:
            BoxDecoration(color: Colors.teal.shade700, shape: BoxShape.circle),
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        leftChevronIcon:
            Icon(Icons.chevron_left, color: Colors.teal.shade700),
        rightChevronIcon:
            Icon(Icons.chevron_right, color: Colors.teal.shade700),
      ),
      calendarBuilders: CalendarBuilders<Evento>(
        markerBuilder: (context, date, eventos) {
          if (eventos.isEmpty) return const SizedBox();
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 35),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventosDelDia() {
    final eventos = _obtenerEventos(_selectedDay ?? DateTime.now());
    if (eventos.isEmpty) {
      return const Center(
        child: Text(
          'NO HAY EVENTOS EN ESTA FECHA.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final eventosUnicos = {
      for (var e in eventos) e.titulo: e,
    }.values.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventosUnicos.length,
      itemBuilder: (context, index) {
        final e = eventosUnicos[index];
        final bool esCumple = e.titulo.contains('Cumpleaños');
        final color = esCumple ? Colors.pinkAccent : Colors.blue.shade600;
        final icono = esCumple ? Icons.cake : Icons.event_note;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
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
              backgroundColor: color,
              child: Icon(icono, color: Colors.white),
            ),
            title: Text(
              e.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${e.descripcion}\nFecha: ${e.fecha}\nPlanta: ${e.creadoPor}',
              style: const TextStyle(color: Colors.black87),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

