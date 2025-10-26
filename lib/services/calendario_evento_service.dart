import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/evento.dart';

class CalendarioEventoService {
  Future<List<Evento>> cargarCumpleaniosPorPlanta(String planta) async {
    final List<Evento> lista = [];
    try {
      final dir = await getApplicationDocumentsDirectory();
      final base =
          Directory('${dir.path}/cumpleanios/${planta.replaceAll(' ', '_')}');
      if (!await base.exists()) return [];

      final carpetas = base.listSync().whereType<Directory>();
      for (var carpeta in carpetas) {
        final archivo = File('${carpeta.path}/datos.txt');
        if (await archivo.exists()) {
          final contenido = await archivo.readAsString();
          final lineas = contenido.split('\n');
          String nombre = '', fecha = '', plantaTxt = '';
          for (var l in lineas) {
            if (l.startsWith('Nombre:')) {
              nombre = l.replaceFirst('Nombre:', '').trim();
            }
            if (l.startsWith('Fecha de nacimiento:')) {
              fecha = l.replaceFirst('Fecha de nacimiento:', '').trim();
            }
            if (l.startsWith('Planta:')) {
              plantaTxt = l.replaceFirst('Planta:', '').trim();
            }
          }

          if (nombre.isNotEmpty && fecha.isNotEmpty) {
            final fechaBase = DateFormat('dd/MM/yyyy').parse(fecha);
            for (int year = DateTime.now().year; year <= 4000; year++) {
              final fechaCumple = DateTime(year, fechaBase.month, fechaBase.day);
              final fechaNormalizada = DateTime(
                  fechaCumple.year, fechaCumple.month, fechaCumple.day);
              final evento = Evento(
                id: '${nombre}_$year',
                titulo: 'CUMPLEAÑOS DE $nombre',
                descripcion: 'FESTEJO DE CUMPLEAÑOS EN $plantaTxt',
                fecha:
                    DateFormat('yyyy-MM-dd - HH:mm').format(fechaNormalizada),
                creadoPor: plantaTxt,
                archivoPath: '',
              );
              lista.add(evento);
            }
          }
        }
      }
    } catch (e) {
      print('ERROR LEYENDO CUMPLEAÑOS: $e');
    }
    return lista;
  }

  Map<DateTime, List<Evento>> agruparPorFecha(List<Evento> eventos) {
    final Map<DateTime, List<Evento>> agrupados = {};
    for (var evento in eventos) {
      try {
        final partes = evento.fecha.split(' - ');
        final fechaStr = partes[0];
        final horaStr = partes.length > 1 ? partes[1] : '00:00';
        final fechaCompleta =
            DateFormat('yyyy-MM-dd HH:mm').parse('$fechaStr $horaStr');

        final dia = DateTime(
            fechaCompleta.year, fechaCompleta.month, fechaCompleta.day);

        agrupados.putIfAbsent(dia, () => []);
        agrupados[dia]!.add(evento);
      } catch (_) {}
    }
    return agrupados;
  }
}
