// lib/features/students/presentation/pages/students_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/student_bloc.dart';
import '../widgets/student_card.dart';
import '../widgets/student_form_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class StudentsPage extends StatefulWidget {
  final int? groupId; // null = from drawer, not null = from group
  final String? groupName; // For better UX when coming from group

  const StudentsPage({super.key, this.groupId, this.groupName});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _searchController = TextEditingController();
  int? _currentBranchId;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializePage() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentBranchId = authState.user.branchId;
      
      if (widget.groupId != null) {
        // Load students by group
        context.read<StudentBloc>().add(
          StudentLoadByGroupRequested(widget.groupId!),
        );
      } else {
        // Load students by branch (from drawer)
        context.read<StudentBloc>().add(
          StudentLoadByBranchRequested(branchId: _currentBranchId),
        );
      }
    }
  }

  void _handleSearch(String query) {
    if (_currentBranchId == null || widget.groupId != null) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query && mounted) {
        context.read<StudentBloc>().add(
          StudentSearchRequested(query: query, branchId: _currentBranchId!),
        );
      }
    });
  }

  void _createStudent() {
    if (_currentBranchId == null) return;

    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        branchId: _currentBranchId!,
        onSubmit: (firstName, lastName, phoneNumber) {
          context.read<StudentBloc>().add(
            StudentCreateRequested(
              firstName: firstName,
              lastName: lastName,
              branchId: _currentBranchId!,
              phoneNumber: phoneNumber,
            ),
          );
        },
      ),
    );
  }

  void _editStudent(student) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        branchId: student.branchId,
        student: student,
        onSubmit: (firstName, lastName, phoneNumber) {
          context.read<StudentBloc>().add(
            StudentUpdateRequested(
              id: student.id,
              firstName: firstName,
              lastName: lastName,
              branchId: student.branchId,
              phoneNumber: phoneNumber,
            ),
          );
        },
      ),
    );
  }

  void _deleteStudent(student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Delete Student'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this student?'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.branchName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      student.phoneNumber!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action cannot be undone.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
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
              context.read<StudentBloc>().add(StudentDeleteRequested(student.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: widget.groupId != null 
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Group Students',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.groupName != null)
                    Text(
                      widget.groupName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: widget.groupName != null ? 70 : 56,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initializePage,
                  tooltip: 'Refresh students',
                ),
              ],
            )
          : null, // No appbar if from drawer (MainLayout handles it)
      
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Search Bar (only show if not from group)
            if (widget.groupId == null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search students by name or phone...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B7280),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _initializePage();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: _handleSearch,
                ),
              ),

            // Content Area
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) {
                  // Loading State
                  if (state is StudentLoading || state is StudentOperationLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.groupId != null 
                                ? 'Loading group students...'
                                : 'Loading students...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Error State
                  if (state is StudentError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Something went wrong',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _initializePage,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (widget.groupId != null)
                                  TextButton.icon(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Go Back'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success State
                  if (state is StudentLoaded) {
                    if (state.students.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  state.isSearchResult
                                      ? Icons.search_off
                                      : Icons.people_outlined,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                state.isSearchResult
                                    ? 'No students found'
                                    : state.loadedBy == 'group'
                                        ? 'No students in this group'
                                        : 'No students yet',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.isSearchResult
                                    ? 'Try searching with different keywords'
                                    : state.loadedBy == 'group'
                                        ? widget.groupName != null
                                            ? '${widget.groupName} doesn\'t have any students yet'
                                            : 'This group doesn\'t have any students yet'
                                        : 'Add your first student to get started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state.isSearchResult)
                                TextButton.icon(
                                  onPressed: () {
                                    _searchController.clear();
                                    _initializePage();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear Search'),
                                )
                              else if (state.loadedBy == 'group')
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back to Groups'),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: _createStudent,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First Student'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Header info (if from group)
                        if (state.loadedBy == 'group')
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.group,
                                    color: Colors.purple,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.groupName ?? 'Group Students',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${state.students.length} student(s) enrolled',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Students List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _initializePage();
                            },
                            color: AppTheme.primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 100),
                              itemCount: state.students.length,
                              itemBuilder: (context, index) {
                                final student = state.students[index];
                                return StudentCard(
                                  student: student,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.person, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Text('Viewing ${student.fullName}'),
                                          ],
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  onEdit: widget.groupId == null ? () => _editStudent(student) : null,
                                  onDelete: widget.groupId == null ? () => _deleteStudent(student) : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.groupId == null 
          ? FloatingActionButton(
              onPressed: _createStudent,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // Don't show FAB when viewing group students
    );
  }
}