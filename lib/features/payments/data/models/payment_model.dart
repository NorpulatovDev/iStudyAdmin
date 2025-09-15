// lib/features/payments/data/models/payment_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel extends Equatable {
  final int id;
  final int studentId;
  final String studentName;
  final int courseId;
  final String courseName;
  final double amount;
  final String? description;
  final String status;
  final int branchId;
  final String branchName;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.courseName,
    required this.amount,
    this.description,
    required this.status,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        courseId,
        courseName,
        amount,
        description,
        status,
        branchId,
        branchName,
        createdAt,
      ];
}