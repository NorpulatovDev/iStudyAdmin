import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/report_bloc.dart';

class ReportFilterDialog extends StatefulWidget {
  final String reportType;
  final int branchId;
  final Function(Map<String, dynamic>) onGenerate;

  const ReportFilterDialog({
    super.key,
    required this.reportType,
    required this.branchId,
    required this.onGenerate,
  });

  @override
  State<ReportFilterDialog> createState() => _ReportFilterDialogState();
}

class _ReportFilterDialogState extends State<ReportFilterDialog> {
  String _selectedPeriodType = 'monthly';
  DateTime _selectedDate = DateTime.now();
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Generate ${_getReportTypeName()} Report',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Type Selection
                    const Text(
                      'Select Period Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildPeriodTypeOptions(),
                    
                    const SizedBox(height: 20),
                    
                    // Date Selection based on period type
                    if (_selectedPeriodType == 'daily')
                      _buildDailySelection()
                    else if (_selectedPeriodType == 'monthly')
                      _buildMonthlySelection()
                    else if (_selectedPeriodType == 'range')
                      _buildRangeSelection(),
                    
                    const SizedBox(height: 24),
                    
                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleGenerate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Generate Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTypeOptions() {
    final options = _getPeriodTypeOptions();
    
    return Column(
      children: options.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            title: Text(option['label'] as String),
            subtitle: Text(
              option['description'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            value: option['value'] as String,
            groupValue: _selectedPeriodType,
            onChanged: (value) {
              setState(() {
                _selectedPeriodType = value!;
                // Reset dates when changing period type
                _startDate = null;
                _endDate = null;
              });
            },
            activeColor: AppTheme.primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySelection() {
    return Row(
      children: [
        // Year Selection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Month Selection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Month',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(_monthNames[index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            // Start Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Date',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 12,
                              color: _startDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // End Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Date',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 12,
                              color: _endDate != null
                                  ? Colors.black
                                  : Colors.grey[600],
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
        ),
      ],
    );
  }

  List<Map<String, String>> _getPeriodTypeOptions() {
    switch (widget.reportType) {
      case 'payment':
        return [
          {
            'value': 'daily',
            'label': 'Daily Report',
            'description': 'Payments for a specific day',
          },
          {
            'value': 'monthly',
            'label': 'Monthly Report',
            'description': 'Complete monthly payment summary',
          },
          {
            'value': 'range',
            'label': 'Date Range',
            'description': 'Custom date range payments',
          },
        ];
      case 'expense':
        return [
          {
            'value': 'daily',
            'label': 'Daily Expenses',
            'description': 'Expenses for a specific day',
          },
          {
            'value': 'monthly',
            'label': 'Monthly Expenses',
            'description': 'Complete monthly expense summary',
          },
          {
            'value': 'range',
            'label': 'Date Range',
            'description': 'Custom date range expenses',
          },
        ];
      case 'salary':
        return [
          {
            'value': 'monthly',
            'label': 'Monthly Salaries',
            'description': 'Teacher salary calculations for a month',
          },
          {
            'value': 'range',
            'label': 'Salary Range',
            'description': 'Multi-month salary summary',
          },
        ];
      case 'financial':
      default:
        return [
          {
            'value': 'monthly',
            'label': 'Monthly Summary',
            'description': 'Complete financial overview for a month',
          },
          {
            'value': 'range',
            'label': 'Date Range',
            'description': 'Financial summary for custom period',
          },
        ];
    }
  }

  String _getReportTypeName() {
    switch (widget.reportType) {
      case 'payment':
        return 'Payment';
      case 'expense':
        return 'Expense';
      case 'salary':
        return 'Salary';
      case 'financial':
        return 'Financial';
      default:
        return 'Report';
    }
  }

  void _handleGenerate() {
    final filterData = <String, dynamic>{};

    switch (_selectedPeriodType) {
      case 'daily':
        if (widget.reportType == 'payment') {
          filterData['reportType'] = PaymentReportType.daily;
        } else if (widget.reportType == 'expense') {
          filterData['reportType'] = ExpenseReportType.daily;
        }
        filterData['date'] = _selectedDate;
        break;
        
      case 'monthly':
        if (widget.reportType == 'payment') {
          filterData['reportType'] = PaymentReportType.monthly;
        } else if (widget.reportType == 'expense') {
          filterData['reportType'] = ExpenseReportType.monthly;
        } else if (widget.reportType == 'salary') {
          filterData['reportType'] = SalaryReportType.monthly;
        }
        filterData['year'] = _selectedYear;
        filterData['month'] = _selectedMonth;
        break;
        
      case 'range':
        if (_startDate == null || _endDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select both start and end dates'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
        
        if (_startDate!.isAfter(_endDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Start date must be before end date'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }
        
        if (widget.reportType == 'payment') {
          filterData['reportType'] = PaymentReportType.range;
        } else if (widget.reportType == 'expense') {
          filterData['reportType'] = ExpenseReportType.range;
        } else if (widget.reportType == 'salary') {
          filterData['reportType'] = SalaryReportType.range;
          filterData['startYear'] = _startDate!.year;
          filterData['startMonth'] = _startDate!.month;
          filterData['endYear'] = _endDate!.year;
          filterData['endMonth'] = _endDate!.month;
        }
        
        if (widget.reportType != 'salary') {
          filterData['startDate'] = _startDate;
          filterData['endDate'] = _endDate;
        }
        break;
    }

    widget.onGenerate(filterData);
    Navigator.of(context).pop();
  }
}