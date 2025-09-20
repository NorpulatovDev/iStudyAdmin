// lib/features/students/data/models/student_model.dart - Updated version
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
  final String? parentPhoneNumber; // Added this field
  final int branchId;
  final String branchName;
  final DateTime createdAt;
  final bool? hasPaidInMonth;
  final double? totalPaidInMonth;
  final double? remainingAmount;
  final String? paymentStatus; // "PAID", "PARTIAL", "UNPAID"
  final DateTime? lastPaymentDate;
  final List<int>? groupIds; // Added this field for group associations

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.parentPhoneNumber,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
    this.hasPaidInMonth,
    this.totalPaidInMonth,
    this.remainingAmount,
    this.paymentStatus,
    this.lastPaymentDate,
    this.groupIds,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  String get fullName => '$firstName $lastName';

  // Convert StudentModel to CreateStudentRequest for editing
  CreateStudentRequest toCreateRequest() {
    return CreateStudentRequest(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber ?? '',
      parentPhoneNumber: parentPhoneNumber ?? '',
      branchId: branchId,
      groupIds: groupIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        parentPhoneNumber,
        branchId,
        branchName,
        createdAt,
        hasPaidInMonth,
        totalPaidInMonth,
        remainingAmount,
        paymentStatus,
        lastPaymentDate,
        groupIds,
      ];
}

@JsonSerializable()
class CreateStudentRequest extends Equatable {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String parentPhoneNumber;
  final int branchId;
  final List<int>? groupIds; // nullable now

  const CreateStudentRequest({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.parentPhoneNumber,
    required this.branchId,
    this.groupIds, // optional
  });

  factory CreateStudentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStudentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateStudentRequestToJson(this);

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phoneNumber,
        parentPhoneNumber,
        branchId,
        groupIds,
      ];
}