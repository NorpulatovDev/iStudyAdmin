import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/report_model.dart';

class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummaryModel summary;

  const FinancialSummaryCard({super.key, required this.summary});

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
                  color: _getProfitColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: _getProfitColor(),
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Summary',
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
          
          // Net Profit Display
          Center(
            child: Column(
              children: [
                Text(
                  summary.netProfit >= 0 ? 'Net Profit' : 'Net Loss',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${summary.netProfit >= 0 ? '' : '-'}\$${NumberFormat('#,##0.00').format(summary.netProfit.abs())}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getProfitColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getProfitColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    summary.netProfit >= 0 ? 'Profitable' : 'Loss Making',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getProfitColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Financial Overview Cards
          _buildFinancialOverview(),
          
          const SizedBox(height: 24),
          
          // Financial Metrics
          _buildFinancialMetrics(),
          
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
                    backgroundColor: _getProfitColor(),
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

  Widget _buildFinancialOverview() {
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
            'Financial Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          
          // Income and Expenses Row
          Row(
            children: [
              Expanded(
                child: _buildFinancialItem(
                  'Total Income',
                  summary.totalIncome,
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialItem(
                  'Total Expenses',
                  summary.totalExpenses,
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Expense Breakdown Row
          Row(
            children: [
              Expanded(
                child: _buildFinancialItem(
                  'Regular Expenses',
                  summary.regularExpenses,
                  Colors.orange,
                  Icons.receipt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialItem(
                  'Salary Payments',
                  summary.salaryPayments,
                  Colors.purple,
                  Icons.people,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, double amount, Color color, IconData icon) {
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
        ],
      ),
    );
  }

  Widget _buildFinancialMetrics() {
    final profitMargin = summary.totalIncome > 0 
        ? (summary.netProfit / summary.totalIncome * 100) 
        : 0.0;
    
    final expenseRatio = summary.totalIncome > 0 
        ? (summary.totalExpenses / summary.totalIncome * 100) 
        : 0.0;

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
                Icons.analytics,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Financial Metrics',
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
                child: _buildMetricItem(
                  'Profit Margin',
                  '${profitMargin.toStringAsFixed(1)}%',
                  _getProfitMarginColor(profitMargin),
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Expense Ratio',
                  '${expenseRatio.toStringAsFixed(1)}%',
                  _getExpenseRatioColor(expenseRatio),
                  Icons.pie_chart,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          _buildPerformanceInsight(profitMargin),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color, IconData icon) {
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInsight(double profitMargin) {
    String insightText;
    String detailText;
    Color insightColor;
    IconData insightIcon;

    if (profitMargin > 20) {
      insightText = 'Excellent Performance';
      detailText = 'High profit margin indicates strong financial health';
      insightColor = Colors.green;
      insightIcon = Icons.trending_up;
    } else if (profitMargin > 10) {
      insightText = 'Good Performance';
      detailText = 'Healthy profit margin with room for optimization';
      insightColor = Colors.blue;
      insightIcon = Icons.thumb_up;
    } else if (profitMargin > 0) {
      insightText = 'Moderate Performance';
      detailText = 'Low profit margin - consider cost optimization';
      insightColor = Colors.orange;
      insightIcon = Icons.warning;
    } else {
      insightText = 'Needs Attention';
      detailText = 'Operating at a loss - review expenses and revenue';
      insightColor = Colors.red;
      insightIcon = Icons.error;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: insightColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            insightIcon,
            color: insightColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insightText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: insightColor,
                  ),
                ),
                Text(
                  detailText,
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

  Color _getProfitColor() {
    return summary.netProfit >= 0 ? Colors.green : Colors.red;
  }

  Color _getProfitMarginColor(double margin) {
    if (margin > 15) return Colors.green;
    if (margin > 5) return Colors.orange;
    return Colors.red;
  }

  Color _getExpenseRatioColor(double ratio) {
    if (ratio < 70) return Colors.green;
    if (ratio < 90) return Colors.orange;
    return Colors.red;
  }

  String _getPeriodDescription() {
    switch (summary.type.toLowerCase()) {
      case 'monthly':
        if (summary.year != null && summary.month != null) {
          final date = DateTime(summary.year!, summary.month!);
          return 'Monthly summary for ${DateFormat('MMMM yyyy').format(date)}';
        }
        return 'Monthly financial summary';
      case 'range':
        if (summary.startDate != null && summary.endDate != null) {
          final start = DateTime.parse(summary.startDate!);
          final end = DateTime.parse(summary.endDate!);
          return 'From ${DateFormat('MMM dd').format(start)} to ${DateFormat('MMM dd, yyyy').format(end)}';
        }
        return 'Date range financial summary';
      default:
        return 'Financial summary';
    }
  }

  void _viewDetailedBreakdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: _getProfitColor()),
                  const SizedBox(width: 12),
                  const Text(
                    'Financial Summary Details',
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
              
              _buildDetailRow('Period', _getPeriodDescription()),
              _buildDetailRow('Branch ID', '${summary.branchId}'),
              const Divider(),
              
              // Income Section
              Text(
                'Income',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Total Income', '\$${NumberFormat('#,##0.00').format(summary.totalIncome)}'),
              
              const SizedBox(height: 16),
              
              // Expenses Section
              Text(
                'Expenses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Regular Expenses', '\$${NumberFormat('#,##0.00').format(summary.regularExpenses)}'),
              _buildDetailRow('Salary Payments', '\$${NumberFormat('#,##0.00').format(summary.salaryPayments)}'),
              _buildDetailRow('Total Expenses', '\$${NumberFormat('#,##0.00').format(summary.totalExpenses)}'),
              
              const Divider(),
              
              // Net Result
              _buildDetailRow(
                summary.netProfit >= 0 ? 'Net Profit' : 'Net Loss',
                '${summary.netProfit >= 0 ? '' : '-'}\$${NumberFormat('#,##0.00').format(summary.netProfit.abs())}',
                color: _getProfitColor(),
              ),
              
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
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
        content: Text('Financial summary export functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}