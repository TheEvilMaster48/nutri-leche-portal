class Buzon {
  final int id;
  final String asunto;
  final String mensaje;
  final String remitente;
  final String fechaEnvio;     
  final String horaRecibida;   

  Buzon({
    required this.id,
    required this.asunto,
    required this.mensaje,
    required this.remitente,
    required this.fechaEnvio,
    required this.horaRecibida,
  });

  factory Buzon.fromJson(Map<String, dynamic> json) {
    return Buzon(
      id: json['id'],
      asunto: json['asunto'],
      mensaje: json['mensaje'],
      remitente: json['remitente'],
      fechaEnvio: json['fechaEnvio'] ?? '',
      horaRecibida: json['horaRecibida'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'asunto': asunto,
        'mensaje': mensaje,
        'remitente': remitente,
        'fechaEnvio': fechaEnvio,
        'horaRecibida': horaRecibida,
      };
}
