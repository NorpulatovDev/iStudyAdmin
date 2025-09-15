// lib/features/teachers/presentation/widgets/teacher_info_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';

class TeacherInfoCard extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherInfoCard({
    super.key,
    required this.teacher,
  });

  Color _getSalaryTypeColor() {
    switch (teacher.salaryType) {
      case 'FIXED':
        return Colors.blue;
      case 'PERCENTAGE':
        return Colors.green;
      case 'MIXED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getSalaryTypeColor().withOpacity(0.03),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with Avatar and Basic Info
            Row(
              children: [
                // Large Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getSalaryTypeColor(),
                        _getSalaryTypeColor().withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getSalaryTypeColor().withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${teacher.firstName[0]}${teacher.lastName[0]}'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Branch Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          teacher.branchName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Salary Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getSalaryTypeColor().withOpacity(0.1),
                          border: Border.all(
                            color: _getSalaryTypeColor().withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getSalaryTypeIcon(),
                              size: 14,
                              color: _getSalaryTypeColor(),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              teacher.salaryTypeDisplayName,
                              style: TextStyle(
                                color: _getSalaryTypeColor(),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Contact Information
            if (teacher.phoneNumber != null && teacher.phoneNumber!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: teacher.phoneNumber!,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
            ],
            
            if (teacher.email != null && teacher.email!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: teacher.email!,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
            ],
            
            // Join Date
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: DateFormat('MMM dd, yyyy').format(teacher.createdAt),
              color: Colors.orange,
            ),
            
            const SizedBox(height: 20),
            
            // Salary Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSalaryTypeColor().withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSalaryTypeColor().withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        size: 18,
                        color: _getSalaryTypeColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Salary Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getSalaryTypeColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      // Base Salary (if applicable)
                      if (teacher.salaryType == 'FIXED' || teacher.salaryType == 'MIXED')
                        Expanded(
                          child: _buildSalaryDetail(
                            'Base Salary',
                            '\$${NumberFormat('#,##0').format(teacher.baseSalary)}',
                            Colors.blue,
                          ),
                        ),
                      
                      // Percentage (if applicable)
                      if (teacher.salaryType == 'PERCENTAGE' || teacher.salaryType == 'MIXED') ...[
                        if (teacher.salaryType == 'MIXED') const SizedBox(width: 16),
                        Expanded(
                          child: _buildSalaryDetail(
                            'Percentage',
                            '${teacher.paymentPercentage.toStringAsFixed(1)}%',
                            Colors.green,
                          ),
                        ),
                      ],
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
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
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryDetail(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSalaryTypeIcon() {
    switch (teacher.salaryType) {
      case 'FIXED':
        return Icons.attach_money;
      case 'PERCENTAGE':
        return Icons.percent;
      case 'MIXED':
        return Icons.account_balance_wallet;
      default:
        return Icons.monetization_on;
    }
  }
}