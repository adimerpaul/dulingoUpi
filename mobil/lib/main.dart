import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'repositories/learning_repository.dart';
import 'services/api_client.dart';
import 'services/session_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';
import 'widgets/loading_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionService();
  final api = ApiClient(session);
  final authRepository = AuthRepository(api, session);
  final learningRepository = LearningRepository(api);
  final auth = AuthViewModel(authRepository);

  runApp(LumoApp(auth: auth, learningRepository: learningRepository));
}

class LumoApp extends StatefulWidget {
  const LumoApp({
    super.key,
    required this.auth,
    required this.learningRepository,
  });

  final AuthViewModel auth;
  final LearningRepository learningRepository;

  @override
  State<LumoApp> createState() => _LumoAppState();
}

class _LumoAppState extends State<LumoApp> {
  @override
  void initState() {
    super.initState();
    widget.auth.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumo',
      theme: AppTheme.dark(),
      home: AnimatedBuilder(
        animation: widget.auth,
        builder: (context, _) {
          if (widget.auth.loading && widget.auth.user == null) {
            return const Scaffold(body: LoadingView());
          }

          if (widget.auth.isLoggedIn) {
            return HomeView(
              auth: widget.auth,
              learningRepository: widget.learningRepository,
            );
          }

          return LoginView(viewModel: widget.auth);
        },
      ),
    );
  }
}
