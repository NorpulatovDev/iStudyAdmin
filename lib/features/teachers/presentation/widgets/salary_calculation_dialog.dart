// lib/features/teachers/presentation/widgets/salary_calculation_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';

class SalaryCalculationDialog extends StatefulWidget {
  final TeacherModel teacher;
  final Function(int year, int month) onCalculate;

  const SalaryCalculationDialog({
    super.key,
    required this.teacher,
    required this.onCalculate,
  });

  @override
  State<SalaryCalculationDialog> createState() => _SalaryCalculationDialogState();
}

class _SalaryCalculationDialogState extends State<SalaryCalculationDialog> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  bool isCalculating = false;
  Map<String, dynamic>? calculationResult;

  final List<String> monthNames = [
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
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor,
                    AppTheme.successColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Calculate Salary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.teacher.fullName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                    // Teacher Summary
                    _buildTeacherSummary(),
                    
                    const SizedBox(height: 20),
                    
                    // Date Selection
                    _buildDateSelection(),
                    
                    const SizedBox(height: 20),
                    
                    // Calculation Result
                    if (calculationResult != null) ...[
                      _buildCalculationResult(),
                      const SizedBox(height: 20),
                    ],
                    
                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Teacher Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Salary Type',
                  widget.teacher.salaryTypeDisplayName,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Branch',
                  widget.teacher.branchName,
                ),
              ),
            ],
          ),
          
          if (widget.teacher.salaryType == 'FIXED' || widget.teacher.salaryType == 'MIXED') ...[
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Base Salary',
              '\$${widget.teacher.baseSalary.toStringAsFixed(2)}',
            ),
          ],
          
          if (widget.teacher.salaryType == 'PERCENTAGE' || widget.teacher.salaryType == 'MIXED') ...[
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Payment Percentage',
              '${widget.teacher.paymentPercentage.toStringAsFixed(1)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Select Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // Year Selection
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value!;
                            calculationResult = null; // Reset result
                          });
                        },
                        items: List.generate(5, (index) {
                          int year = DateTime.now().year - index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                      ),
                    ),
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
                  Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value!;
                            calculationResult = null; // Reset result
                          });
                        },
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(monthNames[index]),
                          );
                        }),
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

  Widget _buildCalculationResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Calculation Result',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Mock calculation results - replace with actual API data
          _buildResultRow('Base Salary', '\$1,200.00'),
          _buildResultRow('Payment Based', '\$450.00'),
          _buildResultRow('Total Students', '15'),
          _buildResultRow('Student Payments', '\$4,500.00'),
          
          const Divider(height: 24),
          
          _buildResultRow(
            'Total Salary',
            '\$1,650.00',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.successColor : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? AppTheme.successColor : const Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Calculate Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isCalculating ? null : _handleCalculate,
            icon: isCalculating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.calculate),
            label: Text(isCalculating ? 'Calculating...' : 'Calculate Salary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Mark as Paid Button (show only if calculation exists)
        if (calculationResult != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleMarkAsPaid,
              icon: const Icon(Icons.payment),
              label: const Text('Mark as Paid'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleCalculate() async {
    setState(() {
      isCalculating = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock result - replace with actual API call
    setState(() {
      isCalculating = false;
      calculationResult = {
        'baseSalary': 1200.00,
        'paymentBased': 450.00,
        'totalSalary': 1650.00,
        'totalStudents': 15,
        'studentPayments': 4500.00,
      };
    });

    // Call the callback
    widget.onCalculate(selectedYear, selectedMonth);
  }

  void _handleMarkAsPaid() {
    // Handle marking salary as paid
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark salary as paid for ${widget.teacher.fullName} for ${monthNames[selectedMonth - 1]} $selectedYear?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirm dialog
              Navigator.pop(context); // Close salary dialog
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Salary marked as paid for ${widget.teacher.fullName}',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}