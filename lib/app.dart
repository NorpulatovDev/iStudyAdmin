import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './core/injection/injection_container.dart';
import './features/auth/data/repositories/auth_repository.dart';
import './core/theme/app_theme.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';
import './features/auth/presentation/pages/login_page.dart';
import './features/home/presentation/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(sl<AuthRepository>()),
      child: MaterialApp(
        title: "I Study Admin",
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            if (state is AuthAuthenticated) {
              return const HomePage();
            }

            return const LoginPage();
          },
        ),
      ),
    );
  }
}
