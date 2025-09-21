import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/report_bloc.dart';
import '../../data/models/report_model.dart';
import '../widgets/payment_report_card.dart';
import '../widgets/expense_report_card.dart';
import '../widgets/financial_summary_card.dart';

class ReportsPage extends StatefulWidget {
  final int? branchId;

  const ReportsPage({super.key, this.branchId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  ReportPeriod _selectedPeriod = ReportPeriod.monthly;
  ReportType _selectedReportType = ReportType.financial;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    switch (_selectedReportType) {
      case ReportType.payment:
        _loadPaymentReport();
        break;
      case ReportType.expense:
        _loadExpenseReport();
        break;
      case ReportType.financial:
        _loadFinancialSummary();
        break;
    }
  }

  void _loadPaymentReport() {
    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        context.read<ReportBloc>().add(LoadDailyPaymentReport(date: _selectedDate));
        break;
      case ReportPeriod.monthly:
        context.read<ReportBloc>().add(LoadMonthlyPaymentReport(
          year: _selectedDate.year,
          month: _selectedDate.month,
        ));
        break;
      case ReportPeriod.range:
        if (_startDate != null && _endDate != null) {
          context.read<ReportBloc>().add(LoadPaymentRangeReport(
            startDate: _startDate!,
            endDate: _endDate!,
          ));
        }
        break;
    }
  }

  void _loadExpenseReport() {
    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        context.read<ReportBloc>().add(LoadDailyExpenseReport(date: _selectedDate));
        break;
      case ReportPeriod.monthly:
        context.read<ReportBloc>().add(LoadMonthlyExpenseReport(
          year: _selectedDate.year,
          month: _selectedDate.month,
        ));
        break;
      case ReportPeriod.range:
        if (_startDate != null && _endDate != null) {
          context.read<ReportBloc>().add(LoadExpenseRangeReport(
            startDate: _startDate!,
            endDate: _endDate!,
          ));
        }
        break;
    }
  }

  void _loadFinancialSummary() {
    switch (_selectedPeriod) {
      case ReportPeriod.monthly:
        context.read<ReportBloc>().add(LoadFinancialSummary(
          year: _selectedDate.year,
          month: _selectedDate.month,
        ));
        break;
      case ReportPeriod.range:
        if (_startDate != null && _endDate != null) {
          context.read<ReportBloc>().add(LoadFinancialSummaryRange(
            startDate: _startDate!,
            endDate: _endDate!,
          ));
        }
        break;
      case ReportPeriod.daily:
        // Financial summary not available for daily, fallback to monthly
        _selectedPeriod = ReportPeriod.monthly;
        _loadFinancialSummary();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildControlsSection(),
          Expanded(
            child: BlocListener<ReportBloc, ReportState>(
              listener: (context, state) {
                if (state is ReportError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PaymentReportLoaded) {
                    return _buildPaymentReportView(state.report);
                  }

                  if (state is ExpenseReportLoaded) {
                    return _buildExpenseReportView(state.report);
                  }

                  if (state is FinancialSummaryLoaded) {
                    return _buildFinancialSummaryView(state.summary);
                  }

                  if (state is ReportError) {
                    return _buildErrorState(state.message);
                  }

                  return _buildInitialState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.analytics, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Financial Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exportReport,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Report type and period selectors
          Row(
            children: [
              // Report Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<ReportType>(
                        value: _selectedReportType,
                        isExpanded: true,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: ReportType.financial,
                            child: Row(
                              children: [
                                Icon(Icons.account_balance, size: 18),
                                SizedBox(width: 8),
                                Text('Financial Summary'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ReportType.payment,
                            child: Row(
                              children: [
                                Icon(Icons.payment, size: 18),
                                SizedBox(width: 8),
                                Text('Payment Report'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: ReportType.expense,
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, size: 18),
                                SizedBox(width: 8),
                                Text('Expense Report'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedReportType = value;
                              // Reset to monthly if financial summary and daily was selected
                              if (value == ReportType.financial && _selectedPeriod == ReportPeriod.daily) {
                                _selectedPeriod = ReportPeriod.monthly;
                              }
                            });
                            _loadReport();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Period Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<ReportPeriod>(
                        value: _selectedPeriod,
                        isExpanded: true,
                        underline: Container(),
                        items: [
                          if (_selectedReportType != ReportType.financial)
                            const DropdownMenuItem(
                              value: ReportPeriod.daily,
                              child: Row(
                                children: [
                                  Icon(Icons.today, size: 18),
                                  SizedBox(width: 8),
                                  Text('Daily'),
                                ],
                              ),
                            ),
                          const DropdownMenuItem(
                            value: ReportPeriod.monthly,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 18),
                                SizedBox(width: 8),
                                Text('Monthly'),
                              ],
                            ),
                          ),
                          const DropdownMenuItem(
                            value: ReportPeriod.range,
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: 18),
                                SizedBox(width: 8),
                                Text('Date Range'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                            _loadReport();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date selection
          _buildDateSelection(),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loadReport,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    if (_selectedPeriod == ReportPeriod.range) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _selectStartDate(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Select start date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _selectEndDate(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Select end date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Selected Date:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: InkWell(
              onTap: _selectDate,
              child: Text(
                _selectedPeriod == ReportPeriod.daily
                    ? DateFormat('MMM dd, yyyy').format(_selectedDate)
                    : DateFormat('MMMM yyyy').format(_selectedDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPaymentReportView(PaymentReportModel report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Report',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getReportPeriodText(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          PaymentReportCard(report: report),
        ],
      ),
    );
  }

  Widget _buildExpenseReportView(ExpenseReportModel report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Report',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getReportPeriodText(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ExpenseReportCard(report: report),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryView(FinancialSummaryModel summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getReportPeriodText(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          FinancialSummaryCard(summary: summary),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.analytics,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Generate Financial Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a report type and period to generate\nyour financial reports and analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.analytics),
              label: const Text('Generate Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Generate Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReportPeriodText() {
    switch (_selectedPeriod) {
      case ReportPeriod.daily:
        return 'For ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}';
      case ReportPeriod.monthly:
        return 'For ${DateFormat('MMMM yyyy').format(_selectedDate)}';
      case ReportPeriod.range:
        if (_startDate != null && _endDate != null) {
          return 'From ${DateFormat('MMM dd, yyyy').format(_startDate!)} to ${DateFormat('MMM dd, yyyy').format(_endDate!)}';
        }
        return 'Date range not selected';
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReport();
    }
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Auto-adjust end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked.add(const Duration(days: 30));
        }
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate?.add(const Duration(days: 30)) ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDate = DateTime.now();
      _startDate = null;
      _endDate = null;
      _selectedPeriod = ReportPeriod.monthly;
      _selectedReportType = ReportType.financial;
    });
    _loadReport();
  }

  void _exportReport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}