// lib/features/students/presentation/widgets/add_student_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../data/models/student_model.dart';
import '../bloc/student_bloc.dart';

class AddStudentDialog extends StatelessWidget {
  final int branchId;
  final StudentModel? student;
  final VoidCallback? onStudentAdded;

  const AddStudentDialog({
    super.key,
    required this.branchId,
    this.student,
    this.onStudentAdded,
  });

  bool get isEditing => student != null;

  @override
  Widget build(BuildContext context) {
    // Trigger course loading immediately
    if (!isEditing) {
      context.read<CourseBloc>().add(CourseLoadRequested(branchId: branchId));
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 700,
        ),
        child: isEditing 
            ? _EditStudentForm(student: student!, onStudentAdded: onStudentAdded)
            : _AddStudentForm(branchId: branchId, onStudentAdded: onStudentAdded),
      ),
    );
  }
}

class _EditStudentForm extends StatefulWidget {
  final StudentModel student;
  final VoidCallback? onStudentAdded;

  const _EditStudentForm({
    required this.student,
    this.onStudentAdded,
  });

  @override
  State<_EditStudentForm> createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<_EditStudentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _parentPhoneNumberController;
  
  List<int> _selectedGroupIds = [];
  bool _isLoadingAllGroups = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student.firstName);
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _phoneNumberController = TextEditingController(text: widget.student.phoneNumber ?? '');
    _parentPhoneNumberController = TextEditingController(text: widget.student.parentPhoneNumber ?? '');
    
    // Initialize with current group enrollments
    _selectedGroupIds = List.from(widget.student.groupIds ?? []);
    
    // Load all groups for the branch to show enrollment options
    _loadAllGroups();
  }

  void _loadAllGroups() {
    setState(() {
      _isLoadingAllGroups = true;
    });
    context.read<GroupBloc>().add(GroupLoadByBranchRequested(branchId: widget.student.branchId));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _parentPhoneNumberController.dispose();
    super.dispose();
  }

  void _onGroupToggled(int groupId, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedGroupIds.contains(groupId)) {
          _selectedGroupIds.add(groupId);
        }
      } else {
        _selectedGroupIds.remove(groupId);
      }
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final request = CreateStudentRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      parentPhoneNumber: _parentPhoneNumberController.text.trim(),
      branchId: widget.student.branchId,
      groupIds: _selectedGroupIds.isNotEmpty ? _selectedGroupIds : null,
    );

    context.read<StudentBloc>().add(StudentUpdateRequested(
      id: widget.student.id,
      request: request,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentOperationSuccess) {
              Navigator.pop(context);
              widget.onStudentAdded?.call();
            } else if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupLoaded) {
              setState(() {
                _isLoadingAllGroups = false;
              });
            } else if (state is GroupError) {
              setState(() {
                _isLoadingAllGroups = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load groups: ${state.message}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
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
                const Icon(Icons.edit, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Student',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Information Section
                    _buildSectionHeader('Student Information', Icons.person),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Student Phone *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _parentPhoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Phone *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Parent phone is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Group Enrollment Section
                    _buildSectionHeader('Group Enrollment', Icons.group),
                    const SizedBox(height: 16),
                    _buildGroupEnrollment(),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final isLoading = state is StudentOperationLoading;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Student'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupEnrollment() {
    if (_isLoadingAllGroups) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading groups...'),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoaded) {
          if (state.groups.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.group_off, color: Colors.orange[700], size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'No groups available',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create groups first to enroll students',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by course for better organization
          final groupsByCourse = <String, List<GroupModel>>{};
          for (final group in state.groups) {
            final courseName = group.courseName;
            groupsByCourse[courseName] = (groupsByCourse[courseName] ?? [])..add(group);
          }

          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Currently enrolled in ${_selectedGroupIds.length} group(s). Select/deselect to modify enrollment:',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: groupsByCourse.entries.map((entry) {
                        final courseName = entry.key;
                        final groups = entry.value;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.blue[50],
                              child: Row(
                                children: [
                                  Icon(Icons.school, size: 16, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    courseName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Groups in this course
                            ...groups.map((group) {
                              final isSelected = _selectedGroupIds.contains(group.id);
                              final wasOriginallyEnrolled = widget.student.groupIds?.contains(group.id) ?? false;
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Theme.of(context).primaryColor.withOpacity(0.05)
                                      : null,
                                  border: isSelected 
                                      ? Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 3))
                                      : null,
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (selected) {
                                    _onGroupToggled(group.id, selected ?? false);
                                  },
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          group.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      if (wasOriginallyEnrolled && !isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'REMOVING',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      else if (!wasOriginallyEnrolled && isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'ADDING',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${group.studentCount} students enrolled',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (group.teacherName != null)
                                        Text(
                                          'Teacher: ${group.teacherName}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is GroupError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Error loading groups',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadAllGroups,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AddStudentForm extends StatefulWidget {
  final int branchId;
  final VoidCallback? onStudentAdded;

  const _AddStudentForm({
    required this.branchId,
    this.onStudentAdded,
  });

  @override
  State<_AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<_AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _parentPhoneNumberController = TextEditingController();

  CourseModel? _selectedCourse;
  List<int> _selectedGroupIds = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _parentPhoneNumberController.dispose();
    super.dispose();
  }

  void _onCourseSelected(CourseModel course) {
    setState(() {
      _selectedCourse = course;
      _selectedGroupIds.clear();
    });
    context.read<GroupBloc>().add(GroupLoadByCourseRequested(course.id));
  }

  void _onGroupToggled(int groupId, bool selected) {
    setState(() {
      if (selected) {
        _selectedGroupIds.add(groupId);
      } else {
        _selectedGroupIds.remove(groupId);
      }
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one group'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final request = CreateStudentRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      parentPhoneNumber: _parentPhoneNumberController.text.trim(),
      branchId: widget.branchId,
      groupIds: _selectedGroupIds,
    );

    context.read<StudentBloc>().add(StudentCreateRequested(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentOperationSuccess) {
          Navigator.pop(context);
          widget.onStudentAdded?.call();
        } else if (state is StudentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
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
                const Expanded(
                  child: Text(
                    'Add New Student',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Information Section
                    _buildSectionHeader('Student Information', Icons.person),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Student Phone *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _parentPhoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Parent Phone *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Parent phone is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Course Selection Section
                    _buildSectionHeader('Select Course', Icons.school),
                    const SizedBox(height: 16),
                    _buildCourseSelection(),
                    const SizedBox(height: 32),

                    // Group Selection Section
                    _buildSectionHeader('Select Groups', Icons.group),
                    const SizedBox(height: 16),
                    _buildGroupSelection(),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final isLoading = state is StudentOperationLoading;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Student'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSelection() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CourseLoaded) {
          if (state.courses.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No courses available. Please create courses first.'),
            );
          }

          return DropdownButtonFormField<CourseModel>(
            value: _selectedCourse,
            decoration: const InputDecoration(
              labelText: 'Select Course *',
              border: OutlineInputBorder(),
            ),
            items: state.courses.map((course) {
              return DropdownMenuItem(
                value: course,
                child: Text('${course.name} - \$${course.price.toStringAsFixed(2)}'),
              );
            }).toList(),
            onChanged: (course) {
              if (course != null) {
                _onCourseSelected(course);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a course';
              }
              return null;
            },
          );
        }

        if (state is CourseError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Error loading courses: ${state.message}'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGroupSelection() {
    if (_selectedCourse == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Please select a course first to see available groups.'),
      );
    }

    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GroupLoaded) {
          if (state.groups.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('No groups available for this course.'),
            );
          }

          return Column(
            children: state.groups.map((group) {
              final isSelected = _selectedGroupIds.contains(group.id);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (selected) {
                  _onGroupToggled(group.id, selected ?? false);
                },
                title: Text(group.name),
                subtitle: Text('${group.studentCount} students enrolled'),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          );
        }

        if (state is GroupError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Error loading groups: ${state.message}'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}