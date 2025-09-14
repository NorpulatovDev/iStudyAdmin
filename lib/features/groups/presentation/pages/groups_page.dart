// lib/features/groups/presentation/pages/groups_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../students/presentation/pages/students_page.dart';
import '../bloc/group_bloc.dart';
import '../widgets/group_card.dart';

class GroupsPage extends StatefulWidget {
  final int? courseId; // null = from drawer, not null = from course
  final String? courseName; // For better UX when coming from course

  const GroupsPage({super.key, this.courseId, this.courseName});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  int? _currentBranchId;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentBranchId = authState.user.branchId;
      
      if (widget.courseId != null) {
        // Load groups by course
        context.read<GroupBloc>().add(
          GroupLoadByCourseRequested(widget.courseId!),
        );
      } else {
        // Load groups by branch (from drawer)
        context.read<GroupBloc>().add(
          GroupLoadByBranchRequested(branchId: _currentBranchId),
        );
      }
    }
  }

  void _navigateToGroupStudents(group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentsPage(
          groupId: group.id,
          groupName: group.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: widget.courseId != null 
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Groups',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.courseName != null)
                    Text(
                      widget.courseName!,
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
              toolbarHeight: widget.courseName != null ? 70 : 56,
              // Add a refresh action
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initializePage,
                  tooltip: 'Refresh groups',
                ),
              ],
            )
          : null, // No appbar if from drawer (MainLayout handles it)
      
      body: BlocListener<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
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
        child: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading || state is GroupOperationLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.courseId != null 
                          ? 'Loading course groups...'
                          : 'Loading groups...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is GroupError) {
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
                          if (widget.courseId != null)
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

            if (state is GroupLoaded) {
              if (state.groups.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          state.loadedBy == 'course' 
                              ? 'No groups for this course' 
                              : 'No groups yet',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.loadedBy == 'course'
                              ? widget.courseName != null
                                  ? '${widget.courseName} doesn\'t have any groups yet'
                                  : 'This course doesn\'t have any groups yet'
                              : 'Create your first group to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (state.loadedBy == 'course')
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Courses'),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Header info
                  if (state.loadedBy == 'course')
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.courseName ?? 'Course Groups',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${state.groups.length} group(s) found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Tip for navigation
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 12,
                                  color: Colors.purple[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to view students',
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Groups list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _initializePage();
                      },
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return GroupCard(
                            group: group,
                            onTap: () => _navigateToGroupStudents(group),
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
    );
  }
}