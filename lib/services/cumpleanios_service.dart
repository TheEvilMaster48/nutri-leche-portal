import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/cumpleanios.dart';

class CumpleaniosService {
  static Future<Directory> _getDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/cumpleanios');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return carpeta;
  }

  // Guardar cumpleaños en archivo .txt
  static Future<void> guardarCumpleanios(Cumpleanios c) async {
    final carpeta = await _getDir();
    final nombreArchivo = c.nombreCompleto.replaceAll(' ', '_');
    final file = File('${carpeta.path}/$nombreArchivo.txt');
    await file.writeAsString(c.toText());
  }

  // Leer todos los archivos de cumpleaños
  static Future<List<Cumpleanios>> listarCumpleanios() async {
    final carpeta = await _getDir();
    final archivos = carpeta.listSync();
    List<Cumpleanios> lista = [];

    for (var a in archivos) {
      if (a is File && a.path.endsWith('.txt')) {
        final contenido = await a.readAsString();
        final c = Cumpleanios.fromText(contenido);
        lista.add(c);
      }
    }
    return lista;
  }

  // Eliminar cumpleaños
  static Future<void> eliminarCumpleanios(String nombreCompleto) async {
    final carpeta = await _getDir();
    final file = File('${carpeta.path}/${nombreCompleto.replaceAll(' ', '_')}.txt');
    if (await file.exists()) await file.delete();
  }
}
