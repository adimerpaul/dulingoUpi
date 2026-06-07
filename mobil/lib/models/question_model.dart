class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.nombre,
    required this.tipoPregunta,
    required this.config,
    required this.respuestas,
  });

  final int id;
  final String nombre;
  final String tipoPregunta;
  final Map<String, dynamic> config;
  final List<AnswerModel> respuestas;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final respuestasJson = json['respuestas'] as List<dynamic>? ?? [];
    final rawConfig = json['config'];
    return QuestionModel(
      id: int.parse('${json['id']}'),
      nombre: '${json['nombre'] ?? ''}',
      tipoPregunta: '${json['tipo_pregunta'] ?? 'multiple_choice'}',
      config: rawConfig is Map<String, dynamic> ? rawConfig : {},
      respuestas: respuestasJson
          .map((item) => AnswerModel.fromJson(item))
          .toList(),
    );
  }
}

class AnswerModel {
  const AnswerModel({
    required this.id,
    required this.nombre,
    required this.esCorrecta,
  });

  final int id;
  final String nombre;
  final bool esCorrecta;

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: int.parse('${json['id']}'),
      nombre: '${json['nombre'] ?? ''}',
      esCorrecta:
          json['es_correcta'] == true || '${json['es_correcta']}' == '1',
    );
  }
}
