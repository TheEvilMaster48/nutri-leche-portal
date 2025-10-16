class Recurso {
  final String id;
  final String titulo;
  final String descripcion;
  final String tipo; // 'pdf', 'documento', 'imagen'
  final String? contenido;
  final DateTime fechaCreacion;

  Recurso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.contenido,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'contenido': contenido,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Recurso.fromJson(Map<String, dynamic> json) {
    return Recurso(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      contenido: json['contenido'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
