// lib/features/groups/presentation/widgets/create_group_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../../teachers/presentation/bloc/teacher_bloc.dart';
import '../../../teachers/data/models/teacher_model.dart';

class CreateGroupDialog extends StatefulWidget {
  final int courseId;
  final int branchId;

  const CreateGroupDialog({
    super.key,
    required this.courseId,
    required this.branchId,
  });

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  int? _selectedTeacherId;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<String> _selectedDays = [];
  
  final List<String> _daysOfWeek = [
    'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
  ];

  @override
  void initState() {
    super.initState();
    // Load teachers for the current branch when dialog opens
    _loadTeachers();
  }

  void _loadTeachers() {
    context.read<TeacherBloc>().add(
      TeacherLoadByBranchRequested(branchId: widget.branchId),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Custom validator for time fields
  String? _validateTime(TimeOfDay? time, String fieldName) {
    if (time == null) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate that start time is before end time
  String? _validateTimeOrder() {
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      
      if (startMinutes >= endMinutes) {
        return 'Start time must be before end time';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 800;
    final isTablet = screenWidth > 600 && screenWidth <= 800;
    
    return Dialog(
      insetPadding: EdgeInsets.all(isDesktop ? 40 : 16),
      child: Container(
        width: double.infinity,
        height: isDesktop ? null : screenHeight * 0.9,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: isDesktop ? 750 : double.infinity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(child: _buildForm(context, isDesktop, isTablet)),
            _buildActionButtons(context, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Icon(Icons.group_add, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Create New Group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name *',
                hintText: 'Enter group name',
                prefixIcon: Icon(Icons.groups),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Group name is required';
                }
                if (value.trim().length < 2) {
                  return 'Group name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Teacher Selection - Now Required
            _buildTeacherDropdown(),
            const SizedBox(height: 16),
            
            // Time Selection - Now Required - Responsive layout
            if (isDesktop || isTablet)
              Row(
                children: [
                  Expanded(child: _buildRequiredTimeField(context, 'Start Time *', _startTime, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRequiredTimeField(context, 'End Time *', _endTime, false)),
                ],
              )
            else
              Column(
                children: [
                  _buildRequiredTimeField(context, 'Start Time *', _startTime, true),
                  const SizedBox(height: 16),
                  _buildRequiredTimeField(context, 'End Time *', _endTime, false),
                ],
              ),
            
            // Show time validation error if needed
            if (_startTime != null && _endTime != null && _validateTimeOrder() != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _validateTimeOrder()!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Days of Week Selection
            const Text(
              'Days of Week *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDaysSelection(isDesktop, isTablet),
            
            // Show days validation error
            if (_selectedDays.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select at least one day',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Course and Branch info
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherDropdown() {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading) {
          return Container(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('Loading teachers...'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        } else if (state is TeacherLoaded) {
          final teachers = state.teachers;

          return DropdownButtonFormField<int?>(
            value: _selectedTeacherId,
            decoration: InputDecoration(
              labelText: 'Teacher *',
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
              errorBorder: _selectedTeacherId == null ? OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              ) : null,
              suffixIcon: teachers.isEmpty 
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadTeachers,
                    tooltip: 'Refresh teachers',
                  )
                : null,
            ),
            items: [
              // Remove the "No teacher assigned" option
              ...teachers.map((teacher) {
                return DropdownMenuItem<int?>(
                  value: teacher.id,
                  child: Text('${teacher.firstName} ${teacher.lastName}'),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTeacherId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a teacher';
              }
              return null;
            },
            hint: Text(teachers.isEmpty 
              ? 'No teachers available - Create a teacher first' 
              : 'Select a teacher'),
          );
        } else if (state is TeacherError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  leading: Icon(Icons.error, color: Colors.red[700]),
                  title: const Text('Error loading teachers'),
                  subtitle: Text(
                    state.message,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadTeachers,
                    tooltip: 'Retry loading teachers',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Teacher selection is required to create a group',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        // Initial state - show loading dropdown
        return DropdownButtonFormField<int?>(
          value: _selectedTeacherId,
          decoration: const InputDecoration(
            labelText: 'Teacher *',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: const [],
          onChanged: null, // Disabled while loading
          hint: const Text('Loading teachers...'),
        );
      },
    );
  }

  // Updated time field that shows required validation
  Widget _buildRequiredTimeField(BuildContext context, String label, TimeOfDay? time, bool isStartTime) {
    final hasError = time == null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _selectTime(context, isStartTime),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.access_time),
              border: const OutlineInputBorder(),
              errorBorder: hasError ? OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
              ) : null,
              suffixIcon: time != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          if (isStartTime) {
                            _startTime = null;
                          } else {
                            _endTime = null;
                          }
                        });
                      },
                    )
                  : null,
            ),
            child: Text(
              time?.format(context) ?? 'Select ${label.replaceAll(' *', '')}',
              style: TextStyle(
                color: time != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              '${label.replaceAll(' *', '')} is required',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDaysSelection(bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _daysOfWeek.map((day) => _buildDayChip(day)).toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isTablet ? 4 : 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.5,
        children: _daysOfWeek.map((day) => _buildDayChip(day)).toList(),
      );
    }
  }

  Widget _buildDayChip(String day) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(
        day.substring(0, 3),
        style: const TextStyle(fontSize: 12),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
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
              const Text(
                'Group Information',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Course ID: ${widget.courseId}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            'Branch ID: ${widget.branchId}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupOperationLoading;
          
          return Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: isDesktop ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              if (!isDesktop) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Group'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ] else ...[
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
                      : const Text('Create Group'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _submitForm() {
    // Validate form fields (including teacher dropdown)
    if (!_formKey.currentState!.validate()) return;
    
    // Double-check teacher is selected (additional validation)
    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a teacher'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Validate required time fields
    if (_startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time is required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (_endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time is required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Validate time order
    if (_validateTimeOrder() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validateTimeOrder()!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Validate at least one day is selected
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    
    // Format time to HH:mm
    final startTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    final endTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    context.read<GroupBloc>().add(
      GroupCreateRequested(
        name: name,
        courseId: widget.courseId,
        branchId: widget.branchId,
        teacherId: _selectedTeacherId!, // Now guaranteed to be non-null
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: _selectedDays,
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }
}