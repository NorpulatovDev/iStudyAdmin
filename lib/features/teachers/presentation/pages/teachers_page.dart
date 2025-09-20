import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../widgets/teacher_form_dialog.dart';
import '../../data/models/teacher_model.dart';
import 'teacher_details_page.dart';

class TeachersPage extends StatefulWidget {
  final int? branchId;

  const TeachersPage({super.key, this.branchId});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSalaryType;

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(TeacherLoadByBranchRequested(branchId: widget.branchId));
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
      body: Column(
        children: [
          _buildHeader(),
          // _buildFilters(),
          Expanded(
            child: BlocListener<TeacherBloc, TeacherState>(
              listener: (context, state) {
                if (state is TeacherOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is TeacherError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<TeacherBloc, TeacherState>(
                builder: (context, state) {
                  if (state is TeacherLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is TeacherLoaded) {
                    if (state.teachers.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return _buildTeachersList(state.teachers);
                  }
                  
                  if (state is TeacherError) {
                    return _buildErrorState(state.message);
                  }
                  
                  return const Center(
                    child: Text(
                      'No teachers available',
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            const Icon(Icons.person, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Teachers',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showCreateTeacherDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Teacher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  // Widget _buildFilters() {
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
  //     child: Row(
  //       children: [
  //         // Search Field
  //         Expanded(
  //           flex: 2,
  //           child: TextField(
  //             controller: _searchController,
  //             decoration: InputDecoration(
  //               hintText: 'Search teachers...',
  //               prefixIcon: const Icon(Icons.search),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 borderSide: BorderSide(color: Colors.grey[300]!),
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //             ),
  //             onChanged: (value) {
  //               if (widget.branchId != null) {
  //                 context.read<TeacherBloc>().add(
  //                   TeacherSearchRequested(
  //                     query: value,
  //                     branchId: widget.branchId!,
  //                   ),
  //                 );
  //               }
  //             },
  //           ),
  //         ),
  //         const SizedBox(width: 16),
          
  //         // Salary Type Filter
  //         Expanded(
  //           child: DropdownButtonFormField<String>(
  //             value: _selectedSalaryType,
  //             decoration: InputDecoration(
  //               labelText: 'Salary Type',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //             ),
  //             items: [
  //               const DropdownMenuItem(value: null, child: Text('All Types')),
  //               const DropdownMenuItem(value: 'FIXED', child: Text('Fixed')),
  //               const DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentage')),
  //               const DropdownMenuItem(value: 'MIXED', child: Text('Mixed')),
  //             ],
  //             onChanged: (value) {
  //               setState(() {
  //                 _selectedSalaryType = value;
  //               });
                
  //               if (widget.branchId != null) {
  //                 if (value == null) {
  //                   // Show all teachers
  //                   context.read<TeacherBloc>().add(
  //                     TeacherLoadByBranchRequested(branchId: widget.branchId),
  //                   );
  //                 } else {
  //                   // Filter by salary type
  //                   context.read<TeacherBloc>().add(
  //                     TeacherFilterBySalaryTypeRequested(
  //                       branchId: widget.branchId!,
  //                       salaryType: value,
  //                     ),
  //                   );
  //                 }
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTeachersList(List<TeacherModel> teachers) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Teachers (${teachers.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                return _buildTeacherCard(teachers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToTeacherDetails(teacher),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditTeacherDialog(teacher);
                      } else if (value == 'delete') {
                        _deleteTeacher(teacher);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (teacher.phoneNumber != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              teacher.phoneNumber!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getSalaryTypeColor(teacher.salaryType)[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            teacher.salaryTypeDisplayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSalaryTypeColor(teacher.salaryType)[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            teacher.branchName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MaterialColor _getSalaryTypeColor(String salaryType) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
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
                Icons.person_outline,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No teachers available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first teacher to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateTeacherDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Teacher'),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
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
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshTeachers,
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

  void _navigateToTeacherDetails(TeacherModel teacher) async {
    // Navigate to teacher details and wait for result
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherDetailsPage(teacherId: teacher.id),
      ),
    );
    
    // Refresh teachers when returning from teacher details
    context.read<TeacherBloc>().add(TeacherLoadByBranchRequested(branchId: widget.branchId));
  }

  void _refreshTeachers() {
    context.read<TeacherBloc>().add(TeacherRefreshRequested(branchId: widget.branchId));
  }

  void _showCreateTeacherDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: TeacherFormDialog(
          branchId: widget.branchId ?? 1, // fallback to 1 if no branch ID available
        ),
      ),
    );
  }

  void _showEditTeacherDialog(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeacherBloc>(),
        child: TeacherFormDialog(
          teacher: teacher,
          branchId: teacher.branchId,
        ),
      ),
    );
  }

  void _deleteTeacher(TeacherModel teacher) {
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
            const Text(
              'Delete Teacher',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${teacher.fullName}"?',
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
                      'This will also affect all associated groups and data.',
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TeacherBloc>().add(TeacherDeleteRequested(teacher.id));
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