// lib/features/students/presentation/pages/students_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:istudyadmin/features/students/presentation/widgets/student_search_bar_chat.dart';

import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';
import '../widgets/student_list_item.dart';

import '../widgets/add_student_dialog.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _currentBranchId;

  @override
  void initState() {
    super.initState();
    // Always load students when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
    });
  }

  void _loadStudents() {
    // Load all students for the current branch
    context.read<StudentBloc>().add(const StudentLoadByBranchRequested());
  }

  void _onSearchChanged(String query) {
    if (_currentBranchId == null) return;

    if (query.trim().isEmpty) {
      // If search is empty, reload all students
      _loadStudents();
    } else {
      // Search students
      context.read<StudentBloc>().add(StudentSearchRequested(
        query: query,
        branchId: _currentBranchId!,
      ));
    }
  }

  void _showAddStudentDialog() {
    if (_currentBranchId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddStudentDialog(
        branchId: _currentBranchId!,
        onStudentAdded: () {
          // Refresh the list after adding
          _searchController.clear();
          _loadStudents();
        },
      ),
    );
  }

  void _onRefresh() {
    _searchController.clear();
    context.read<StudentBloc>().add(StudentRefreshRequested(
      branchId: _currentBranchId,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: BlocConsumer<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is StudentOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is StudentLoaded) {
              // Extract branch ID from the first student if available
              if (state.students.isNotEmpty) {
                _currentBranchId = state.students.first.branchId;
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Header with search and add button
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      StudentSearchBar(
                        controller: _searchController,
                        onChanged:  _onSearchChanged,
                        enabled: _currentBranchId != null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              state is StudentLoaded 
                                  ? '${state.students.length} students found'
                                  : 'Students',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _currentBranchId != null ? _showAddStudentDialog : null,
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
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _onRefresh,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _buildContent(state),
                ),
              ],
            );
          },
        ),
    );
  }

  Widget _buildContent(StudentState state) {
    if (state is StudentLoading || state is StudentOperationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is StudentLoaded) {
      if (state.students.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    state.isSearchResult ? Icons.search_off : Icons.people_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.isSearchResult
                      ? 'No students found'
                      : 'No students yet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.isSearchResult
                      ? 'Try adjusting your search criteria'
                      : 'Add your first student to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                if (!state.isSearchResult) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _currentBranchId != null ? _showAddStudentDialog : null,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add First Student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: state.students.length,
          itemBuilder: (context, index) {
            final student = state.students[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StudentListItem(
                student: student,
                onTap: () => _onStudentTap(student),
                onEdit: () => _onStudentEdit(student),
                onDelete: () => _onStudentDelete(student),
              ),
            );
          },
        ),
      );
    }

    if (state is StudentError) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(24),
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
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStudents,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Initial state
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _onStudentTap(StudentModel student) {
    // Navigate to student details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student details for ${student.fullName} - To be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onStudentEdit(StudentModel student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddStudentDialog(
        branchId: student.branchId,
        student: student,
        onStudentAdded: () {
          // Refresh the list after editing
          _onRefresh();
        },
      ),
    );
  }

  void _onStudentDelete(StudentModel student) {
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
            const Text('Delete Student'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${student.fullName}"?',
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
                      'This action cannot be undone and will remove the student from all groups.',
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
              context.read<StudentBloc>().add(
                StudentDeleteRequested(student.id),
              );
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
}