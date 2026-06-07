class SectionModel {
  const SectionModel({
    required this.id,
    required this.nombre,
    required this.detalles,
  });

  final int id;
  final String nombre;
  final List<SectionDetailModel> detalles;

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final detallesJson = json['detalles'] as List<dynamic>? ?? [];
    return SectionModel(
      id: int.parse('${json['id']}'),
      nombre: '${json['nombre'] ?? ''}',
      detalles: detallesJson
          .map((item) => SectionDetailModel.fromJson(item))
          .toList(),
    );
  }
}

class SectionDetailModel {
  const SectionDetailModel({
    required this.id,
    required this.seccionId,
    required this.nombre,
    required this.tipo,
    required this.color,
    required this.orden,
    required this.realizado,
  });

  final int id;
  final int seccionId;
  final String nombre;
  final String tipo;
  final String color;
  final int orden;
  final bool realizado;

  factory SectionDetailModel.fromJson(Map<String, dynamic> json) {
    return SectionDetailModel(
      id: int.parse('${json['id']}'),
      seccionId: int.parse('${json['seccion_id']}'),
      nombre: '${json['nombre'] ?? ''}',
      tipo: '${json['tipo'] ?? 'lesson'}',
      color: '${json['color'] ?? '#ff7a45'}',
      orden: int.tryParse('${json['orden'] ?? 0}') ?? 0,
      realizado: json['realizado'] == true || '${json['realizado']}' == '1',
    );
  }
}
