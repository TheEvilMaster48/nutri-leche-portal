class Usuario {
  final String id;
  final String username;
  final String password;
  final String nombreCompleto;
  final String correo;
  final String codigoEmpleado;
  final String telefono;
  final String cargo;
  final String planta;
  final DateTime fechaRegistro;

  Usuario({
    required this.id,
    required this.username,
    required this.password,
    required this.nombreCompleto,
    required this.correo,
    required this.codigoEmpleado,
    required this.telefono,
    required this.cargo,
    required this.planta,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nombreCompleto': nombreCompleto,
      'correo': correo,
      'codigoEmpleado': codigoEmpleado,
      'telefono': telefono,
      'cargo': cargo,
      'planta': planta,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      nombreCompleto: json['nombreCompleto'],
      correo: json['correo'],
      codigoEmpleado: json['codigoEmpleado'],
      telefono: json['telefono'],
      cargo: json['cargo'],
      planta: json['planta'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }
}
