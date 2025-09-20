import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherFormDialog extends StatefulWidget {
  final TeacherModel? teacher;
  final int? branchId;

  const TeacherFormDialog({
    super.key,
    this.teacher,
    this.branchId,
  });

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _baseSalaryController = TextEditingController();
  final _paymentPercentageController = TextEditingController();
  
  SalaryType _selectedSalaryType = SalaryType.FIXED;
  
  bool get isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _firstNameController.text = widget.teacher!.firstName;
      _lastNameController.text = widget.teacher!.lastName;
      _phoneController.text = widget.teacher!.phoneNumber ?? '';
      _baseSalaryController.text = widget.teacher!.baseSalary.toString();
      _paymentPercentageController.text = widget.teacher!.paymentPercentage.toString();
      
      // Parse salary type from string to enum
      switch (widget.teacher!.salaryType) {
        case 'FIXED':
          _selectedSalaryType = SalaryType.FIXED;
          break;
        case 'PERCENTAGE':
          _selectedSalaryType = SalaryType.PERCENTAGE;
          break;
        case 'MIXED':
          _selectedSalaryType = SalaryType.MIXED;
          break;
        default:
          _selectedSalaryType = SalaryType.FIXED;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _baseSalaryController.dispose();
    _paymentPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            isEditing ? Icons.edit : Icons.person_add,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Teacher' : 'Create New Teacher',
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
            // First Name and Last Name Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter first name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'First name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter last name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Last name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Phone Number
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  if (value.trim().length < 9) {
                    return 'Enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Salary Type Selection
            DropdownButtonFormField<SalaryType>(
              value: _selectedSalaryType,
              decoration: const InputDecoration(
                labelText: 'Salary Type *',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
              items: SalaryType.values.map((type) {
                String displayName;
                IconData icon;
                switch (type) {
                  case SalaryType.FIXED:
                    displayName = 'Fixed Salary';
                    icon = Icons.attach_money;
                    break;
                  case SalaryType.PERCENTAGE:
                    displayName = 'Percentage Based';
                    icon = Icons.percent;
                    break;
                  case SalaryType.MIXED:
                    displayName = 'Mixed (Fixed + Percentage)';
                    icon = Icons.compare_arrows;
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                      Text(displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSalaryType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Base Salary and Payment Percentage Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baseSalaryController,
                    decoration: InputDecoration(
                      labelText: _selectedSalaryType == SalaryType.PERCENTAGE 
                          ? 'Base Salary (optional)' 
                          : 'Base Salary *',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (_selectedSalaryType != SalaryType.PERCENTAGE) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Base salary is required';
                        }
                      }
                      if (value != null && value.trim().isNotEmpty) {
                        final salary = double.tryParse(value);
                        if (salary == null || salary < 0) {
                          return 'Enter a valid salary';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _paymentPercentageController,
                    decoration: InputDecoration(
                      labelText: _selectedSalaryType == SalaryType.FIXED 
                          ? 'Payment % (optional)' 
                          : 'Payment % *',
                      hintText: '0.0',
                      prefixIcon: const Icon(Icons.percent),
                      border: const OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (_selectedSalaryType != SalaryType.FIXED) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Payment percentage is required';
                        }
                      }
                      if (value != null && value.trim().isNotEmpty) {
                        final percentage = double.tryParse(value);
                        if (percentage == null || percentage < 0 || percentage > 100) {
                          return 'Enter a valid percentage (0-100)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Salary Type Information Card
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
                        _getSalaryTypeTitle(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSalaryTypeDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Branch Information (if creating new teacher)
            if (!isEditing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Branch Assignment',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
    );
  }

  String _getSalaryTypeTitle() {
    switch (_selectedSalaryType) {
      case SalaryType.FIXED:
        return 'Fixed Salary Information';
      case SalaryType.PERCENTAGE:
        return 'Percentage-Based Salary Information';
      case SalaryType.MIXED:
        return 'Mixed Salary Information';
    }
  }

  String _getSalaryTypeDescription() {
    switch (_selectedSalaryType) {
      case SalaryType.FIXED:
        return 'Teacher receives a fixed monthly salary. Payment percentage is optional and used for bonus calculations.';
      case SalaryType.PERCENTAGE:
        return 'Teacher receives a percentage of student payments. Base salary is optional and used as minimum guarantee.';
      case SalaryType.MIXED:
        return 'Teacher receives both fixed base salary and percentage of student payments. Both fields are required.';
    }
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherOperationSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isLoading = state is TeacherOperationLoading;
          
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0.0;
    final paymentPercentage = double.tryParse(_paymentPercentageController.text) ?? 0.0;
    final branchId = widget.branchId ?? widget.teacher!.branchId;

    if (isEditing) {
      context.read<TeacherBloc>().add(
        TeacherUpdateRequested(
          id: widget.teacher!.id,
          firstName: firstName,
          lastName: lastName,
          branchId: branchId,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          baseSalary: baseSalary,
          paymentPercentage: paymentPercentage,
          salaryType: _selectedSalaryType,
        ),
      );
    } else {
      context.read<TeacherBloc>().add(
        TeacherCreateRequested(
          firstName: firstName,
          lastName: lastName,
          branchId: branchId,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          baseSalary: baseSalary,
          paymentPercentage: paymentPercentage,
          salaryType: _selectedSalaryType,
        ),
      );
    }
  }
}