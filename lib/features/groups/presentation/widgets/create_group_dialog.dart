import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';

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
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          maxHeight: isDesktop ? 700 : double.infinity,
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
            
            // Teacher Selection
            DropdownButtonFormField<int>(
              value: _selectedTeacherId,
              decoration: const InputDecoration(
                labelText: 'Teacher',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: const [], // TODO: Load teachers from API
              onChanged: (value) {
                setState(() {
                  _selectedTeacherId = value;
                });
              },
              hint: const Text('Select a teacher (optional)'),
            ),
            const SizedBox(height: 16),
            
            // Time Selection - Responsive layout
            if (isDesktop || isTablet)
              Row(
                children: [
                  Expanded(child: _buildTimeField(context, 'Start Time', _startTime, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField(context, 'End Time', _endTime, false)),
                ],
              )
            else
              Column(
                children: [
                  _buildTimeField(context, 'Start Time', _startTime, true),
                  const SizedBox(height: 16),
                  _buildTimeField(context, 'End Time', _endTime, false),
                ],
              ),
            const SizedBox(height: 16),
            
            // Days of Week Selection
            const Text(
              'Days of Week',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDaysSelection(isDesktop, isTablet),
            const SizedBox(height: 16),
            
            // Course and Branch info
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context, String label, TimeOfDay? time, bool isStartTime) {
    return InkWell(
      onTap: () => _selectTime(context, isStartTime),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          time?.format(context) ?? 'Select $label',
          style: TextStyle(
            color: time != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
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
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    
    // Format time to HH:mm
    String? startTime;
    String? endTime;
    if (_startTime != null) {
      startTime = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
    }
    if (_endTime != null) {
      endTime = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
    }

    context.read<GroupBloc>().add(
      GroupCreateRequested(
        name: name,
        courseId: widget.courseId,
        branchId: widget.branchId,
        teacherId: _selectedTeacherId,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: _selectedDays.isNotEmpty ? _selectedDays : null,
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