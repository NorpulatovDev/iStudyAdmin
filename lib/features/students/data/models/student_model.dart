// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';


part 'student_model.g.dart';

@JsonSerializable()
class StudentModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final int branchId;
  final String branchName;
  final DateTime createdAt;
  final bool? hasPaidInMonth;
  final double? totalPaidInMonth;
  final double? remainingAmount;
  final String? paymentStatus; // "PAID", "PARTIAL", "UNPAID"
  final DateTime? lastPaymentDate;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
    this.hasPaidInMonth,
    this.totalPaidInMonth,
    this.remainingAmount,
    this.paymentStatus,
    this.lastPaymentDate,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        branchId,
        branchName,
        createdAt,
        hasPaidInMonth,
        totalPaidInMonth,
        remainingAmount,
        paymentStatus,
        lastPaymentDate,
      ];
}