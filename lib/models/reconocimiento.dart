class Reconocimiento {
  final int id;
  final String titulo;
  final String descripcion;
  final String autor;
  final String otorgadoA; // persona reconocida
  final String departamento;
  final String tipo; // Ej: Empleado del mes, Trabajo en equipo, etc.
  final DateTime fecha;

  Reconocimiento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.otorgadoA,
    required this.departamento,
    required this.tipo,
    required this.fecha,
  });

  factory Reconocimiento.fromJson(Map<String, dynamic> json) {
    return Reconocimiento(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      autor: json['autor'] ?? '',
      otorgadoA: json['otorgadoA'] ?? '',
      departamento: json['departamento'] ?? '',
      tipo: json['tipo'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'autor': autor,
        'otorgadoA': otorgadoA,
        'departamento': departamento,
        'tipo': tipo,
        'fecha': fecha.toIso8601String(),
      };
}
