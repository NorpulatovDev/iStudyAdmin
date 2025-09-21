import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/salary_calculation_model.dart';

class SalaryCard extends StatelessWidget {
  final SalaryCalculationModel salaryCalculation;
  final VoidCallback? onTap;
  final VoidCallback? onPayment;
  final bool isSelected;

  const SalaryCard({
    super.key,
    required this.salaryCalculation,
    this.onTap,
    this.onPayment,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with teacher info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salaryCalculation.teacherName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              salaryCalculation.branchName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (salaryCalculation.remainingAmount > 0 && onPayment != null)
                    IconButton(
                      onPressed: onPayment,
                      icon: const Icon(Icons.payment),
                      tooltip: 'Make Payment',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
            
            // Salary details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSalaryItem(
                          'Total Salary',
                          '\$${NumberFormat('#,##0.00').format(salaryCalculation.totalSalary)}',
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildSalaryItem(
                          'Already Paid',
                          '\$${NumberFormat('#,##0.00').format(salaryCalculation.alreadyPaid)}',
                          salaryCalculation.alreadyPaid > 0 ? Colors.green : Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: _buildSalaryItem(
                          'Remaining',
                          '\$${NumberFormat('#,##0.00').format(salaryCalculation.remainingAmount)}',
                          salaryCalculation.remainingAmount > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Group and student info
                  Row(
                    children: [
                      Icon(Icons.groups, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${salaryCalculation.groups.length} groups',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${salaryCalculation.totalStudents} students',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: salaryCalculation.remainingAmount > 0 
                              ? Colors.orange 
                              : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          salaryCalculation.remainingAmount > 0 ? 'Pending' : 'Paid',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}