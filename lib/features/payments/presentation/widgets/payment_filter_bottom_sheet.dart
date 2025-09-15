// lib/features/payments/presentation/widgets/payment_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/payment_bloc.dart';

class PaymentFilterBottomSheet extends StatefulWidget {
  final int branchId;
  final Function(String filter, String filterType) onFilterApplied;

  const PaymentFilterBottomSheet({
    super.key,
    required this.branchId,
    required this.onFilterApplied,
  });

  @override
  State<PaymentFilterBottomSheet> createState() => _PaymentFilterBottomSheetState();
}

class _PaymentFilterBottomSheetState extends State<PaymentFilterBottomSheet> {
  String _selectedFilterType = 'recent';
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int _recentLimit = 20;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _applyFilter() {
    String filterDescription = '';
    
    switch (_selectedFilterType) {
      case 'recent':
        context.read<PaymentBloc>().add(
          PaymentLoadRecentRequested(
            branchId: widget.branchId,
            limit: _recentLimit,
          ),
        );
        filterDescription = 'Recent $_recentLimit';
        break;
        
      case 'month':
        context.read<PaymentBloc>().add(
          PaymentLoadByMonthRequested(
            branchId: widget.branchId,
            year: _selectedYear,
            month: _selectedMonth,
          ),
        );
        filterDescription = '${_months[_selectedMonth - 1]} $_selectedYear';
        break;
        
      case 'dateRange':
        if (_startDate != null && _endDate != null) {
          context.read<PaymentBloc>().add(
            PaymentLoadByDateRangeRequested(
              branchId: widget.branchId,
              startDate: _startDate!,
              endDate: _endDate!,
            ),
          );
          filterDescription = 'Custom Range';
        }
        break;
        
      case 'all':
      default:
        context.read<PaymentBloc>().add(
          PaymentLoadByBranchRequested(branchId: widget.branchId),
        );
        filterDescription = 'All Payments';
        break;
    }
    
    widget.onFilterApplied(filterDescription, _selectedFilterType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter Payments',
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
          ),
          
          // Filter Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Type Selection
                const Text(
                  'Filter Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                // All Payments
                _buildFilterOption(
                  'all',
                  'All Payments',
                  'Show all payment records',
                  Icons.list,
                ),
                
                // Recent Payments
                _buildFilterOption(
                  'recent',
                  'Recent Payments',
                  'Show most recent payments',
                  Icons.schedule,
                ),
                
                // By Month
                _buildFilterOption(
                  'month',
                  'By Month',
                  'Filter by specific month',
                  Icons.calendar_month,
                ),
                
                // Date Range
                _buildFilterOption(
                  'dateRange',
                  'Date Range',
                  'Custom date range',
                  Icons.date_range,
                ),
                
                const SizedBox(height: 20),
                
                // Filter-specific options
                if (_selectedFilterType == 'recent') ...[
                  const Text(
                    'Number of payments',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [10, 20, 50, 100].map((limit) => 
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$limit'),
                            selected: _recentLimit == limit,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _recentLimit = limit;
                                });
                              }
                            },
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _recentLimit == limit 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey[600],
                              fontWeight: _recentLimit == limit 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
                
                if (_selectedFilterType == 'month') ...[
                  Row(
                    children: [
                      // Year Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Year',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                      
                      // Month Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Month',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
                                  child: Text(_months[index]),
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
                  ),
                ],
                
                if (_selectedFilterType == 'dateRange') ...[
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      _startDate != null
                                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Select date',
                                      style: TextStyle(
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
                      
                      const SizedBox(width: 16),
                      
                      // End Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      _endDate != null
                                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                          : 'Select date',
                                      style: TextStyle(
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
                
                const SizedBox(height: 32),
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate date range if selected
                      if (_selectedFilterType == 'dateRange') {
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
                      }
                      _applyFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedFilterType == value;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilterType = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor 
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}