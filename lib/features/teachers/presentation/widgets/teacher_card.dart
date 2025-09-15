// lib/features/teachers/presentation/widgets/teacher_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';

class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onProfile;

  const TeacherCard({
    super.key,
    required this.teacher,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onProfile,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _getSalaryTypeColor().withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with name and menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getSalaryTypeColor(),
                            _getSalaryTypeColor().withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _getSalaryTypeColor().withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${teacher.firstName[0]}${teacher.lastName[0]}'.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
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
                        ],
                      ),
                    ),
                    
                    if (onEdit != null || onDelete != null || onProfile != null)
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'profile':
                              onProfile?.call();
                              break;
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (onProfile != null)
                            const PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.person_outlined, size: 18, color: Colors.green),
                                  SizedBox(width: 12),
                                  Text('View Profile'),
                                ],
                              ),
                            ),
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                                  SizedBox(width: 12),
                                  Text('Edit Teacher'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                  SizedBox(width: 12),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),

                // Contact info (if exists)
                if (teacher.phoneNumber != null && teacher.phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        teacher.phoneNumber!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],

                if (teacher.email != null && teacher.email!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          teacher.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Salary Info Row
                Row(
                  children: [
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
                        borderRadius: BorderRadius.circular(16),
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

                    const Spacer(),

                    // Salary Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Base Salary (if applicable)
                        if (teacher.salaryType == 'FIXED' || teacher.salaryType == 'MIXED')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  size: 12,
                                  color: Colors.blue,
                                ),
                                Text(
                                  NumberFormat('#,##0').format(teacher.baseSalary),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Percentage (if applicable)
                        if (teacher.salaryType == 'PERCENTAGE' || teacher.salaryType == 'MIXED') ...[
                          if (teacher.salaryType == 'MIXED') const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.percent,
                                  size: 12,
                                  color: Colors.green,
                                ),
                                Text(
                                  '${teacher.paymentPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer Row
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Joined ${DateFormat('MMM dd, yyyy').format(teacher.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    
                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}