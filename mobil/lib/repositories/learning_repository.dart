import '../models/exercise_model.dart';
import '../models/question_model.dart';
import '../models/section_model.dart';
import '../services/api_client.dart';

class LearningRepository {
  LearningRepository(this._api);

  final ApiClient _api;

  Future<List<SectionModel>> getSections() async {
    final response = await _api.get('/secciones');
    final data = response['data'] as Map<String, dynamic>;
    final list = data['secciones'] as List<dynamic>? ?? [];
    return list.map((item) => SectionModel.fromJson(item)).toList();
  }

  Future<List<ExerciseModel>> getExercises({
    required int sectionId,
    required int detailId,
  }) async {
    final response = await _api.get(
      '/secciones/$sectionId/detalles/$detailId/preguntas',
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = data['preguntas'] as List<dynamic>? ?? [];
    return list
        .map((item) => QuestionModel.fromJson(item))
        .map(ExerciseModel.fromQuestion)
        .toList();
  }

  Future<void> markComplete(int detailId) async {
    await _api.post('/progreso', {'seccion_detalle_id': detailId});
  }
}
