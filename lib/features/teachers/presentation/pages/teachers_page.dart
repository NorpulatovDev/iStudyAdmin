// lib/features/teachers/presentation/pages/teachers_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/teacher_bloc.dart';
import '../widgets/teacher_card.dart';
import '../widgets/teacher_form_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repositories/teacher_repository.dart';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final _searchController = TextEditingController();
  int? _currentBranchId;
  String? _currentFilter;

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
      context.read<TeacherBloc>().add(
        TeacherLoadByBranchRequested(branchId: _currentBranchId),
      );
    }
  }

  void _handleSearch(String query) {
    if (_currentBranchId == null) return;

    setState(() {
      _currentFilter = null; // Clear filter when searching
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query && mounted) {
        context.read<TeacherBloc>().add(
          TeacherSearchRequested(query: query, branchId: _currentBranchId!),
        );
      }
    });
  }

  void _handleFilterBySalaryType(String salaryType) {
    if (_currentBranchId == null) return;

    setState(() {
      _currentFilter = salaryType;
      _searchController.clear(); // Clear search when filtering
    });

    context.read<TeacherBloc>().add(
      TeacherFilterBySalaryTypeRequested(
        branchId: _currentBranchId!,
        salaryType: salaryType,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _currentFilter = null;
      _searchController.clear();
    });
    _initializePage();
  }

  void _createTeacher() {
    if (_currentBranchId == null) return;

    showDialog(
      context: context,
      builder: (context) => TeacherFormDialog(
        branchId: _currentBranchId!,
        onSubmit:
            (
              firstName,
              lastName,
              phoneNumber,
              baseSalary,
              paymentPercentage,
              salaryType,
            ) {
              context.read<TeacherBloc>().add(
                TeacherCreateRequested(
                  firstName: firstName,
                  lastName: lastName,
                  branchId: _currentBranchId!,
                  phoneNumber: phoneNumber,
                  baseSalary: baseSalary,
                  paymentPercentage: paymentPercentage,
                  salaryType: salaryType,
                ),
              );
            },
      ),
    );
  }

  void _editTeacher(teacher) {
    showDialog(
      context: context,
      builder: (context) => TeacherFormDialog(
        branchId: teacher.branchId,
        teacher: teacher,
        onSubmit:
            (
              firstName,
              lastName,
              phoneNumber,
              baseSalary,
              paymentPercentage,
              salaryType,
            ) {
              context.read<TeacherBloc>().add(
                TeacherUpdateRequested(
                  id: teacher.id,
                  firstName: firstName,
                  lastName: lastName,
                  branchId: teacher.branchId,
                  phoneNumber: phoneNumber,
                  baseSalary: baseSalary,
                  paymentPercentage: paymentPercentage,
                  salaryType: salaryType,
                ),
              );
            },
      ),
    );
  }

  void _deleteTeacher(teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Delete Teacher'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this teacher?'),
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
                    teacher.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${teacher.branchName} • ${teacher.salaryTypeDisplayName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (teacher.phoneNumber != null &&
                      teacher.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      teacher.phoneNumber!,
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
              context.read<TeacherBloc>().add(
                TeacherDeleteRequested(teacher.id),
              );
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

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'FIXED', 'label': 'Fixed Salary', 'color': Colors.blue},
      {'key': 'PERCENTAGE', 'label': 'Percentage', 'color': Colors.green},
      {'key': 'MIXED', 'label': 'Mixed', 'color': Colors.orange},
    ];

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          // Clear filters chip
          if (_currentFilter != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.clear, size: 16),
                    const SizedBox(width: 4),
                    const Text('Clear'),
                  ],
                ),
                onSelected: (_) => _clearFilters(),
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.grey.shade300,
                checkmarkColor: Colors.black,
                selected: false,
              ),
            ),

          // Salary type filters
          ...filters.map(
            (filter) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['label'] as String),
                selected: _currentFilter == filter['key'],
                onSelected: (selected) {
                  if (selected) {
                    _handleFilterBySalaryType(filter['key'] as String);
                  } else {
                    _clearFilters();
                  }
                },
                backgroundColor: (filter['color'] as Color).withOpacity(0.1),
                selectedColor: (filter['color'] as Color).withOpacity(0.2),
                checkmarkColor: filter['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocListener<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherOperationSuccess) {
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
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search teachers by name...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6B7280),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _clearFilters();
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

            // Filter Chips
            _buildFilterChips(),

            // Content Area
            Expanded(
              child: BlocBuilder<TeacherBloc, TeacherState>(
                builder: (context, state) {
                  // Loading State
                  if (state is TeacherLoading ||
                      state is TeacherOperationLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading teachers...',
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
                  if (state is TeacherError) {
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
                            ElevatedButton.icon(
                              onPressed: _initializePage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Success State
                  if (state is TeacherLoaded) {
                    if (state.teachers.isEmpty) {
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
                                  state.isSearchResult || _currentFilter != null
                                      ? Icons.search_off
                                      : Icons.person_outlined,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                state.isSearchResult
                                    ? 'No teachers found'
                                    : _currentFilter != null
                                    ? 'No teachers with this salary type'
                                    : 'No teachers yet',
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
                                    : _currentFilter != null
                                    ? 'Try adjusting your filter or add new teachers'
                                    : 'Add your first teacher to get started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (state.isSearchResult ||
                                  _currentFilter != null)
                                TextButton.icon(
                                  onPressed: _clearFilters,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear Filters'),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: _createTeacher,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add First Teacher'),
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

                    return RefreshIndicator(
                      onRefresh: () async {
                        _initializePage();
                      },
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: state.teachers.length,
                        itemBuilder: (context, index) {
                          final teacher = state.teachers[index];
                          return TeacherCard(
                            teacher: teacher,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Viewing ${teacher.fullName}'),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            onEdit: () => _editTeacher(teacher),
                            onDelete: () => _deleteTeacher(teacher),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTeacher,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
