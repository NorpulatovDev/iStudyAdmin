// lib/features/groups/presentation/widgets/student_info_table.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../data/models/group_model.dart';

class StudentInfoTable extends StatelessWidget {
  final List<StudentInfo> students;
  final int groupId;

  const StudentInfoTable({
    super.key,
    required this.students,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity, // parent full width
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          // make DataTable at least as wide as the screen
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            columnSpacing: 24,
            horizontalMargin: 20,
            border: TableBorder.all(borderRadius: BorderRadius.circular(12)),
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(
                label: Text(
                  '#',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Student Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Phone',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Parent Phone',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Course Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Paid This Month',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Remaining',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                numeric: true,
                headingRowAlignment: MainAxisAlignment.center,
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                headingRowAlignment: MainAxisAlignment.center,
              ),
            ],
            rows: List.generate(
              students.length,
              (index) => _buildDataRow(context, students[index], index + 1),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, StudentInfo student, int ordinal) {
    Color? rowColor;

    switch (student.paymentStatus?.toLowerCase()) {
      case 'paid':
        rowColor = Colors.green[50]; // light green
        break;
      case 'partial':
        rowColor = Colors.yellow[50]; // light yellow
        break;
      case 'pending':
      case 'unpaid':
        rowColor = Colors.red[50]; // light red
        break;
      default:
        rowColor = null; // no color
    }

    return DataRow(
      color: rowColor != null ? MaterialStateProperty.all(rowColor) : null,
      cells: [
        DataCell(Text(ordinal.toString(),
            style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(student.studentName ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(student.phoneNumber ?? 'N/A')),
        DataCell(Text(student.parentPhoneNumber ?? 'N/A')),
        DataCell(Text(student.coursePrice != null
            ? '\$${student.coursePrice!.toStringAsFixed(2)}'
            : 'N/A')),
        DataCell(Text(
          student.totalPaidInMonth != null
              ? '\$${student.totalPaidInMonth!.toStringAsFixed(2)}'
              : '\$0.00',
          style: TextStyle(
            color: (student.totalPaidInMonth ?? 0) > 0
                ? Colors.green[700]
                : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        )),
        DataCell(Text(
          student.remainingAmount != null
              ? '\$${student.remainingAmount!.toStringAsFixed(2)}'
              : 'N/A',
          style: TextStyle(
            color: (student.remainingAmount ?? 0) > 0
                ? Colors.red[700]
                : Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        )),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => _viewStudent(context, student),
                tooltip: 'View Student',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[700],
                  minimumSize: const Size(32, 32),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editStudent(context, student),
                tooltip: 'Edit Student',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  foregroundColor: Colors.orange[700],
                  minimumSize: const Size(32, 32),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.remove_circle, size: 18),
                onPressed: () => _removeStudent(context, student),
                tooltip: 'Remove from Group',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No students in this group',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add students to see their information here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewStudent(BuildContext context, StudentInfo student) {
    // TODO: Implement view student functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View student: ${student.studentName} - To be implemented')),
    );
  }

  void _editStudent(BuildContext context, StudentInfo student) {
    // TODO: Implement edit student functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit student: ${student.studentName} - To be implemented')),
    );
  }

  void _removeStudent(BuildContext context, StudentInfo student) {
    if (student.studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove student: Student ID not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove "${student.studentName}" from this group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              
              // Dispatch remove student event
              context.read<GroupBloc>().add(
                GroupRemoveStudentRequested(
                  groupId: groupId,
                  studentId: student.studentId!,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}