// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './core/injection/injection_container.dart';
import './features/auth/data/repositories/auth_repository.dart';
import './features/courses/data/repositories/course_repository.dart';
import './features/groups/data/repositories/group_repository.dart';
import './features/students/data/repositories/student_repository.dart';
import './core/theme/app_theme.dart';
import './features/auth/presentation/bloc/auth_bloc.dart';
import './features/courses/presentation/bloc/course_bloc.dart';
import './features/groups/presentation/bloc/group_bloc.dart';
import './features/students/presentation/bloc/student_bloc.dart';
import './features/auth/presentation/pages/login_page.dart';
import './features/main/presentation/pages/main_layout.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(sl<AuthRepository>())
            ..add(AuthCheckRequested()), // Check if user is already logged in
        ),
        BlocProvider(
          create: (context) => CourseBloc(sl<CourseRepository>()),
        ),
        BlocProvider(
          create: (context) => GroupBloc(sl<GroupRepository>()),
        ),
        BlocProvider(
          create: (context) => StudentBloc(sl<StudentRepository>()),
        ),
      ],
      child: MaterialApp(
        title: "iStudy Admin",
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Scaffold(
                backgroundColor: const Color(0xFFF5F7FA),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // App Title
                      const Text(
                        'iStudy Admin',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Loading Indicator
                      const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AuthAuthenticated) {
              return const MainLayout();
            }

            return const LoginPage();
          },
        ),
      ),
    );
  }
}