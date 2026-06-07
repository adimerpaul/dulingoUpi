import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/exercise_model.dart';
import '../../models/section_model.dart';
import '../../repositories/learning_repository.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/lesson_view_model.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/lumo_button.dart';

class LessonView extends StatefulWidget {
  const LessonView({
    super.key,
    required this.repository,
    required this.section,
    required this.detail,
    required this.home,
  });

  final LearningRepository repository;
  final SectionModel section;
  final SectionDetailModel detail;
  final HomeViewModel home;

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView> {
  late final LessonViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = LessonViewModel(
      widget.repository,
      section: widget.section,
      detail: widget.detail,
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([vm, widget.home]),
      builder: (context, _) {
        if (vm.completed) {
          return _CompleteView(
            onContinue: () => Navigator.of(context).pop(true),
          );
        }

        if (vm.loading) return const Scaffold(body: LoadingView());
        if (vm.error != null) {
          return Scaffold(
            body: Center(child: Text(vm.error!, textAlign: TextAlign.center)),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(vm: vm, hearts: widget.home.hearts),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: _ExerciseBody(vm: vm),
                      ),
                    ),
                  ),
                ),
                _Footer(vm: vm, home: widget.home),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.vm, required this.hearts});

  final LessonViewModel vm;
  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close, color: AppColors.muted2, size: 30),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: vm.progress,
                minHeight: 16,
                backgroundColor: AppColors.panel2,
                color: AppColors.amber,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.favorite, color: AppColors.heart),
          const SizedBox(width: 5),
          Text(
            '$hearts',
            style: const TextStyle(
              color: AppColors.heart,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBody extends StatelessWidget {
  const _ExerciseBody({required this.vm});

  final LessonViewModel vm;

  @override
  Widget build(BuildContext context) {
    final exercise = vm.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.question,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 26),
        switch (exercise.type) {
          ExerciseType.choice => _ChoiceExercise(vm: vm),
          ExerciseType.build => _BuildExercise(vm: vm),
          ExerciseType.match => _MatchExercise(vm: vm),
        },
      ],
    );
  }
}

class _ChoiceExercise extends StatelessWidget {
  const _ChoiceExercise({required this.vm});

  final LessonViewModel vm;

  @override
  Widget build(BuildContext context) {
    final exercise = vm.current;
    return Column(
      children: List.generate(exercise.options.length, (index) {
        final selected = vm.selectedChoice == index;
        final correct = vm.checked && index == exercise.answerIndex;
        final wrong = vm.checked && selected && !correct;
        final color = correct
            ? AppColors.soft(AppColors.green)
            : wrong
            ? AppColors.soft(AppColors.red)
            : selected
            ? AppColors.soft(AppColors.primary)
            : AppColors.panel;
        final border = correct
            ? AppColors.green
            : wrong
            ? AppColors.red
            : selected
            ? AppColors.primary
            : AppColors.border;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionTile(
            label: exercise.options[index],
            prefix: '${index + 1}',
            color: color,
            border: border,
            onTap: () => vm.selectChoice(index),
          ),
        );
      }),
    );
  }
}

class _BuildExercise extends StatelessWidget {
  const _BuildExercise({required this.vm});

  final LessonViewModel vm;

  @override
  Widget build(BuildContext context) {
    final exercise = vm.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Prompt(text: exercise.prompt),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 2),
            ),
          ),
          child: Wrap(
            spacing: 9,
            runSpacing: 9,
            children: List.generate(vm.placedWordIndexes.length, (position) {
              final bankIndex = vm.placedWordIndexes[position];
              return _WordChip(
                label: exercise.bank[bankIndex],
                onTap: () => vm.removeWordAt(position),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(exercise.bank.length, (index) {
            final used = vm.placedWordIndexes.contains(index);
            return Opacity(
              opacity: used ? .25 : 1,
              child: _WordChip(
                label: used ? '       ' : exercise.bank[index],
                onTap: used ? null : () => vm.addWord(index),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MatchExercise extends StatelessWidget {
  const _MatchExercise({required this.vm});

  final LessonViewModel vm;

  @override
  Widget build(BuildContext context) {
    final pairs = vm.current.pairs;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: List.generate(pairs.length, (index) {
              return _MatchTile(
                label: pairs[index][0],
                selected: vm.selectedLeft == index,
                done: vm.matchedPairs.contains(index),
                onTap: () => vm.tapMatch('L', index),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: List.generate(pairs.length, (index) {
              return _MatchTile(
                label: pairs[index][1],
                selected: vm.selectedRight == index,
                done: vm.matchedPairs.contains(index),
                onTap: () => vm.tapMatch('R', index),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Icon(Icons.record_voice_over, color: AppColors.primary, size: 60),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.panel,
              border: Border.all(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.prefix,
    required this.color,
    required this.border,
    required this.onTap,
  });

  final String label;
  final String prefix;
  final Color color;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border(
            left: BorderSide(color: border, width: 2),
            top: BorderSide(color: border, width: 2),
            right: BorderSide(color: border, width: 2),
            bottom: BorderSide(color: border, width: 4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderStrong, width: 2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                prefix,
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(13),
          border: const Border(
            left: BorderSide(color: AppColors.border, width: 2),
            top: BorderSide(color: AppColors.border, width: 2),
            right: BorderSide(color: AppColors.border, width: 2),
            bottom: BorderSide(color: AppColors.border, width: 4),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.selected,
    required this.done,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: done ? 0 : 1,
      duration: const Duration(milliseconds: 220),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OptionTile(
          label: label,
          prefix: '',
          color: selected ? AppColors.soft(AppColors.primary) : AppColors.panel,
          border: selected ? AppColors.primary : AppColors.border,
          onTap: done ? () {} : onTap,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.vm, required this.home});

  final LessonViewModel vm;
  final HomeViewModel home;

  @override
  Widget build(BuildContext context) {
    final canCheck = switch (vm.current.type) {
      ExerciseType.choice => vm.selectedChoice != null,
      ExerciseType.build => vm.placedWordIndexes.isNotEmpty,
      ExerciseType.match => vm.checked,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: vm.checked
            ? AppColors.soft(vm.isCorrect ? AppColors.green : AppColors.red)
            : AppColors.bg,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (vm.checked)
              Expanded(
                child: Text(
                  vm.isCorrect ? 'Correcto!' : 'Respuesta correcta:',
                  style: TextStyle(
                    color: vm.isCorrect ? AppColors.green : AppColors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              Expanded(
                child: LumoButton(
                  label: vm.current.type == ExerciseType.match
                      ? 'Saltar'
                      : 'No se',
                  outline: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: LumoButton(
                label: vm.checked ? 'Continuar' : 'Comprobar',
                color: vm.checked
                    ? (vm.isCorrect ? AppColors.green : AppColors.red)
                    : AppColors.primary,
                borderColor: vm.checked
                    ? (vm.isCorrect
                          ? const Color(0xFF4AA823)
                          : const Color(0xFFD63B3B))
                    : AppColors.primaryDark,
                onPressed: vm.checked
                    ? vm.next
                    : canCheck
                    ? () {
                        final ok = vm.check();
                        if (!ok) home.loseHeart();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: AppColors.amber,
                size: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'Leccion completada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Ganaste XP y gemas por completar el nodo.'),
              const SizedBox(height: 34),
              LumoButton(label: 'Continuar', onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
