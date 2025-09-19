// lib/features/reports/presentation/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:istudyadmin/features/reports/data/models/report_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/report_bloc.dart';
import '../widgets/report_card.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int? _currentBranchId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentBranchId = authState.user.branchId;
      context.read<ReportBloc>().add(const DashboardStatsRequested());
    }
  }

  void _generateTodayReport() {
    if (_currentBranchId == null) return;
    context.read<ReportBloc>().add(
          PaymentReportRequested(
            branchId: _currentBranchId!,
            reportType: PaymentReportType.daily,
            date: DateTime.now(),
          ),
        );
  }

  void _generateMonthlyReport() {
    if (_currentBranchId == null) return;
    final now = DateTime.now();
    context.read<ReportBloc>().add(
          PaymentReportRequested(
            branchId: _currentBranchId!,
            reportType: PaymentReportType.monthly,
            year: now.year,
            month: now.month,
          ),
        );
  }

  void _generateCustomDateReport() {
    if (_currentBranchId == null || _startDate == null || _endDate == null)
      return;
    context.read<ReportBloc>().add(
          PaymentReportRequested(
            branchId: _currentBranchId!,
            reportType: PaymentReportType.range,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  void _generateFinancialSummary() {
    if (_currentBranchId == null) return;
    final now = DateTime.now();
    context.read<ReportBloc>().add(
          FinancialSummaryRequested(
            branchId: _currentBranchId!,
            year: now.year,
            month: now.month,
          ),
        );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Stats
            BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is DashboardStatsLoaded) {
                  return _buildDashboardStats(state.stats);
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Report Generation Section
            const Text(
              'Generate Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            // Report Buttons
            _buildReportButton(
              title: 'Today\'s Report',
              subtitle: 'View today\'s payments and activities',
              icon: Icons.today,
              color: AppTheme.primaryColor,
              onTap: _generateTodayReport,
            ),

            const SizedBox(height: 12),

            _buildReportButton(
              title: 'Monthly Report',
              subtitle: 'Current month\'s summary',
              icon: Icons.calendar_month,
              color: AppTheme.successColor,
              onTap: _generateMonthlyReport,
            ),

            const SizedBox(height: 12),

            _buildReportButton(
              title: 'Custom Date Range',
              subtitle: _startDate != null && _endDate != null
                  ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                  : 'Select custom date range',
              icon: Icons.date_range,
              color: Colors.orange,
              onTap: () async {
                await _selectDateRange();
                if (_startDate != null && _endDate != null) {
                  _generateCustomDateReport();
                }
              },
            ),

            const SizedBox(height: 12),

            _buildReportButton(
              title: 'Financial Summary',
              subtitle: 'Complete financial overview',
              icon: Icons.analytics,
              color: Colors.purple,
              onTap: _generateFinancialSummary,
            ),

            const SizedBox(height: 24),

            // Report Results
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppTheme.primaryColor),
                          SizedBox(height: 16),
                          Text('Generating report...'),
                        ],
                      ),
                    );
                  }

                  if (state is ReportLoaded) {
                    return ReportCard(report: state.report);
                  }

                  if (state is ReportError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializePage,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'Select a report type above to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats(DashboardStatsModel stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Students',
                    '${stats.totalStudents}',
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Teachers',
                    '${stats.totalTeachers}',
                    Icons.person,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Monthly Revenue',
                    '\$${NumberFormat('#,##0.00').format(stats.monthlyRevenue)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Revenue',
                    '\$${NumberFormat('#,##0.00').format(stats.totalRevenue)}',
                    Icons.account_balance,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
