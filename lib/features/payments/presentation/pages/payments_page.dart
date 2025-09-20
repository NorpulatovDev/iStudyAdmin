// lib/features/payments/presentation/pages/payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../widgets/payment_card.dart';
import '../widgets/payment_filter_bottom_sheet.dart';
import '../widgets/create_payment_dialog.dart';

class PaymentsPage extends StatefulWidget {
  final int? studentId;
  final String? studentName;

  const PaymentsPage({super.key, this.studentId, this.studentName});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  int? _currentBranchId;
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = 'All Payments';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentBranchId = authState.user.branchId;

      if (widget.studentId != null) {
        // Load payments for specific student
        context.read<PaymentBloc>().add(
              PaymentLoadByStudentRequested(widget.studentId!),
            );
      } else {
        // Load all payments for branch
        context.read<PaymentBloc>().add(
              PaymentLoadByBranchRequested(branchId: _currentBranchId),
            );
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentFilterBottomSheet(
        branchId: _currentBranchId!,
        onFilterApplied: (filter, filterType) {
          setState(() {
            _currentFilter = filter;
          });
        },
      ),
    );
  }

  void _showCreatePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => CreatePaymentDialog(
        branchId: _currentBranchId!,
        preselectedStudentId: widget.studentId,
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _initializePage();
      return;
    }

    context.read<PaymentBloc>().add(
          PaymentSearchRequested(
            branchId: _currentBranchId!,
            studentName: query,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: widget.studentId != null
          ? AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Payments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.studentName != null)
                    Text(
                      widget.studentName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: widget.studentName != null ? 70 : 56,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<PaymentBloc>().add(
                          PaymentRefreshRequested(studentId: widget.studentId),
                        );
                  },
                  tooltip: 'Refresh payments',
                ),
              ],
            )
          : null, // No appbar if from drawer (MainLayout handles it)

      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by student name...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _initializePage();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppTheme.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: _performSearch,
                ),

                const SizedBox(height: 12),

                // Filter and Add Payment Row
                Row(
                  children: [
                    // Filter Button
                    if (widget.studentId == null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showFilterOptions,
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: Text(
                            _currentFilter,
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side:
                                const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    if (widget.studentId == null) const SizedBox(width: 12),

                    // Add Payment Button
                    ElevatedButton.icon(
                      onPressed: _showCreatePaymentDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is PaymentOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(state.message),
                        ],
                      ),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              child: BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading ||
                      state is PaymentOperationLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading payments...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PaymentError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Something went wrong',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _initializePage,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is PaymentLoaded) {
                    if (state.payments.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.payment_outlined,
                                  size: 64,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.studentId != null
                                    ? 'No payments found'
                                    : 'No payments yet',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.studentId != null
                                    ? 'This student hasn\'t made any payments yet'
                                    : 'Create your first payment record to get started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _showCreatePaymentDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Payment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Summary header
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.payment,
                                  color: AppTheme.successColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${state.payments.length} payment(s)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Total: ${state.payments.fold<double>(0, (sum, payment) => sum + payment.amount).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Payments list
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (widget.studentId != null) {
                                context.read<PaymentBloc>().add(
                                      PaymentRefreshRequested(
                                          studentId: widget.studentId),
                                    );
                              } else {
                                context.read<PaymentBloc>().add(
                                      PaymentRefreshRequested(
                                          branchId: _currentBranchId),
                                    );
                              }
                            },
                            color: AppTheme.primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.payments.length,
                              itemBuilder: (context, index) {
                                final payment = state.payments[index];
                                return PaymentCard(payment: payment);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
