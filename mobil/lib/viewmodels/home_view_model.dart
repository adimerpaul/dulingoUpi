import 'package:flutter/foundation.dart';

import '../models/section_model.dart';
import '../repositories/learning_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final LearningRepository _repository;

  List<SectionModel> sections = [];
  bool loading = false;
  String? error;
  int hearts = 5;
  int gems = 183;
  int selectedNav = 0;

  SectionModel? get currentSection => sections.isEmpty ? null : sections.first;

  int get completedCount {
    return currentSection?.detalles
            .where((detail) => detail.realizado)
            .length ??
        0;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      sections = await _repository.getSections();
    } catch (err) {
      error = '$err';
    }
    loading = false;
    notifyListeners();
  }

  void setNav(int index) {
    selectedNav = index;
    notifyListeners();
  }

  Future<void> refreshAfterLesson() {
    gems += 5;
    return load();
  }

  void loseHeart() {
    hearts = hearts <= 0 ? 0 : hearts - 1;
    notifyListeners();
  }

  void refillHearts() {
    hearts = 5;
    notifyListeners();
  }
}
