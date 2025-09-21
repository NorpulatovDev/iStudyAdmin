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
    this.groupId,
    this.groupName,
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
class UnpaidStudentModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? parentPhoneNumber;
  final double remainingAmount;
  final String groupName;
  final int groupId;

  const UnpaidStudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.parentPhoneNumber,
    required this.remainingAmount,
    required this.groupName,
    required this.groupId,
  });

  factory UnpaidStudentModel.fromJson(Map<String, dynamic> json) =>
      _$UnpaidStudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnpaidStudentModelToJson(this);

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        parentPhoneNumber,
        remainingAmount,
        groupName,
        groupId,
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

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentRequestFromJson(json);

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

@JsonSerializable()
class UpdatePaymentRequest extends Equatable {
  final double amount;

  const UpdatePaymentRequest({required this.amount});

  factory UpdatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePaymentRequestToJson(this);

  @override
  List<Object?> get props => [amount];
}