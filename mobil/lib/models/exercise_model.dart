import 'question_model.dart';

enum ExerciseType { choice, build, match }

class ExerciseModel {
  const ExerciseModel.choice({
    required this.question,
    required this.options,
    required this.answerIndex,
  }) : type = ExerciseType.choice,
       prompt = '',
       bank = const [],
       answerWords = const [],
       pairs = const [];

  const ExerciseModel.build({
    required this.question,
    required this.prompt,
    required this.bank,
    required this.answerWords,
  }) : type = ExerciseType.build,
       options = const [],
       answerIndex = -1,
       pairs = const [];

  const ExerciseModel.match({required this.question, required this.pairs})
    : type = ExerciseType.match,
      options = const [],
      answerIndex = -1,
      prompt = '',
      bank = const [],
      answerWords = const [];

  final ExerciseType type;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String prompt;
  final List<String> bank;
  final List<String> answerWords;
  final List<List<String>> pairs;

  factory ExerciseModel.fromQuestion(QuestionModel question) {
    if (question.tipoPregunta == 'build') {
      return ExerciseModel.build(
        question: 'Traduce esta oracion',
        prompt: question.nombre,
        bank: (question.config['bank'] as List<dynamic>? ?? [])
            .map((item) => '$item')
            .toList(),
        answerWords: (question.config['answer'] as List<dynamic>? ?? [])
            .map((item) => '$item')
            .toList(),
      );
    }

    if (question.tipoPregunta == 'match') {
      final pairsJson = question.config['pairs'] as List<dynamic>? ?? [];
      return ExerciseModel.match(
        question: 'Empareja los pares',
        pairs: pairsJson.map((pair) {
          final list = pair as List<dynamic>;
          return ['${list[0]}', '${list[1]}'];
        }).toList(),
      );
    }

    final answerIndex = question.respuestas.indexWhere(
      (answer) => answer.esCorrecta,
    );
    return ExerciseModel.choice(
      question: question.nombre,
      options: question.respuestas.map((answer) => answer.nombre).toList(),
      answerIndex: answerIndex < 0 ? 0 : answerIndex,
    );
  }
}
