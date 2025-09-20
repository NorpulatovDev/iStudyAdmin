// lib/features/payments/presentation/widgets/create_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../../data/models/payment_model.dart';

class CreatePaymentDialog extends StatefulWidget {
  final int branchId;
  final int? preselectedStudentId;
  final int? preselectedCourseId;
  final int? preselectedGroupId;

  const CreatePaymentDialog({
    super.key,
    required this.branchId,
    this.preselectedStudentId,
    this.preselectedCourseId,
    this.preselectedGroupId,
  });

  @override
  State<CreatePaymentDialog> createState() => _CreatePaymentDialogState();
}

class _CreatePaymentDialogState extends State<CreatePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCourseId;
  int? _selectedGroupId;
  int? _selectedStudentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.preselectedCourseId;
    _selectedGroupId = widget.preselectedGroupId;
    _selectedStudentId = widget.preselectedStudentId;
    _loadInitialData();
  }

  void _loadInitialData() {
    // Always load courses first
    context.read<CourseBloc>().add(
      CourseLoadRequested(branchId: widget.branchId),
    );

    // If we have a preselected course, load its groups
    if (_selectedCourseId != null) {
      context.read<GroupBloc>().add(
        GroupLoadByCourseRequested( _selectedCourseId!),
      );
    }

    // If we have a preselected group, load its students
    if (_selectedGroupId != null) {
      context.read<StudentBloc>().add(
        StudentLoadByGroupRequested( _selectedGroupId!),
      );
    }
  }

  void _onCourseSelected(int courseId) {
    setState(() {
      _selectedCourseId = courseId;
      _selectedGroupId = null; // Reset group selection
      _selectedStudentId = null; // Reset student selection
    });
    
    // Load groups for the selected course
    context.read<GroupBloc>().add(
      GroupLoadByCourseRequested( courseId),
    );
    
    // Auto-fill amount with course price
    final courseState = context.read<CourseBloc>().state;
    if (courseState is CourseLoaded) {
      final selectedCourse = courseState.courses.firstWhere(
        (course) => course.id == courseId,
      );
      _amountController.text = selectedCourse.price.toStringAsFixed(2);
    }
  }

  void _onGroupSelected(int groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _selectedStudentId = null; // Reset student selection
    });
    
    // Load students for the selected group
    context.read<StudentBloc>().add(
      StudentLoadByGroupRequested( groupId),
    );
  }

  void _createPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null || _selectedGroupId == null || _selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select course, group, and student'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final description = _descriptionController.text.trim();
    final now = DateTime.now();

    final request = CreatePaymentRequest(
      studentId: _selectedStudentId!,
      groupId: _selectedGroupId!,
      amount: amount,
      branchId: widget.branchId,
      description: description.isNotEmpty ? description : null,
      paymentYear: now.year,
      paymentMonth: now.month,
    );

    context.read<PaymentBloc>().add(
      PaymentCreateRequested(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentOperationSuccess) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        } else if (state is PaymentError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add New Payment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Step Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Follow the steps: Course → Group → Student',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Step 1: Course Selection
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedCourseId != null 
                              ? AppTheme.successColor 
                              : AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _selectedCourseId != null
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Course',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<CourseBloc, CourseState>(
                    builder: (context, state) {
                      if (state is CourseLoading) {
                        return _buildLoadingDropdown('Loading courses...');
                      }
                      
                      if (state is CourseLoaded) {
                        return DropdownButtonFormField<int>(
                          value: _selectedCourseId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            hintText: 'Choose a course first',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a course';
                            }
                            return null;
                          },
                          items: state.courses.map((course) {
                            return DropdownMenuItem<int>(
                              value: course.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '\$${course.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: widget.preselectedCourseId != null 
                              ? null 
                              : (value) {
                                  if (value != null) {
                                    _onCourseSelected(value);
                                  }
                                },
                        );
                      }
                      
                      return _buildErrorDropdown('Failed to load courses');
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Step 2: Group Selection
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedGroupId != null 
                              ? AppTheme.successColor 
                              : (_selectedCourseId != null 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey[400]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _selectedGroupId != null
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : const Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Group',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      if (_selectedCourseId == null) {
                        return _buildDisabledDropdown('Select a course first');
                      }
                      
                      if (state is GroupLoading) {
                        return _buildLoadingDropdown('Loading groups...');
                      }
                      
                      if (state is GroupLoaded) {
                        if (state.groups.isEmpty) {
                          return _buildErrorDropdown('No groups available for this course');
                        }
                        
                        return DropdownButtonFormField<int>(
                          value: _selectedGroupId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            hintText: 'Choose a group',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a group';
                            }
                            return null;
                          },
                          items: state.groups.map((group) {
                            return DropdownMenuItem<int>(
                              value: group.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    group.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // if (group.description != null)
                                  //   Text(
                                  //     group.description!,
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: Colors.grey[600],
                                  //     ),
                                  //   ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: widget.preselectedGroupId != null 
                              ? null 
                              : (value) {
                                  if (value != null) {
                                    _onGroupSelected(value);
                                  }
                                },
                        );
                      }
                      
                      if (state is GroupError) {
                        return _buildErrorDropdown('Failed to load groups');
                      }
                      
                      return _buildDisabledDropdown('Select a course first');
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Step 3: Student Selection
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedStudentId != null 
                              ? AppTheme.successColor 
                              : (_selectedGroupId != null 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey[400]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _selectedStudentId != null
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Student',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, state) {
                      if (_selectedGroupId == null) {
                        return _buildDisabledDropdown('Select a group first');
                      }
                      
                      if (state is StudentLoading) {
                        return _buildLoadingDropdown('Loading students...');
                      }
                      
                      if (state is StudentLoaded) {
                        if (state.students.isEmpty) {
                          return _buildErrorDropdown('No students in this group');
                        }
                        
                        return DropdownButtonFormField<int>(
                          value: _selectedStudentId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            hintText: 'Choose a student',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a student';
                            }
                            return null;
                          },
                          items: state.students.map((student) {
                            return DropdownMenuItem<int>(
                              value: student.id,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    child: Text(
                                      '${student.firstName[0]}${student.lastName[0]}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${student.firstName} ${student.lastName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: widget.preselectedStudentId != null 
                              ? null 
                              : (value) {
                                  setState(() {
                                    _selectedStudentId = value;
                                  });
                                },
                        );
                      }
                      
                      if (state is StudentError) {
                        return _buildErrorDropdown('Failed to load students');
                      }
                      
                      return _buildDisabledDropdown('Select a group first');
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Amount Field
                  const Text(
                    'Payment Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixText: '\$ ',
                      hintText: '0.00',
                      suffixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Field (Optional)
                  const Text(
                    'Description (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter payment description...',
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isLoading 
                              ? null 
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Create Payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String text) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown(String text) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red[50],
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledDropdown(String text) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.grey[500], size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}