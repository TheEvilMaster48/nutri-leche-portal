import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/evento_service.dart';
import '../services/auth_service.dart';
import '../models/evento.dart';
import '../models/usuario.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final Map<String, bool> _categoriaExpandida = {};
  bool mostrarEventosPasados = false;

  List<Evento> _eventosTotales = [];

  @override
  void initState() {
    super.initState();
    _cargarEventosIniciales();
  }

  Future<void> _cargarEventosIniciales() async {
    final eventoService = context.read<EventoService>();
    final auth = context.read<AuthService>();
    final usuario = auth.currentUser;

    if (usuario == null) return;

    if (_tieneAccesoTotal(usuario)) {
      await eventoService.recargarEventos(usuario: usuario);
      setState(() {
        _eventosTotales = eventoService.eventos;
      });
    } else {
      final todos = await eventoService.obtenerTodosLosEventos();
      setState(() {
        _eventosTotales = todos;
      });
    }
  }

  bool _tieneAccesoTotal(Usuario usuario) {
    const rolesPermitidos = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];
    return rolesPermitidos.contains(usuario.rol);
  }

  @override
  Widget build(BuildContext context) {
    final eventoService = context.watch<EventoService>();
    final auth = context.watch<AuthService>();
    final Usuario? usuario = auth.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error: no hay sesión activa',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    final bool esAdmin = _tieneAccesoTotal(usuario);
    final String plantaUsuario = usuario.planta;

    // Categorías fijas
    final categorias = [
      'Planta Administrativa',
      'Planta de Recursos Humanos',
      'Planta Bodega',
      'Planta Producción',
      'Planta Ventas',
    ];

    // Obtener fecha y hora actual
    final ahora = DateTime.now();
    List<Evento> eventosActivos = [];
    List<Evento> eventosPasados = [];

    // Clasificar eventos activos / pasados
    for (var e in _eventosTotales) {
      try {
        final partes = e.fecha.split(' - ');
        final fechaStr = partes[0];
        final horaStr = partes.length > 1 ? partes[1] : '00H00';
        final horaParseada = horaStr.replaceAll('H', ':');
        final fechaCompleta =
            DateFormat('yyyy-MM-dd HH:mm').parse('$fechaStr $horaParseada');

        if (fechaCompleta.isBefore(ahora)) {
          eventosPasados.add(e);
        } else {
          eventosActivos.add(e);
        }
      } catch (_) {
        eventosActivos.add(e);
      }
    }

    // ✅ Agrupar eventos por planta según texto del campo creadoPor
    Map<String, List<Evento>> agruparPorPlanta(List<Evento> lista) {
      Map<String, List<Evento>> agrupado = {
        for (var c in categorias) c: [],
      };

      for (var e in lista) {
        final creador = e.creadoPor.toLowerCase();
        String categoria = 'Planta Administrativa';

        if (creador.contains('recursos') || creador.contains('rrhh')) {
          categoria = 'Planta de Recursos Humanos';
        } else if (creador.contains('bodega')) {
          categoria = 'Planta Bodega';
        } else if (creador.contains('produccion') ||
            creador.contains('producción')) {
          categoria = 'Planta Producción';
        } else if (creador.contains('ventas')) {
          categoria = 'Planta Ventas';
        } else if (creador.contains('administrativa')) {
          categoria = 'Planta Administrativa';
        }

        agrupado[categoria]?.add(e);
      }

      return agrupado;
    }

    final activosPorCategoria = agruparPorPlanta(eventosActivos);
    final pasadosPorCategoria = agruparPorPlanta(eventosPasados);

    // ✅ Filtrar eventos según la planta del usuario
    Map<String, List<Evento>> mostrarMapa;

    if (esAdmin) {
      String categoriaPlanta = 'Planta Administrativa';
      if (plantaUsuario.toLowerCase().contains('recursos')) {
        categoriaPlanta = 'Planta de Recursos Humanos';
      } else if (plantaUsuario.toLowerCase().contains('bodega')) {
        categoriaPlanta = 'Planta Bodega';
      } else if (plantaUsuario.toLowerCase().contains('produccion') ||
          plantaUsuario.toLowerCase().contains('producción')) {
        categoriaPlanta = 'Planta Producción';
      } else if (plantaUsuario.toLowerCase().contains('ventas')) {
        categoriaPlanta = 'Planta Ventas';
      }

      mostrarMapa = mostrarEventosPasados
          ? {
              categoriaPlanta: pasadosPorCategoria[categoriaPlanta] ?? [],
            }
          : {
              categoriaPlanta: activosPorCategoria[categoriaPlanta] ?? [],
            };
    } else {
      // Empleados ven todos los eventos activos combinados
      mostrarMapa = mostrarEventosPasados
          ? pasadosPorCategoria
          : activosPorCategoria;
    }

    final tituloSeccion = esAdmin
        ? (mostrarEventosPasados ? 'Eventos Pasados' : 'Eventos Programados')
        : 'Eventos Programados';

    return Scaffold(
      appBar: AppBar(
        title: Text(tituloSeccion, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (esAdmin)
            IconButton(
              icon: Icon(
                mostrarEventosPasados
                    ? Icons.event_available_rounded
                    : Icons.history_rounded,
              ),
              tooltip: mostrarEventosPasados
                  ? 'Ver próximos eventos'
                  : 'Ver eventos pasados',
              onPressed: () {
                setState(() => mostrarEventosPasados = !mostrarEventosPasados);
              },
            ),
          if (esAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Nuevo evento',
              onPressed: () async {
                await Navigator.pushNamed(context, '/crear_evento');
                await eventoService.recargarEventos(usuario: usuario);
                await _cargarEventosIniciales();
              },
            ),
        ],
      ),
      body: _eventosTotales.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No hay eventos disponibles por el momento',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: mostrarMapa.entries.map((entry) {
                final categoria = entry.key;
                final eventos = entry.value;
                final expandida = _categoriaExpandida[categoria] ?? true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _colorPorCategoria(categoria),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    key: Key(categoria),
                    initiallyExpanded: expandida,
                    onExpansionChanged: (valor) {
                      setState(() {
                        _categoriaExpandida[categoria] = valor;
                      });
                    },
                    title: Text(
                      categoria,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _colorPorCategoria(categoria),
                      ),
                    ),
                    trailing: Icon(
                      expandida
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _colorPorCategoria(categoria),
                    ),
                    children: eventos.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'No hay eventos en esta categoría.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          ]
                        : eventos
                            .map((evento) => _buildEventoCard(
                                  evento,
                                  esAdmin,
                                  mostrarEventosPasados,
                                  eventoService,
                                  usuario,
                                ))
                            .toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEventoCard(Evento evento, bool esAdmin, bool eventoPasadoVisible,
      EventoService eventoService, Usuario usuarioActual) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: eventoPasadoVisible
              ? const Color(0xFFEDEDED)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: eventoPasadoVisible
                  ? Colors.grey.withOpacity(0.25)
                  : const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              eventoPasadoVisible ? Icons.event_busy : Icons.event_note,
              color:
                  eventoPasadoVisible ? Colors.grey : const Color(0xFF3B82F6),
            ),
          ),
          title: Text(
            evento.titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: eventoPasadoVisible ? Colors.grey[700] : Colors.black,
              decoration: eventoPasadoVisible
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(evento.descripcion),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(evento.fecha, style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Creado por: ${evento.creadoPor} (#${evento.id})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: esAdmin
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar evento',
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text(
                            '¿Seguro que deseas eliminar el evento "${evento.titulo}" de forma permanente?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await eventoService.eliminarEvento(
                          evento.id, usuarioActual);
                      await _cargarEventosIniciales();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Evento "${evento.titulo}" eliminado'),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  // Colores por planta
  Color _colorPorCategoria(String categoria) {
    switch (categoria) {
      case 'Planta Administrativa':
        return Colors.blue;
      case 'Planta de Recursos Humanos':
        return Colors.purple;
      case 'Planta Bodega':
        return Colors.orange;
      case 'Planta Producción':
        return Colors.green;
      case 'Planta Ventas':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }
}
