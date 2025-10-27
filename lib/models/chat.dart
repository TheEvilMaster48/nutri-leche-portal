class Mensaje {
  final String usuario;
  final String contenido;
  final DateTime fechaHora;
  final bool esPropio;

  Mensaje({
    required this.usuario,
    required this.contenido,
    required this.fechaHora,
    required this.esPropio,
  });

  Map<String, dynamic> toJson() => {
        'usuario': usuario,
        'contenido': contenido,
        'fechaHora': fechaHora.toIso8601String(),
      };

  factory Mensaje.fromJson(Map<String, dynamic> json) => Mensaje(
        usuario: json['usuario'] ?? '',
        contenido: json['contenido'] ?? '',
        fechaHora: DateTime.tryParse(json['fechaHora'] ?? '') ?? DateTime.now(),
        esPropio: false,
      );
}
