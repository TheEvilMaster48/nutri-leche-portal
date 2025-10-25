class Sugerencia {
  final int id;
  final String titulo;
  final String mensaje;
  final String autor;
  final bool anonimo;
  final DateTime fecha;
  final String estado;

  Sugerencia({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.autor,
    required this.anonimo,
    required this.fecha,
    required this.estado,
  });

  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      autor: json['autor'] ?? '',
      anonimo: json['anonimo'] ?? false,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      estado: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'mensaje': mensaje,
        'autor': autor,
        'anonimo': anonimo,
        'fecha': fecha.toIso8601String(),
        'estado': estado,
      };
}
