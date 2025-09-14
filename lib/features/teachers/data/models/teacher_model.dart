// lib/features/teachers/data/models/teacher_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final double baseSalary;
  final double paymentPercentage;
  final String salaryType; // "FIXED", "PERCENTAGE", "MIXED"
  final int branchId;
  final String branchName;
  final DateTime createdAt;

  const TeacherModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    required this.baseSalary,
    required this.paymentPercentage,
    required this.salaryType,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);

  String get fullName => '$firstName $lastName';

  String get salaryTypeDisplayName {
    switch (salaryType) {
      case 'FIXED':
        return 'Fixed Salary';
      case 'PERCENTAGE':
        return 'Percentage Based';
      case 'MIXED':
        return 'Mixed (Fixed + Percentage)';
      default:
        return salaryType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        email,
        baseSalary,
        paymentPercentage,
        salaryType,
        branchId,
        branchName,
        createdAt,
      ];
}