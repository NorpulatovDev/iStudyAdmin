// lib/features/teachers/presentation/pages/teacher_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../widgets/salary_calculation_dialog.dart';
import '../widgets/teacher_info_card.dart';
import '../widgets/teacher_groups_section.dart';

class TeacherProfilePage extends StatefulWidget {
  final TeacherModel teacher;

  const TeacherProfilePage({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  List<GroupModel> teacherGroups = [];
  bool isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherGroups();
  }

  void _loadTeacherGroups() {
    setState(() {
      isLoadingGroups = true;
    });

    // Load groups by teacher - this would need a new API endpoint
    // For now, we'll simulate loading groups
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // This would be replaced with actual API call
          teacherGroups = []; // Will be populated from API
          isLoadingGroups = false;
        });
      }
    });
  }

  void _showSalaryCalculation() {
    showDialog(
      context: context,
      builder: (context) => SalaryCalculationDialog(
        teacher: widget.teacher,
        onCalculate: (year, month) {
          // Handle salary calculation
          _calculateSalary(year, month);
        },
      ),
    );
  }

  void _calculateSalary(int year, int month) {
    // This would call the salary calculation API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calculating salary for ${widget.teacher.fullName}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.teacher.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeacherGroups,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTeacherGroups();
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher Information Card
              TeacherInfoCard(teacher: widget.teacher),
              
              const SizedBox(height: 20),
              
              // Quick Actions Section
              _buildQuickActions(),
              
              const SizedBox(height: 20),
              
              // Teacher Groups Section
              TeacherGroupsSection(
                groups: teacherGroups,
                isLoading: isLoadingGroups,
                onRefresh: _loadTeacherGroups,
              ),
              
              const SizedBox(height: 20),
              
              // Salary Information Section
              _buildSalarySection(),
              
              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSalaryCalculation,
        backgroundColor: AppTheme.successColor,
        icon: const Icon(Icons.calculate, color: Colors.white),
        label: const Text(
          'Calculate Salary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.groups,
                    label: 'View Groups',
                    color: Colors.purple,
                    onTap: () {
                      // Scroll to groups section or navigate
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.payment,
                    label: 'Salary History',
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to salary history
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone,
                    label: 'Contact',
                    color: Colors.blue,
                    onTap: () {
                      // Open phone dialer or contact
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalarySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.attach_money,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Salary Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Salary Type
            _buildSalaryInfoRow(
              'Salary Type',
              widget.teacher.salaryTypeDisplayName,
              _getSalaryTypeColor(widget.teacher.salaryType),
            ),
            
            // Base Salary (if applicable)
            if (widget.teacher.salaryType == 'FIXED' || widget.teacher.salaryType == 'MIXED')
              _buildSalaryInfoRow(
                'Base Salary',
                '\$${NumberFormat('#,##0.00').format(widget.teacher.baseSalary)}',
                Colors.blue,
              ),
            
            // Payment Percentage (if applicable)
            if (widget.teacher.salaryType == 'PERCENTAGE' || widget.teacher.salaryType == 'MIXED')
              _buildSalaryInfoRow(
                'Payment Percentage',
                '${widget.teacher.paymentPercentage.toStringAsFixed(1)}%',
                Colors.green,
              ),
            
            const SizedBox(height: 16),
            
            // Calculate Salary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showSalaryCalculation,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Monthly Salary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
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
      ),
    );
  }

  Widget _buildSalaryInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSalaryTypeColor(String salaryType) {
    switch (salaryType) {
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
}