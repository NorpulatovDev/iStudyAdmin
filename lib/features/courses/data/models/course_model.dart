// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

import 'package:istudyadmin/features/groups/data/models/group_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class CourseModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double price; // BigDecimal from backend
  final int? durationMonths;
  final int branchId;
  final String branchName;
  final DateTime createdAt;
  final List<GroupModel>? groups;

  const CourseModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.durationMonths,
    required this.branchId,
    required this.branchName,
    required this.createdAt,
    this.groups,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        durationMonths,
        branchId,
        branchName,
        createdAt,
        groups,
      ];
}
