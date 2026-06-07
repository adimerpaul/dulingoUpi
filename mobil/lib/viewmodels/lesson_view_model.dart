import 'package:flutter/foundation.dart';

import '../models/exercise_model.dart';
import '../models/section_model.dart';
import '../repositories/learning_repository.dart';

class LessonViewModel extends ChangeNotifier {
  LessonViewModel(
    this._repository, {
    required this.section,
    required this.detail,
  });

  final LearningRepository _repository;
  final SectionModel section;
  final SectionDetailModel detail;

  List<ExerciseModel> exercises = [];
  int index = 0;
  int? selectedChoice;
  bool checked = false;
  bool isCorrect = false;
  bool completed = false;
  bool loading = true;
  String? error;
  List<int> placedWordIndexes = [];
  int? selectedLeft;
  int? selectedRight;
  Set<int> matchedPairs = {};

  ExerciseModel get current => exercises[index];

  double get progress {
    if (exercises.isEmpty) return 0;
    return (index + (checked ? 1 : 0)) / exercises.length;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      exercises = await _repository.getExercises(
        sectionId: section.id,
        detailId: detail.id,
      );
      if (exercises.isEmpty) {
        error = 'No hay preguntas en esta leccion';
      }
    } catch (err) {
      error = '$err';
    }
    loading = false;
    notifyListeners();
  }

  void selectChoice(int optionIndex) {
    if (checked) return;
    selectedChoice = optionIndex;
    notifyListeners();
  }

  void addWord(int bankIndex) {
    if (checked || placedWordIndexes.contains(bankIndex)) return;
    placedWordIndexes.add(bankIndex);
    notifyListeners();
  }

  void removeWordAt(int position) {
    if (checked) return;
    placedWordIndexes.removeAt(position);
    notifyListeners();
  }

  void tapMatch(String side, int pairIndex) {
    if (checked || matchedPairs.contains(pairIndex)) return;
    if (side == 'L') {
      selectedLeft = selectedLeft == pairIndex ? null : pairIndex;
    } else {
      selectedRight = selectedRight == pairIndex ? null : pairIndex;
    }

    if (selectedLeft != null && selectedRight != null) {
      if (selectedLeft == selectedRight) {
        matchedPairs.add(selectedLeft!);
        selectedLeft = null;
        selectedRight = null;
        if (matchedPairs.length == current.pairs.length) {
          checked = true;
          isCorrect = true;
        }
      } else {
        selectedLeft = null;
        selectedRight = null;
      }
    }
    notifyListeners();
  }

  bool check() {
    final ok = switch (current.type) {
      ExerciseType.choice => selectedChoice == current.answerIndex,
      ExerciseType.build =>
        _selectedWords().join(' ') == current.answerWords.join(' '),
      ExerciseType.match => matchedPairs.length == current.pairs.length,
    };
    checked = true;
    isCorrect = ok;
    notifyListeners();
    return ok;
  }

  Future<void> next() async {
    if (index + 1 >= exercises.length) {
      await _repository.markComplete(detail.id);
      completed = true;
      notifyListeners();
      return;
    }

    index++;
    selectedChoice = null;
    checked = false;
    isCorrect = false;
    placedWordIndexes = [];
    selectedLeft = null;
    selectedRight = null;
    matchedPairs = {};
    notifyListeners();
  }

  List<String> _selectedWords() {
    return placedWordIndexes.map((i) => current.bank[i]).toList();
  }
}
