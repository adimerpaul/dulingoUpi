import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/section_model.dart';
import '../../repositories/learning_repository.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/lumo_logo.dart';
import '../lesson/lesson_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.auth,
    required this.learningRepository,
  });

  final AuthViewModel auth;
  final LearningRepository learningRepository;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel(widget.learningRepository)..load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        if (vm.loading && vm.sections.isEmpty) return const LoadingView();
        if (vm.error != null && vm.sections.isEmpty) {
          return _ErrorView(error: vm.error!, onRetry: vm.load);
        }

        final wide = MediaQuery.sizeOf(context).width >= 900;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide) _SideNav(auth: widget.auth, vm: vm),
                Expanded(
                  child: _MainPath(vm: vm, onStart: _openLesson),
                ),
                if (wide) _RightRail(vm: vm, auth: widget.auth),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  backgroundColor: AppColors.bg,
                  selectedIndex: vm.selectedNav,
                  onDestinationSelected: vm.setNav,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home),
                      label: 'Aprender',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.emoji_events),
                      label: 'Ligas',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openLesson(
    SectionModel section,
    SectionDetailModel detail,
  ) async {
    final completed = vm.completedCount;
    final index = section.detalles.indexWhere((item) => item.id == detail.id);
    if (index != completed) return;

    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonView(
          repository: widget.learningRepository,
          section: section,
          detail: detail,
          home: vm,
        ),
      ),
    );
    if (done == true) await vm.refreshAfterLesson();
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.auth, required this.vm});

  final AuthViewModel auth;
  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: LumoLogo(size: 36),
          ),
          _NavButton(
            icon: Icons.home,
            label: 'Aprender',
            selected: true,
            onTap: () {},
          ),
          _NavButton(
            icon: Icons.emoji_events,
            label: 'Ligas',
            selected: false,
            onTap: () {},
          ),
          _NavButton(
            icon: Icons.person,
            label: 'Perfil',
            selected: false,
            onTap: () {},
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.logout,
            label: 'Salir',
            selected: false,
            onTap: auth.logout,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.muted,
        ),
        title: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        tileColor: selected ? AppColors.soft(AppColors.primary) : null,
      ),
    );
  }
}

class _MainPath extends StatelessWidget {
  const _MainPath({required this.vm, required this.onStart});

  final HomeViewModel vm;
  final void Function(SectionModel section, SectionDetailModel detail) onStart;

  @override
  Widget build(BuildContext context) {
    final section = vm.currentSection;
    if (section == null) {
      return const Center(child: Text('No hay secciones disponibles'));
    }

    final completed = vm.completedCount;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _UnitBanner(section: section),
              const SizedBox(height: 34),
              ...List.generate(section.detalles.length, (index) {
                final detail = section.detalles[index];
                final status = index < completed
                    ? _NodeStatus.done
                    : index == completed
                    ? _NodeStatus.active
                    : _NodeStatus.locked;
                return _PathNode(
                  detail: detail,
                  status: status,
                  offset: _offsetFor(index),
                  onTap: () => onStart(section, detail),
                );
              }),
              const SizedBox(height: 18),
              const _DividerLabel(label: 'Proxima seccion'),
              const SizedBox(height: 18),
              const _LockedNode(),
            ]),
          ),
        ),
      ],
    );
  }

  double _offsetFor(int index) {
    const values = [0, -52, -80, -52, 0, 56, 88, 56, 0, -52];
    return values[index % values.length].toDouble();
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.section});

  final SectionModel section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(0, 5), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ETAPA 1, SECCION 1',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

enum _NodeStatus { done, active, locked }

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.detail,
    required this.status,
    required this.offset,
    required this.onTap,
  });

  final SectionDetailModel detail;
  final _NodeStatus status;
  final double offset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = status == _NodeStatus.active;
    return Transform.translate(
      offset: Offset(offset, 0),
      child: Column(
        children: [
          if (active) const _StartBubble(),
          GestureDetector(
            onTap: status == _NodeStatus.locked ? null : onTap,
            child: _NodeCircle(
              status: status,
              icon: status == _NodeStatus.done
                  ? Icons.check
                  : detail.tipo == 'review'
                  ? Icons.menu_book
                  : detail.tipo == 'chest'
                  ? Icons.card_giftcard
                  : detail.tipo == 'crown'
                  ? Icons.workspace_premium
                  : Icons.star,
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _NodeCircle extends StatelessWidget {
  const _NodeCircle({required this.status, required this.icon});

  final _NodeStatus status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _NodeStatus.done => AppColors.primary,
      _NodeStatus.active => AppColors.amber,
      _NodeStatus.locked => const Color(0xFF283039),
    };
    final shadow = switch (status) {
      _NodeStatus.done => AppColors.primaryDark,
      _NodeStatus.active => AppColors.amberDark,
      _NodeStatus.locked => const Color(0xFF1B222A),
    };
    return Container(
      width: 74,
      height: 66,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: shadow, offset: const Offset(0, 7), blurRadius: 0),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }
}

class _StartBubble extends StatelessWidget {
  const _StartBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'EMPIEZA',
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 2)),
      ],
    );
  }
}

class _LockedNode extends StatelessWidget {
  const _LockedNode();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _NodeCircle(status: _NodeStatus.locked, icon: Icons.star),
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail({required this.vm, required this.auth});

  final HomeViewModel vm;
  final AuthViewModel auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Stat(
                icon: Icons.diamond,
                value: '${vm.gems}',
                color: AppColors.gem,
              ),
              const SizedBox(width: 18),
              _Stat(
                icon: Icons.favorite,
                value: '${vm.hearts}',
                color: AppColors.heart,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, ${auth.user?.nombre ?? 'Estudiante'}'),
                const SizedBox(height: 16),
                const Text(
                  'Desafios del dia',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                _ProgressTask(
                  label: 'Gana 10 XP',
                  progress: .4,
                  icon: Icons.local_fire_department,
                ),
                const SizedBox(height: 14),
                _ProgressTask(
                  label: 'Completa 1 leccion',
                  progress: vm.completedCount > 0 ? 1 : 0,
                  icon: Icons.diamond,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.border, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.color});

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ProgressTask extends StatelessWidget {
  const _ProgressTask({
    required this.label,
    required this.progress,
    required this.icon,
  });

  final String label;
  final double progress;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.panel3,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.amber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 13,
                  backgroundColor: AppColors.panel3,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}
