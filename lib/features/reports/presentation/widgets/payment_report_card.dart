import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/report_model.dart';

class PaymentReportCard extends StatelessWidget {
  final PaymentReportModel report;

  const PaymentReportCard({super.key, required this.report});

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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Payments Received',
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
                  NumberFormat('#,##0.0').format(report.totalPayments),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Payment insights
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
                    backgroundColor: Colors.green,
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
                'Payment Insights',
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
          
          if (report.totalPayments > 0) ...[
            const SizedBox(height: 12),
            _buildPerformanceIndicator(),
          ],
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

  Widget _buildPerformanceIndicator() {
    // Simple performance indicator based on amount
    final isGoodPerformance = report.totalPayments > 1000;
    final performanceColor = isGoodPerformance ? Colors.green : Colors.orange;
    final performanceText = isGoodPerformance ? 'Strong Performance' : 'Moderate Performance';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: performanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: performanceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isGoodPerformance ? Icons.trending_up : Icons.trending_flat,
            color: performanceColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performanceText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: performanceColor,
                  ),
                ),
                Text(
                  isGoodPerformance 
                      ? 'Payment collection is performing well'
                      : 'Consider reviewing payment processes',
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
        return 'Daily payment report';
      case 'monthly':
        if (report.year != null && report.month != null) {
          final date = DateTime(report.year!, report.month!);
          return 'Monthly report for ${DateFormat('MMMM yyyy').format(date)}';
        }
        return 'Monthly payment report';
      case 'range':
        if (report.startDate != null && report.endDate != null) {
          final start = DateTime.parse(report.startDate!);
          final end = DateTime.parse(report.endDate!);
          return 'From ${DateFormat('MMM dd').format(start)} to ${DateFormat('MMM dd, yyyy').format(end)}';
        }
        return 'Date range payment report';
      default:
        return 'Payment report';
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
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.green),
                  const SizedBox(width: 12),
                  const Text(
                    'Payment Report Details',
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
              _buildDetailRow('Total Payments', NumberFormat('#,##0.0').format(report.totalPayments)),
              
              if (report.year != null)
                _buildDetailRow('Year', '${report.year}'),
              if (report.month != null)
                _buildDetailRow('Month', '${report.month}'),
              if (report.date != null)
                _buildDetailRow('Date', report.date!),
              if (report.startDate != null)
                _buildDetailRow('Start Date', report.startDate!),
              if (report.endDate != null)
                _buildDetailRow('End Date', report.endDate!),
                
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
            width: 120,
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
        content: Text('Payment report export functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}