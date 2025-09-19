import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/course_bloc.dart';
import '../widgets/course_list_widget.dart';
import '../widgets/course_detail_widget.dart';
import '../widgets/course_form_dialog.dart';
import '../../data/models/course_model.dart';

class CoursesScreen extends StatefulWidget {
  final int? branchId;

  const CoursesScreen({super.key, this.branchId});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  CourseModel? selectedCourse;
  bool isDesktop = false;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(CourseLoadRequested(branchId: widget.branchId));
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      body: BlocListener<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is CourseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is CourseLoaded) {
              if (state.courses.isEmpty) {
                return _buildEmptyState();
              }
              
              // Auto-select first course if none selected
              if (selectedCourse == null && state.courses.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    selectedCourse = state.courses.first;
                  });
                });
              }
              
              return isDesktop 
                  ? _buildDesktopLayout(state.courses)
                  : _buildMobileLayout(state.courses);
            }
            
            if (state is CourseError) {
              return _buildErrorState(state.message);
            }
            
            return const Center(child: Text('No courses available'));
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(List<CourseModel> courses) {
    return Row(
      children: [
        // Left sidebar with course list
        SizedBox(
          width: 350,
          child: CourseListWidget(
            courses: courses,
            selectedCourse: selectedCourse,
            onCourseSelected: (course) {
              setState(() {
                selectedCourse = course;
              });
            },
            onCourseEdit: _showEditCourseDialog,
            onCourseDelete: _deleteCourse,
            onCreateCourse: () => _showCreateCourseDialog(context),
          ),
        ),
        // Vertical divider
        const VerticalDivider(width: 1),
        // Right side with course details
        Expanded(
          child: selectedCourse != null
              ? CourseDetailWidget(course: selectedCourse!)
              : const Center(
                  child: Text(
                    'Select a course to view details',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<CourseModel> courses) {
    return selectedCourse == null
        ? CourseListWidget(
            courses: courses,
            selectedCourse: null,
            onCourseSelected: (course) {
              setState(() {
                selectedCourse = course;
              });
            },
            onCourseEdit: _showEditCourseDialog,
            onCourseDelete: _deleteCourse,
            onCreateCourse: () => _showCreateCourseDialog(context),
          )
        : Column(
            children: [
              // Back button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedCourse = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to List'),
                ),
              ),
              // Course details
              Expanded(
                child: CourseDetailWidget(course: selectedCourse!),
              ),
            ],
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No courses available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first course to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateCourseDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
          ),
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
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
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
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshCourses,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _refreshCourses() {
    context.read<CourseBloc>().add(CourseRefreshRequested(branchId: widget.branchId));
  }

  int _getBranchId() {
    return widget.branchId ?? selectedCourse?.branchId ?? 1; // fallback to 1 if no branch ID available
  }

  void _showCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CourseBloc>(),
        child: CourseFormDialog(
          branchId: _getBranchId(),
        ),
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CourseBloc>(),
        child: CourseFormDialog(
          course: course,
          branchId: course.branchId,
        ),
      ),
    );
  }

  void _deleteCourse(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CourseBloc>().add(CourseDeleteRequested(course.id));
              // Clear selected course if it's being deleted
              if (selectedCourse?.id == course.id) {
                setState(() {
                  selectedCourse = null;
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}