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
  final int? groupId;
  final String? groupName;
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
    required this.groupId,
    required this.groupName,
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
        groupId,
        groupName,
        amount,
        description,
        status,
        branchId,
        branchName,
        createdAt,
      ];
}

@JsonSerializable()
class CreatePaymentRequest extends Equatable {
  final int studentId;
  final int groupId;
  final double amount;
  final String? description;
  final int branchId;
  final int paymentYear;
  final int paymentMonth;

  const CreatePaymentRequest({
    required this.studentId,
    required this.groupId,
    required this.amount,
    this.description,
    required this.branchId,
    required this.paymentYear,
    required this.paymentMonth,
  });

  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);

  @override
  List<Object?> get props => [
        studentId,
        groupId,
        amount,
        description,
        branchId,
        paymentYear,
        paymentMonth,
      ];
}
