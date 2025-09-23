// lib/features/groups/presentation/pages/group_details_page.dart - Mobile Responsive Version

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/group_bloc.dart';
import '../widgets/student_info_table.dart';
import '../widgets/edit_group_dialog.dart';
import '../widgets/add_student_dialog.dart';
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
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final GlobalKey<FormState> _dateFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentYear = widget.initialYear ?? now.year;
    currentMonth = widget.initialMonth ?? now.month;

    _yearController.text = currentYear.toString();
    _monthController.text = currentMonth.toString();

    _loadGroupDetails();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _loadGroupDetails() {
    context.read<GroupBloc>().add(
          GroupLoadByIdRequested(widget.groupId, currentYear, currentMonth),
        );
  }

  void _updateDateAndLoad() {
    if (_dateFormKey.currentState?.validate() ?? false) {
      final newYear = int.parse(_yearController.text);
      final newMonth = int.parse(_monthController.text);

      setState(() {
        currentYear = newYear;
        currentMonth = newMonth;
      });

      _loadGroupDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(isMobile),
          Expanded(
            child: BlocListener<GroupBloc, GroupState>(
              listener: (context, state) {
                if (state is GroupOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _loadGroupDetails(); // Refresh data
                } else if (state is GroupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is GroupDetailLoaded) {
                    return _buildGroupDetails(state.group, isMobile, isTablet);
                  }

                  if (state is GroupError) {
                    return _buildErrorState(state.message, isMobile);
                  }

                  return const Center(
                    child: Text(
                      'No group data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 20,
      ),
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
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Icon(
              Icons.groups,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Text(
                'Group Details',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDetails(GroupModel group, bool isMobile, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupInfoCard(group, isMobile),
          SizedBox(height: isMobile ? 16 : 24),
          _buildStatsCards(group, isMobile, isTablet),
          SizedBox(height: isMobile ? 16 : 24),
          _buildStudentSection(group, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildGroupInfoCard(GroupModel group, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile: Stack layout, Desktop: Row layout
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupTitle(group, isMobile),
                const SizedBox(height: 16),
                _buildActionButtons(group, isMobile),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _buildGroupTitle(group, isMobile)),
                _buildActionButtons(group, isMobile),
              ],
            ),
          SizedBox(height: isMobile ? 16 : 24),
          _buildInfoChips(group, isMobile),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(GroupModel group, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name,
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.school,
              size: isMobile ? 16 : 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                group.courseName,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(GroupModel group, bool isMobile) {
    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit',
              color: Colors.blue,
              onPressed: () => _showUpdateGroupDialog(group),
              isCompact: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              color: Colors.red,
              onPressed: () => _showDeleteConfirmation(group),
              isCompact: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: Colors.blue,
          onPressed: () => _showUpdateGroupDialog(group),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: Colors.red,
          onPressed: () => _showDeleteConfirmation(group),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isCompact = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isCompact ? 16 : 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildInfoChips(GroupModel group, bool isMobile) {
    final chips = [
      _buildInfoChip(
        icon: Icons.location_on_outlined,
        label: 'Branch',
        value: group.branchName,
        color: Colors.purple,
        isMobile: isMobile,
      ),
      _buildInfoChip(
        icon: Icons.person_outline,
        label: 'Teacher',
        value: group.teacherName ?? 'Not assigned',
        color: Colors.orange,
        isMobile: isMobile,
      ),
      _buildInfoChip(
        icon: Icons.calendar_today_outlined,
        label: 'Created',
        value: DateFormat('MMM dd, yyyy').format(group.createdAt),
        color: Colors.green,
        isMobile: isMobile,
      ),
    ];

    if (isMobile) {
      return Column(
        children: chips
            .map((chip) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(width: double.infinity, child: chip),
                ))
            .toList(),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: chips,
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(GroupModel group, bool isMobile, bool isTablet) {
    final cards = [
      _buildStatCard(
        icon: Icons.people_outline,
        title: 'Total Students',
        value: '${group.studentCount}',
        color: Colors.blue,
        isMobile: isMobile,
      ),
      _buildStatCard(
        icon: Icons.schedule_outlined,
        title: 'Schedule',
        value: group.daysOfWeek.map((day) => day.substring(0, 3)).join(", "),
        color: Colors.green,
        isMobile: isMobile,
      ),
      _buildStatCard(
        icon: Icons.access_time_outlined,
        title: 'Duration',
        value: "${group.startTime}/${group.endTime}",
        color: Colors.orange,
        isMobile: isMobile,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: card,
                ))
            .toList(),
      );
    }

    return Row(
      children: cards
          .map((card) => Expanded(child: card))
          .expand((widget) => [widget, const SizedBox(width: 16)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
      child: isMobile
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentSection(GroupModel group, bool isMobile, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                _buildStudentHeader(group, isMobile),
                SizedBox(height: isMobile ? 16 : 20),
                _buildDatePicker(isMobile),
              ],
            ),
          ),
          StudentInfoTable(
            students: group.studentPayments ?? [],
            groupId: group.id,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader(GroupModel group, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Students',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.studentCount} students enrolled',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddStudentDialog(group),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${group.studentCount} students enrolled',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddStudentDialog(group),
          icon: const Icon(Icons.person_add, size: 18),
          label: const Text('Add Student'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'View data for:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _dateFormKey,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      hintText: '2024',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final year = int.tryParse(value);
                      if (year == null) {
                        return 'Invalid';
                      }
                      if (year < 2000 || year > 2100) {
                        return 'Invalid range';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _updateDateAndLoad(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      hintText: '12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final month = int.tryParse(value);
                      if (month == null) {
                        return 'Invalid';
                      }
                      if (month < 1 || month > 12) {
                        return '1-12 only';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _updateDateAndLoad(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _updateDateAndLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'View data for:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Form(
            key: _dateFormKey,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      hintText: '2024',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final year = int.tryParse(value);
                      if (year == null) {
                        return 'Invalid';
                      }
                      if (year < 2000 || year > 2100) {
                        return 'Invalid range';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _updateDateAndLoad(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      hintText: '12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final month = int.tryParse(value);
                      if (month == null) {
                        return 'Invalid';
                      }
                      if (month < 1 || month > 12) {
                        return '1-12 only';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _updateDateAndLoad(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _updateDateAndLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, bool isMobile) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
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
                size: isMobile ? 40 : 48,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: _loadGroupDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateGroupDialog(GroupModel group) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditGroupDialog(group: group),
    );
  }

  void _showDeleteConfirmation(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Group',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${group.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone and will remove all associated data.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GroupBloc>().add(GroupDeleteRequested(group.id));
              Navigator.pop(context); // Go back after deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(GroupModel group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddStudentDialog(group: group),
    );
  }
}