// lib/features/reports/presentation/widgets/report_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getReportIcon(),
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getReportTitle(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Period: ${report.formattedPeriod}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Report Data
              if (report.totalPayments != null)
                _buildDataRow(
                  'Total Payments',
                  '\$${NumberFormat('#,##0.00').format(report.totalPayments)}',
                  AppTheme.successColor,
                ),
              
              if (report.totalExpenses != null)
                _buildDataRow(
                  'Total Expenses',
                  '\$${NumberFormat('#,##0.00').format(report.totalExpenses)}',
                  Colors.red,
                ),
              
              if (report.totalSalaries != null)
                _buildDataRow(
                  'Total Salaries',
                  '\$${NumberFormat('#,##0.00').format(report.totalSalaries)}',
                  Colors.orange,
                ),
              
              if (report.totalIncome != null)
                _buildDataRow(
                  'Total Income',
                  '\$${NumberFormat('#,##0.00').format(report.totalIncome)}',
                  AppTheme.primaryColor,
                ),
              
              // Net Profit (highlighted)
              if (report.netProfit != null) ...[
                const Divider(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (report.netProfit! >= 0 
                        ? AppTheme.successColor 
                        : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Profit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: report.netProfit! >= 0 
                              ? AppTheme.successColor 
                              : Colors.red,
                        ),
                      ),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(report.netProfit)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: report.netProfit! >= 0 
                              ? AppTheme.successColor 
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTitle() {
    if (report.isPaymentReport) {
      if (report.isDailyReport) return 'Daily Payment Report';
      if (report.isMonthlyReport) return 'Monthly Payment Report';
      if (report.isRangeReport) return 'Payment Range Report';
      return 'Payment Report';
    }
    if (report.isExpenseReport) {
      if (report.isDailyReport) return 'Daily Expense Report';
      if (report.isMonthlyReport) return 'Monthly Expense Report';
      if (report.isRangeReport) return 'Expense Range Report';
      return 'Expense Report';
    }
    if (report.isSalaryReport) {
      if (report.isMonthlyReport) return 'Monthly Salary Report';
      if (report.isRangeReport) return 'Salary Range Report';
      return 'Salary Report';
    }
    if (report.isFinancialSummary) {
      return 'Financial Summary';
    }
    return 'Report';
  }

  IconData _getReportIcon() {
    if (report.isPaymentReport) return Icons.payment;
    if (report.isExpenseReport) return Icons.money_off;
    if (report.isSalaryReport) return Icons.person;
    if (report.isFinancialSummary) return Icons.analytics;
    return Icons.assessment;
  }
}