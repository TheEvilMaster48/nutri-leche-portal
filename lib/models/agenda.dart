class Agenda {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final String recordatorio;

  Agenda({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.recordatorio,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      recordatorio: json['recordatorio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'recordatorio': recordatorio,
      };
}
