import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/group_bloc.dart';
import '../widgets/student_info_table.dart';
import '../../data/models/group_model.dart';

class GroupDetailsPage extends StatefulWidget {
  final int groupId;
  final int? initialYear;
  final int? initialMonth;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    this.initialYear,
    this.initialMonth,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late int currentYear;
  late int currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentYear = widget.initialYear ?? now.year;
    currentMonth = widget.initialMonth ?? now.month;
    _loadGroupDetails();
  }

  void _loadGroupDetails() {
    context.read<GroupBloc>().add(
          GroupLoadByIdRequested(widget.groupId, currentYear, currentMonth),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocListener<GroupBloc, GroupState>(
              listener: (context, state) {
                if (state is GroupOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGroupDetails(); // Refresh data
                } else if (state is GroupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GroupDetailLoaded) {
                    return _buildGroupDetails(state.group);
                  }

                  if (state is GroupError) {
                    return _buildErrorState(state.message);
                  }

                  return const Center(child: Text('No group data available'));
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.groups, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Group Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _buildMonthYearSelector(),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: currentMonth,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
            underline: Container(),
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(months[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  currentMonth = value;
                });
                _loadGroupDetails();
              }
            },
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: currentYear,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
            underline: Container(),
            items: List.generate(5, (index) {
              final year = DateTime.now().year - 2 + index;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  currentYear = value;
                });
                _loadGroupDetails();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDetails(GroupModel group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupInfoCard(group),
          const SizedBox(height: 24),
          _buildStudentSection(group),
        ],
      ),
    );
  }

  Widget _buildGroupInfoCard(GroupModel group) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      group.courseName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showUpdateGroupDialog(group),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Update Group',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(group),
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Group',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip('Branch', group.branchName, Colors.purple),
              const SizedBox(width: 16),
              _buildInfoChip('Teacher', group.teacherName ?? 'Not assigned',
                  Colors.orange),
              const SizedBox(width: 16),
              _buildInfoChip(
                  'Created',
                  DateFormat('MMM dd, yyyy').format(group.createdAt),
                  Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSection(GroupModel group) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Students (${group.studentCount})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddStudentDialog(group),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Student'),
                ),
              ],
            ),
          ),
          StudentInfoTable(students: group.studentPayments ?? []),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadGroupDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showUpdateGroupDialog(GroupModel group) {
    // TODO: Implement update group dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Update group dialog - To be implemented')),
    );
  }

  void _showDeleteConfirmation(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GroupBloc>().add(GroupDeleteRequested(group.id));
              Navigator.pop(context); // Go back after deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(GroupModel group) {
    // TODO: Implement add student dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add student dialog - To be implemented')),
    );
  }
}
