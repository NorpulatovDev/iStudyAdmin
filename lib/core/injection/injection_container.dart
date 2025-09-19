// lib/core/injection/injection_container.dart
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/courses/data/repositories/course_repository.dart';
import '../../features/courses/presentation/bloc/course_bloc.dart';
import '../../features/groups/data/repositories/group_repository.dart';
import '../../features/groups/presentation/bloc/group_bloc.dart';
import '../../features/students/data/repositories/student_repository.dart';
import '../../features/students/presentation/bloc/student_bloc.dart';
import '../../features/teachers/data/repositories/teacher_repository.dart';
import '../../features/teachers/presentation/bloc/teacher_bloc.dart';
import '../../features/payments/data/repositories/payment_repository.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';
import '../../features/reports/data/repositories/report_repository.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core services
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepository(sl<ApiService>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepository(sl<ApiService>(), sl<StorageService>()),
  ); 

  // BLoCs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));
  sl.registerLazySingleton<CourseBloc>(() => CourseBloc(sl<CourseRepository>()));
  sl.registerLazySingleton<GroupBloc>(() => GroupBloc(sl<GroupRepository>()));
  sl.registerLazySingleton<StudentBloc>(() => StudentBloc(sl<StudentRepository>()));
  sl.registerLazySingleton<TeacherBloc>(() => TeacherBloc(sl<TeacherRepository>()));
  sl.registerLazySingleton<PaymentBloc>(() => PaymentBloc(sl<PaymentRepository>()));
  sl.registerLazySingleton<ReportBloc>(() => ReportBloc(sl<ReportRepository>()));
}