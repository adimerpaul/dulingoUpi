class UserModel {
  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final int id;
  final String nombre;
  final String email;
  final String rol;

  bool get isAdmin => rol == 'Administrador' || id == 1;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse('${json['id']}'),
      nombre: '${json['nombre'] ?? ''}',
      email: '${json['email'] ?? ''}',
      rol: '${json['rol'] ?? 'Estudiante'}',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'email': email, 'rol': rol};
  }
}
