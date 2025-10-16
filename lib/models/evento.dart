class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final String fecha;
  final String creadoPor;
  final String? imagenPath;   // ✅ Nuevo campo opcional
  final String? archivoPath;  // ✅ Nuevo campo opcional

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.creadoPor,
    this.imagenPath,
    this.archivoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha,
        'creadoPor': creadoPor,
        'imagenPath': imagenPath,
        'archivoPath': archivoPath,
      };

  factory Evento.fromJson(Map<String, dynamic> json) => Evento(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        fecha: json['fecha'],
        creadoPor: json['creadoPor'],
        imagenPath: json['imagenPath'],
        archivoPath: json['archivoPath'],
      );
}

