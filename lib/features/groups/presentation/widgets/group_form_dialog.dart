import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_bloc.dart';
import '../../data/models/group_model.dart';

class GroupFormDialog extends StatefulWidget {
  final GroupModel? group;
  final int? courseId;
  final int? branchId;

  const GroupFormDialog({
    super.key,
    this.group,
    this.courseId,
    this.branchId,
  });

  @override
  State<GroupFormDialog> createState() => _GroupFormDialogState();
}

class _GroupFormDialogState extends State<GroupFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.group!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
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
                  Icon(
                    isEditing ? Icons.edit : Icons.group_add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Group' : 'Create New Group',
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
            ),
            
            // Form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      
                      // Course and Branch info display
                      if (!isEditing) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Branch ID: ${widget.branchId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
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
            
            // Action Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    if (isEditing) {
      context.read<GroupBloc>().add(
        GroupUpdateRequested(
          id: widget.group!.id,
          name: name,
          courseId: widget.group!.courseId,
          branchId: widget.group!.branchId,
        ),
      );
    } else {
      context.read<GroupBloc>().add(
        GroupCreateRequested(
          name: name,
          courseId: widget.courseId!,
          branchId: widget.branchId!,
        ),
      );
    }
  }
}