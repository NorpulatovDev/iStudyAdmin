// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  type: json['type'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
  totalPayments: (json['totalPayments'] as num?)?.toDouble(),
  totalExpenses: (json['totalExpenses'] as num?)?.toDouble(),
  totalSalaries: (json['totalSalaries'] as num?)?.toDouble(),
  totalIncome: (json['totalIncome'] as num?)?.toDouble(),
  totalCosts: (json['totalCosts'] as num?)?.toDouble(),
  netProfit: (json['netProfit'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'branchId': instance.branchId,
      'date': instance.date?.toIso8601String(),
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'year': instance.year,
      'month': instance.month,
      'totalPayments': instance.totalPayments,
      'totalExpenses': instance.totalExpenses,
      'totalSalaries': instance.totalSalaries,
      'totalIncome': instance.totalIncome,
      'totalCosts': instance.totalCosts,
      'netProfit': instance.netProfit,
    };

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalBranches: (json['totalBranches'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      totalStudents: (json['totalStudents'] as num).toInt(),
      totalTeachers: (json['totalTeachers'] as num).toInt(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
  DashboardStatsModel instance,
) => <String, dynamic>{
  'totalBranches': instance.totalBranches,
  'totalUsers': instance.totalUsers,
  'totalStudents': instance.totalStudents,
  'totalTeachers': instance.totalTeachers,
  'monthlyRevenue': instance.monthlyRevenue,
  'totalRevenue': instance.totalRevenue,
};
