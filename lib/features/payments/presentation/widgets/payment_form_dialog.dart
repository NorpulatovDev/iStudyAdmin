import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../groups/presentation/bloc/group_bloc.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../students/presentation/bloc/student_bloc.dart';
import '../../../students/data/models/student_model.dart';

class PaymentFormDialog extends StatefulWidget {
  final PaymentModel? payment; // For editing existing payment
  final int? prefilledStudentId;
  final int? prefilledGroupId;
  final double? prefilledAmount;

  const PaymentFormDialog({
    super.key,
    this.payment,
    this.prefilledStudentId,
    this.prefilledGroupId,
    this.prefilledAmount,
  });

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // Dropdown selections
  CourseModel? _selectedCourse;
  GroupModel? _selectedGroup;
  StudentModel? _selectedStudent;

  // Data lists
  List<CourseModel> _courses = [];
  List<GroupModel> _groups = [];
  List<StudentModel> _students = [];

  // Loading states
  bool _isLoadingCourses = false;
  bool _isLoadingGroups = false;
  bool _isLoadingStudents = false;

  bool get isEditing => widget.payment != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    if (!isEditing) {
      _loadCourses();
    }
  }

  void _initializeForm() {
    if (isEditing) {
      // Editing existing payment (only amount can be changed)
      _amountController.text = widget.payment!.amount.toString();
      _descriptionController.text = widget.payment!.description ?? '';
    } else {
      // Creating new payment with prefilled data
      if (widget.prefilledAmount != null) {
        _amountController.text = widget.prefilledAmount.toString();
      }
    }
  }

  void _loadCourses() async {
    setState(() => _isLoadingCourses = true);
    context.read<CourseBloc>().add(const CourseLoadRequested());
  }

  void _loadGroupsByCourse(int courseId) async {
    setState(() {
      _isLoadingGroups = true;
      _selectedGroup = null;
      _selectedStudent = null;
      _groups = [];
      _students = [];
    });
    context.read<GroupBloc>().add(GroupLoadByCourseRequested(courseId));
  }

  void _loadStudentsByGroup(int groupId) async {
    setState(() {
      _isLoadingStudents = true;
      _selectedStudent = null;
      _students = [];
    });
    context.read<StudentBloc>().add(StudentLoadByGroupRequested(groupId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CourseBloc, CourseState>(
          listener: (context, state) {
            if (state is CourseLoaded) {
              setState(() {
                _courses = state.courses;
                _isLoadingCourses = false;
              });

              // Auto-select if prefilled course info is available
              if (widget.prefilledGroupId != null && _courses.isNotEmpty) {
                // Find course by checking groups (this would need group data)
                _loadCourses(); // For now, just load courses
              }
            } else if (state is CourseError) {
              setState(() => _isLoadingCourses = false);
              _showErrorSnackBar('Failed to load courses: ${state.message}');
            }
          },
        ),
        BlocListener<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupLoaded) {
              setState(() {
                _groups = state.groups;
                _isLoadingGroups = false;
              });

              // Auto-select if prefilled group ID is available
              if (widget.prefilledGroupId != null && _groups.isNotEmpty) {
                final prefilledGroup = _groups.firstWhere(
                  (group) => group.id == widget.prefilledGroupId,
                  orElse: () => _groups.first,
                );
                setState(() => _selectedGroup = prefilledGroup);
                _loadStudentsByGroup(prefilledGroup.id);
              }
            } else if (state is GroupError) {
              setState(() => _isLoadingGroups = false);
              _showErrorSnackBar('Failed to load groups: ${state.message}');
            }
          },
        ),
        BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentLoaded) {
              setState(() {
                _students = state.students;
                _isLoadingStudents = false;
              });

              // Auto-select if prefilled student ID is available
              if (widget.prefilledStudentId != null && _students.isNotEmpty) {
                final prefilledStudent = _students.firstWhere(
                  (student) => student.id == widget.prefilledStudentId,
                  orElse: () => _students.first,
                );
                setState(() => _selectedStudent = prefilledStudent);
              }
            } else if (state is StudentError) {
              setState(() => _isLoadingStudents = false);
              _showErrorSnackBar('Failed to load students: ${state.message}');
            }
          },
        ),
      ],
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(child: _buildForm()),
              _buildActionButtons(),
            ],
          ),
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
          Icon(
            isEditing ? Icons.edit : Icons.add,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Payment Amount' : 'Create New Payment',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditing) ...[
              // Show payment details for editing
              _buildReadOnlyField('Student', widget.payment!.studentName),
              const SizedBox(height: 16),
              _buildReadOnlyField('Course', widget.payment!.courseName),
              const SizedBox(height: 16),
              if (widget.payment!.groupName != null)
                _buildReadOnlyField('Group', widget.payment!.groupName!),
              const SizedBox(height: 16),
            ] else ...[
              // Course selection dropdown
              _buildDropdownField<CourseModel>(
                label: 'Select Course *',
                value: _selectedCourse,
                items: _courses,
                isLoading: _isLoadingCourses,
                itemBuilder: (course) => DropdownMenuItem<CourseModel>(
                  value: course,
                  child: Text(
                    course.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                onChanged: (course) {
                  setState(() {
                    _selectedCourse = course;
                    _selectedGroup = null;
                    _selectedStudent = null;
                  });
                  if (course != null) {
                    _loadGroupsByCourse(course.id);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a course' : null,
              ),

              const SizedBox(height: 16),

              // Group selection dropdown
              _buildDropdownField<GroupModel>(
                label: 'Select Group *',
                value: _selectedGroup,
                items: _groups,
                isLoading: _isLoadingGroups,
                enabled: _selectedCourse != null && !_isLoadingGroups,
                itemBuilder: (group) => DropdownMenuItem<GroupModel>(
                  value: group,
                  child: Text(
                    group.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                onChanged: (group) {
                  setState(() {
                    _selectedGroup = group;
                    _selectedStudent = null;
                  });
                  if (group != null) {
                    _loadStudentsByGroup(group.id);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a group' : null,
              ),

              const SizedBox(height: 16),

              // Student selection dropdown
              _buildDropdownField<StudentModel>(
                label: 'Select Student *',
                value: _selectedStudent,
                items: _students,
                isLoading: _isLoadingStudents,
                enabled: _selectedGroup != null && !_isLoadingStudents,
                itemBuilder: (student) => DropdownMenuItem<StudentModel>(
                  value: student,
                  child: Text(
                    '${student.firstName} ${student.lastName}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                onChanged: (student) {
                  setState(() => _selectedStudent = student);
                },
                validator: (value) =>
                    value == null ? 'Please select a student' : null,
              ),

              const SizedBox(height: 16),

              // Payment date selector
              _buildDateSelector(),

              const SizedBox(height: 16),
            ],

            // Amount field (always editable)
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: 'Enter payment amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter payment description',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            if (!isEditing) ...[
              const SizedBox(height: 16),

              // Information card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                        Icon(Icons.info, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select the course first, then choose the group, and finally select the student. The payment date determines the month/year for which this payment is recorded.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required DropdownMenuItem<T> Function(T) itemBuilder,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
    bool isLoading = false,
    bool enabled = true,
    String? emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : enabled && items.isEmpty && emptyMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              emptyMessage,
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<T>(
                      value: value,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      hint: Text(
                        enabled
                            ? (items.isEmpty
                                ? 'No options available'
                                : 'Select an option')
                            : 'Select previous options first',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      items: enabled && items.isNotEmpty
                          ? items.map(itemBuilder).toList()
                          : [],
                      onChanged: enabled && items.isNotEmpty ? onChanged : null,
                      validator: validator,
                      isExpanded: true,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Date *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentOperationSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentLoading;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
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
                    : Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.trim();

    if (isEditing) {
      // Update payment amount
      context.read<PaymentBloc>().add(UpdatePaymentAmount(
            id: widget.payment!.id,
            amount: amount,
          ));
    } else {
      // Create new payment
      if (_selectedStudent == null || _selectedGroup == null) {
        _showErrorSnackBar('Please select student and group');
        return;
      }

      context.read<PaymentBloc>().add(CreatePayment(
            studentId: _selectedStudent!.id,
            groupId: _selectedGroup!.id,
            amount: amount,
            description: description.isNotEmpty ? description : null,
            paymentYear: _selectedDate.year,
            paymentMonth: _selectedDate.month,
          ));
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
