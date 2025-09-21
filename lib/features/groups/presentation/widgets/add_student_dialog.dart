// lib/features/groups/presentation/widgets/add_student_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../data/models/group_model.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/data/models/student_model.dart';

class AddStudentDialog extends StatefulWidget {
  final GroupModel group;

  const AddStudentDialog({
    super.key,
    required this.group,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<StudentModel> _availableStudents = [];
  List<StudentModel> _filteredStudents = [];
  StudentModel? _selectedStudent;
  bool _isLoadingStudents = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAvailableStudents() async {
    setState(() {
      _isLoadingStudents = true;
    });

    try {
      // Load students from the same branch who are not already in this group
      context.read<StudentBloc>().add(
            StudentLoadByBranchRequested(branchId: widget.group.branchId),
          );
    } catch (e) {
      print('Error loading students: $e');
    } finally {
      setState(() {
        _isLoadingStudents = false;
      });
    }
  }

  void _filterStudents() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredStudents = _availableStudents;
      } else {
        _filteredStudents = _availableStudents.where((student) {
          final fullName =
              '${student.firstName} ${student.lastName}'.toLowerCase();
          final phoneNumber = student.phoneNumber?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();

          return fullName.contains(query) || phoneNumber.contains(query);
        }).toList();
      }
    });
  }

  List<StudentModel> _getStudentsNotInGroup(List<StudentModel> allStudents) {
    final groupStudentIds = widget.group.studentPayments
            ?.map((s) => s.studentId)
            .where((id) => id != null)
            .cast<int>()
            .toSet() ??
        <int>{};

    return allStudents
        .where((student) => !groupStudentIds.contains(student.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Dialog(
      insetPadding: EdgeInsets.all(isDesktop ? 40 : 16),
      child: Container(
        width: double.infinity,
        height: isDesktop ? 600 : MediaQuery.of(context).size.height * 0.8,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
        ),
        child: Column(
          children: [
            _buildHeader(),
            // _buildSearchField(),
            Expanded(child: _buildStudentsList()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Student to Group',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Group: ${widget.group.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
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
    );
  }

  // Widget _buildSearchField() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       controller: _searchController,
  //       decoration: InputDecoration(
  //         hintText: 'Search students by name or phone...',
  //         prefixIcon: const Icon(Icons.search),
  //         suffixIcon: _searchController.text.isNotEmpty
  //             ? IconButton(
  //                 icon: const Icon(Icons.clear),
  //                 onPressed: () {
  //                   _searchController.clear();
  //                   setState(() {
  //                     _searchQuery = '';
  //                   });
  //                   _filterStudents();
  //                 },
  //               )
  //             : IconButton(
  //                 icon: const Icon(Icons.refresh),
  //                 onPressed: _loadAvailableStudents,
  //               ),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: BorderSide(color: Colors.grey[300]!),
  //         ),
  //         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //       ),
  //       onChanged: (value) {
  //         setState(() {
  //           _searchQuery = value;
  //         });
  //         _filterStudents();
  //       },
  //     ),
  //   );
  // }

  Widget _buildStudentsList() {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, studentState) {
        if (studentState is StudentLoading || _isLoadingStudents) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading available students...'),
              ],
            ),
          );
        }

        if (studentState is StudentLoaded) {
          _availableStudents = _getStudentsNotInGroup(studentState.students);
          if (_filteredStudents.isEmpty && _searchQuery.isEmpty) {
            _filteredStudents = _availableStudents;
          } else if (_searchQuery.isNotEmpty) {
            _filterStudents();
          }
        }

        if (studentState is StudentError) {
          return _buildErrorState(studentState.message);
        }

        if (_availableStudents.isEmpty) {
          return _buildEmptyState();
        }

        if (_filteredStudents.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoSearchResults();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredStudents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final student = _filteredStudents[index];
            return _buildStudentCard(student);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    final isSelected = _selectedStudent?.id == student.id;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStudent = isSelected ? null : student;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : null,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.firstName} ${student.lastName}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (student.phoneNumber != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            student.phoneNumber!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (student.parentPhoneNumber != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.family_restroom,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Parent: ${student.parentPhoneNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.people_outline,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No available students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All students in this branch are already enrolled in the group, or no students are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAvailableStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name or phone number.',
              textAlign: TextAlign.center,
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAvailableStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupOperationLoading;
          final hasSelection = _selectedStudent != null;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : (hasSelection ? _addStudentToGroup : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection ? null : Colors.grey[300],
                  foregroundColor: hasSelection ? null : Colors.grey[600],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(hasSelection ? 'Add Student' : 'Select a Student'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addStudentToGroup() {
    if (_selectedStudent == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Student',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add "${_selectedStudent!.firstName} ${_selectedStudent!.lastName}" to group "${widget.group.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Student Information',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Name: ${_selectedStudent!.firstName} ${_selectedStudent!.lastName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  if (_selectedStudent!.phoneNumber != null)
                    Text(
                      'Phone: ${_selectedStudent!.phoneNumber}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  if (_selectedStudent!.parentPhoneNumber != null)
                    Text(
                      'Parent Phone: ${_selectedStudent!.parentPhoneNumber}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GroupBloc>().add(
                    GroupAddStudentRequested(
                      groupId: widget.group.id,
                      studentId: _selectedStudent!.id,
                    ),
                  );
            },
            child: const Text('Add Student'),
          ),
        ],
      ),
    );
  }
}
