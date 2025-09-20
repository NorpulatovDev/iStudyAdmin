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

class _CreatePaymentDialogState extends State<CreatePaymentDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int? _selectedCourseId;
  int? _selectedGroupId;
  int? _selectedStudentId;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  bool _isLoading = false;
  int _currentStep = 0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.preselectedCourseId;
    _selectedGroupId = widget.preselectedGroupId;
    _selectedStudentId = widget.preselectedStudentId;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<CourseBloc>().add(
      CourseLoadRequested(branchId: widget.branchId),
    );

    if (_selectedCourseId != null) {
      context.read<GroupBloc>().add(
        GroupLoadByCourseRequested(_selectedCourseId!),
      );
    }

    if (_selectedGroupId != null) {
      context.read<StudentBloc>().add(
        StudentLoadByGroupRequested(_selectedGroupId!),
      );
    }
  }

  void _onCourseSelected(int courseId) {
    setState(() {
      _selectedCourseId = courseId;
      _selectedGroupId = null;
      _selectedStudentId = null;
      _currentStep = 1;
    });
    
    context.read<GroupBloc>().add(
      GroupLoadByCourseRequested(courseId),
    );
  }

  void _onGroupSelected(int groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _selectedStudentId = null;
      _currentStep = 2;
    });
    
    context.read<StudentBloc>().add(
      StudentLoadByGroupRequested(groupId),
    );
  }

  void _onStudentSelected(int studentId) {
    setState(() {
      _selectedStudentId = studentId;
      _currentStep = 3;
    });
  }

  void _createPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCourseId == null || _selectedGroupId == null || _selectedStudentId == null) {
      _showErrorSnackBar('Please complete all selections');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final description = _descriptionController.text.trim();

    final request = CreatePaymentRequest(
      studentId: _selectedStudentId!,
      groupId: _selectedGroupId!,
      amount: amount,
      branchId: widget.branchId,
      description: description.isNotEmpty ? description : null,
      paymentYear: _selectedYear,
      paymentMonth: _selectedMonth,
    );

    context.read<PaymentBloc>().add(
      PaymentCreateRequested(request: request),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentOperationSuccess) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Payment created successfully!'),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is PaymentError) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(state.message);
        } else if (state is PaymentOperationLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.payments_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Payment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Add a new payment record',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: List.generate(4, (index) {
                        final isActive = index <= _currentStep;
                        final isCompleted = index < _currentStep;
                        
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: isActive 
                                  ? (isCompleted ? Colors.green : AppTheme.primaryColor)
                                  : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Payment Period Section
                            _buildSectionCard(
                              title: 'Payment Period',
                              icon: Icons.calendar_month,
                              color: Colors.blue,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Year',
                                      value: _selectedYear,
                                      items: List.generate(5, (index) {
                                        final year = DateTime.now().year - index;
                                        return DropdownMenuItem(
                                          value: year,
                                          child: Text(year.toString()),
                                        );
                                      }),
                                      onChanged: _isLoading ? null : (value) {
                                        setState(() => _selectedYear = value! as int);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Month',
                                      value: _selectedMonth,
                                      items: List.generate(12, (index) {
                                        return DropdownMenuItem(
                                          value: index + 1,
                                          child: Text(_months[index]),
                                        );
                                      }),
                                      onChanged: _isLoading ? null : (value) {
                                        setState(() => _selectedMonth = value! as int);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Course Selection
                            _buildSectionCard(
                              title: 'Step 1: Select Course',
                              icon: Icons.school,
                              color: _selectedCourseId != null ? Colors.green : AppTheme.primaryColor,
                              child: BlocBuilder<CourseBloc, CourseState>(
                                builder: (context, state) {
                                  if (state is CourseLoading) {
                                    return _buildLoadingWidget('Loading courses...');
                                  }
                                  
                                  if (state is CourseLoaded) {
                                    if (state.courses.isEmpty) {
                                      return _buildErrorWidget('No courses available');
                                    }
                                    
                                    return _buildCourseGrid(state.courses);
                                  }
                                  
                                  if (state is CourseError) {
                                    return _buildErrorWidget('Failed to load courses');
                                  }
                                  
                                  return _buildErrorWidget('Failed to load courses');
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Group Selection
                            if (_selectedCourseId != null) ...[
                              _buildSectionCard(
                                title: 'Step 2: Select Group',
                                icon: Icons.group,
                                color: _selectedGroupId != null ? Colors.green : AppTheme.primaryColor,
                                child: BlocBuilder<GroupBloc, GroupState>(
                                  builder: (context, state) {
                                    if (state is GroupLoading) {
                                      return _buildLoadingWidget('Loading groups...');
                                    }
                                    
                                    if (state is GroupLoaded) {
                                      if (state.groups.isEmpty) {
                                        return _buildErrorWidget('No groups available');
                                      }
                                      
                                      return _buildGroupGrid(state.groups);
                                    }
                                    
                                    if (state is GroupError) {
                                      return _buildErrorWidget('Failed to load groups');
                                    }
                                    
                                    return _buildLoadingWidget('Select a course first');
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Student Selection
                            if (_selectedGroupId != null) ...[
                              _buildSectionCard(
                                title: 'Step 3: Select Student',
                                icon: Icons.person,
                                color: _selectedStudentId != null ? Colors.green : AppTheme.primaryColor,
                                child: BlocBuilder<StudentBloc, StudentState>(
                                  builder: (context, state) {
                                    if (state is StudentLoading) {
                                      return _buildLoadingWidget('Loading students...');
                                    }
                                    
                                    if (state is StudentLoaded) {
                                      if (state.students.isEmpty) {
                                        return _buildErrorWidget('No students in this group');
                                      }
                                      
                                      return _buildStudentGrid(state.students);
                                    }
                                    
                                    if (state is StudentError) {
                                      return _buildErrorWidget('Failed to load students');
                                    }
                                    
                                    return _buildLoadingWidget('Loading students...');
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Payment Details
                            if (_selectedStudentId != null) ...[
                              _buildSectionCard(
                                title: 'Payment Details',
                                icon: Icons.attach_money,
                                color: Colors.orange,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      enabled: !_isLoading,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Payment Amount',
                                        prefixText: '\$ ',
                                        hintText: '0.00',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppTheme.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
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
                                    TextFormField(
                                      controller: _descriptionController,
                                      maxLines: 3,
                                      enabled: !_isLoading,
                                      decoration: InputDecoration(
                                        labelText: 'Description (Optional)',
                                        hintText: 'Enter payment description...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: AppTheme.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey[400]!),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading || _selectedStudentId == null ? null : _createPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Create Payment',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCourseGrid(List courses) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final isSelected = _selectedCourseId == course.id;
        
        return GestureDetector(
          onTap: _isLoading ? null : () => _onCourseSelected(course.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [Colors.green, Colors.green.withOpacity(0.8)]
                    : [Colors.grey[50]!, Colors.grey[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 16,
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${course.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupGrid(List groups) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: groups.map<Widget>((group) {
        final isSelected = _selectedGroupId == group.id;
        
        return GestureDetector(
          onTap: _isLoading ? null : () => _onGroupSelected(group.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [Colors.green, Colors.green.withOpacity(0.8)]
                    : [Colors.grey[50]!, Colors.grey[100]!],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudentGrid(List students) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isSelected = _selectedStudentId == student.id;
        
        return GestureDetector(
          onTap: _isLoading ? null : () => _onStudentSelected(student.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [Colors.green, Colors.green.withOpacity(0.8)]
                    : [Colors.grey[50]!, Colors.grey[100]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    student.firstName.isNotEmpty && student.lastName.isNotEmpty
                        ? '${student.firstName[0]}${student.lastName[0]}'
                        : 'S',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${student.firstName} ${student.lastName}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}