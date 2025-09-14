part of 'teacher_bloc.dart';

sealed class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class TeacherLoadByBranchRequested extends TeacherEvent {
  final int? branchId;

  const TeacherLoadByBranchRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}

class TeacherSearchRequested extends TeacherEvent {
  final String query;
  final int branchId;

  const TeacherSearchRequested({
    required this.query,
    required this.branchId,
  });

  @override
  List<Object> get props => [query, branchId];
}

class TeacherFilterBySalaryTypeRequested extends TeacherEvent {
  final int branchId;
  final String salaryType;

  const TeacherFilterBySalaryTypeRequested({
    required this.branchId,
    required this.salaryType,
  });

  @override
  List<Object> get props => [branchId, salaryType];
}

class TeacherCreateRequested extends TeacherEvent {
  final String firstName;
  final String lastName;
  final int branchId;
  final String? phoneNumber;
  final double baseSalary;
  final double paymentPercentage;
  final SalaryType salaryType;

  const TeacherCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.branchId,
    this.phoneNumber,
    required this.baseSalary,
    required this.paymentPercentage,
    required this.salaryType,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        branchId,
        phoneNumber,
        baseSalary,
        paymentPercentage,
        salaryType,
      ];
}

class TeacherUpdateRequested extends TeacherEvent {
  final int id;
  final String firstName;
  final String lastName;
  final int branchId;
  final String? phoneNumber;
  final double baseSalary;
  final double paymentPercentage;
  final SalaryType salaryType;

  const TeacherUpdateRequested({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.branchId,
    this.phoneNumber,
    required this.baseSalary,
    required this.paymentPercentage,
    required this.salaryType,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        branchId,
        phoneNumber,
        baseSalary,
        paymentPercentage,
        salaryType,
      ];
}

class TeacherDeleteRequested extends TeacherEvent {
  final int id;

  const TeacherDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class TeacherRefreshRequested extends TeacherEvent {
  final int? branchId;

  const TeacherRefreshRequested({this.branchId});

  @override
  List<Object?> get props => [branchId];
}
