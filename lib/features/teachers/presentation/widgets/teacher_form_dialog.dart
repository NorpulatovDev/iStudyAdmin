// lib/features/teachers/presentation/widgets/teacher_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class TeacherFormDialog extends StatefulWidget {
  final int branchId;
  final TeacherModel? teacher; // null for create, not null for edit
  final void Function(
    String firstName,
    String lastName,
    String? phoneNumber,
    double baseSalary,
    double paymentPercentage,
    SalaryType salaryType,
  ) onSubmit;

  const TeacherFormDialog({
    super.key,
    required this.branchId,
    required this.onSubmit,
    this.teacher,
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

  bool get _isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final teacher = widget.teacher!;
      _firstNameController.text = teacher.firstName;
      _lastNameController.text = teacher.lastName;
      _phoneController.text = teacher.phoneNumber ?? '';
      _baseSalaryController.text = teacher.baseSalary.toString();
      _paymentPercentageController.text = teacher.paymentPercentage.toString();
      _selectedSalaryType = SalaryType.values.firstWhere(
        (type) => type.name == teacher.salaryType,
        orElse: () => SalaryType.FIXED,
      );
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phoneNumber = _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim();
      final baseSalary = double.parse(_baseSalaryController.text);
      final paymentPercentage = double.parse(_paymentPercentageController.text);

      widget.onSubmit(
        firstName,
        lastName,
        phoneNumber,
        baseSalary,
        paymentPercentage,
        _selectedSalaryType,
      );
      Navigator.of(context).pop();
    }
  }

  String _getSalaryTypeDescription(SalaryType type) {
    switch (type) {
      case SalaryType.FIXED:
        return 'Teacher receives only base salary';
      case SalaryType.PERCENTAGE:
        return 'Teacher receives percentage of student payments';
      case SalaryType.MIXED:
        return 'Teacher receives both base salary and percentage';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isEditing ? Icons.edit : Icons.person_add,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(_isEditing ? 'Edit Teacher' : 'Add Teacher'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name*',
                    hintText: 'Enter first name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name*',
                    hintText: 'Enter last name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number (optional)',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                  ],
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length < 10) {
                        return 'Phone number must be at least 10 digits';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Salary Type Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Salary Type*',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...SalaryType.values.map((type) => RadioListTile<SalaryType>(
                        title: Text(
                          type.name.replaceAll('_', ' '),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _getSalaryTypeDescription(type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: type,
                        groupValue: _selectedSalaryType,
                        onChanged: (value) {
                          setState(() {
                            _selectedSalaryType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.primaryColor,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Base Salary (shown for FIXED and MIXED)
                if (_selectedSalaryType == SalaryType.FIXED || 
                    _selectedSalaryType == SalaryType.MIXED) ...[
                  TextFormField(
                    controller: _baseSalaryController,
                    decoration: InputDecoration(
                      labelText: 'Base Salary*',
                      hintText: 'Enter monthly base salary',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: 'USD',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (_selectedSalaryType == SalaryType.FIXED || 
                          _selectedSalaryType == SalaryType.MIXED) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Base salary is required for this salary type';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null) {
                          return 'Please enter a valid salary amount';
                        }
                        if (salary < 0) {
                          return 'Salary cannot be negative';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Payment Percentage (shown for PERCENTAGE and MIXED)
                if (_selectedSalaryType == SalaryType.PERCENTAGE || 
                    _selectedSalaryType == SalaryType.MIXED) ...[
                  TextFormField(
                    controller: _paymentPercentageController,
                    decoration: InputDecoration(
                      labelText: 'Payment Percentage*',
                      hintText: 'Enter percentage of student payments',
                      prefixIcon: const Icon(Icons.percent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (_selectedSalaryType == SalaryType.PERCENTAGE || 
                          _selectedSalaryType == SalaryType.MIXED) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Payment percentage is required for this salary type';
                        }
                        final percentage = double.tryParse(value);
                        if (percentage == null) {
                          return 'Please enter a valid percentage';
                        }
                        if (percentage < 0 || percentage > 100) {
                          return 'Percentage must be between 0 and 100';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Set default values for hidden fields
                if (_selectedSalaryType == SalaryType.PERCENTAGE) ...[
                  // Set base salary to 0 for percentage-only
                  Builder(builder: (context) {
                    if (_baseSalaryController.text.isEmpty) {
                      _baseSalaryController.text = '0';
                    }
                    return const SizedBox.shrink();
                  }),
                ],

                if (_selectedSalaryType == SalaryType.FIXED) ...[
                  // Set payment percentage to 0 for fixed-only
                  Builder(builder: (context) {
                    if (_paymentPercentageController.text.isEmpty) {
                      _paymentPercentageController.text = '0';
                    }
                    return const SizedBox.shrink();
                  }),
                ],

                // Info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
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
                          'Fields marked with * are required. Salary type determines how the teacher is compensated.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}