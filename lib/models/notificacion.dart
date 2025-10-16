class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String fecha;
  final String tipo;
  final bool leida;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.tipo,
    required this.leida,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'mensaje': mensaje,
    'fecha': fecha,
    'tipo': tipo,
    'leida': leida,
  };

  factory Notificacion.fromJson(Map<String, dynamic> json) => Notificacion(
    id: json['id'],
    titulo: json['titulo'],
    mensaje: json['mensaje'],
    fecha: json['fecha'],
    tipo: json['tipo'],
    leida: json['leida'] ?? false,
  );
}
