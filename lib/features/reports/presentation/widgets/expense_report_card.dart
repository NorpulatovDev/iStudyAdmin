import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/report_model.dart';

class ExpenseReportCard extends StatelessWidget {
  final ExpenseReportModel report;

  const ExpenseReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPeriodDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Main amount display
          Center(
            child: Column(
              children: [
                Text(
                  '\$${NumberFormat('#,##0.00').format(report.totalExpenses)}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total Expenses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Expense breakdown
          _buildExpenseBreakdown(),
          
          const SizedBox(height: 24),
          
          // Insights section
          _buildInsightsSection(),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewDetailedBreakdown(context),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportReport(context),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    final regularPercentage = report.totalExpenses > 0 
        ? (report.regularExpenses / report.totalExpenses * 100) 
        : 0.0;
    final salaryPercentage = report.totalExpenses > 0 
        ? (report.salaryExpenses / report.totalExpenses * 100) 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildExpenseItem(
                  'Regular Expenses',
                  report.regularExpenses,
                  regularPercentage,
                  Colors.orange,
                  Icons.receipt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildExpenseItem(
                  'Salary Expenses',
                  report.salaryExpenses,
                  salaryPercentage,
                  Colors.purple,
                  Icons.people,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Visual breakdown bar
          if (report.totalExpenses > 0) _buildBreakdownBar(regularPercentage, salaryPercentage),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String label, double amount, double percentage, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${NumberFormat('#,##0.00').format(amount)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}% of total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownBar(double regularPercentage, double salaryPercentage) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.analytics, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Expense Distribution',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Row(
            children: [
              if (regularPercentage > 0)
                Expanded(
                  flex: regularPercentage.round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(4),
                        bottomLeft: const Radius.circular(4),
                        topRight: salaryPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                        bottomRight: salaryPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              if (salaryPercentage > 0)
                Expanded(
                  flex: salaryPercentage.round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.only(
                        topLeft: regularPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                        bottomLeft: regularPercentage == 0 ? const Radius.circular(4) : Radius.zero,
                        topRight: const Radius.circular(4),
                        bottomRight: const Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Expense Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  'Report Type',
                  _getReportTypeDisplay(),
                  Icons.category,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightItem(
                  'Branch ID',
                  '${report.branchId}',
                  Icons.location_on,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          _buildExpenseRatioInsight(),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRatioInsight() {
    final isDominantSalary = report.salaryExpenses > report.regularExpenses;
    final dominantCategory = isDominantSalary ? 'Salary' : 'Regular';
    final dominantColor = isDominantSalary ? Colors.purple : Colors.orange;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dominantColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dominantColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pie_chart,
            color: dominantColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dominantCategory expenses are dominant',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: dominantColor,
                  ),
                ),
                Text(
                  isDominantSalary 
                      ? 'Staff costs represent the largest expense category'
                      : 'Operational costs represent the largest expense category',
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
    );
  }

  String _getPeriodDescription() {
    switch (report.type.toLowerCase()) {
      case 'daily':
        if (report.date != null) {
          final date = DateTime.parse(report.date!);
          return 'Daily report for ${DateFormat('MMMM dd, yyyy').format(date)}';
        }
        return 'Daily expense report';
      case 'monthly':
        if (report.year != null && report.month != null) {
          final date = DateTime(report.year!, report.month!);
          return 'Monthly report for ${DateFormat('MMMM yyyy').format(date)}';
        }
        return 'Monthly expense report';
      case 'range':
        if (report.startDate != null && report.endDate != null) {
          final start = DateTime.parse(report.startDate!);
          final end = DateTime.parse(report.endDate!);
          return 'From ${DateFormat('MMM dd').format(start)} to ${DateFormat('MMM dd, yyyy').format(end)}';
        }
        return 'Date range expense report';
      default:
        return 'Expense report';
    }
  }

  String _getReportTypeDisplay() {
    switch (report.type.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'monthly':
        return 'Monthly';
      case 'range':
        return 'Date Range';
      default:
        return report.type;
    }
  }

  void _viewDetailedBreakdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text(
                    'Expense Report Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildDetailRow('Report Type', _getReportTypeDisplay()),
              _buildDetailRow('Period', _getPeriodDescription()),
              _buildDetailRow('Branch ID', '${report.branchId}'),
              const Divider(),
              _buildDetailRow('Regular Expenses', '\$${NumberFormat('#,##0.00').format(report.regularExpenses)}'),
              _buildDetailRow('Salary Expenses', '\$${NumberFormat('#,##0.00').format(report.salaryExpenses)}'),
              _buildDetailRow('Total Expenses', '\$${NumberFormat('#,##0.00').format(report.totalExpenses)}'),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense report export functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}