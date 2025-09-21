import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/teacher_salary_bloc.dart';
import '../../data/models/salary_calculation_model.dart';

class SalaryPaymentPage extends StatefulWidget {
  final int? branchId;

  const SalaryPaymentPage({super.key, this.branchId});

  @override
  State<SalaryPaymentPage> createState() => _SalaryPaymentPageState();
}

class _SalaryPaymentPageState extends State<SalaryPaymentPage> {
  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    context.read<TeacherSalaryBloc>().add(
      SalaryPaymentsByBranchRequested(branchId: widget.branchId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocListener<TeacherSalaryBloc, TeacherSalaryState>(
              listener: (context, state) {
                if (state is TeacherSalaryOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  _loadPayments(); // Refresh data
                } else if (state is TeacherSalaryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<TeacherSalaryBloc, TeacherSalaryState>(
                builder: (context, state) {
                  if (state is TeacherSalaryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TeacherSalaryPaymentsLoaded) {
                    return _buildPaymentsList(state.payments);
                  }

                  if (state is TeacherSalaryError) {
                    return _buildErrorState(state.message);
                  }

                  return const Center(
                    child: Text(
                      'No payment data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.payment, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Salary Payments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _loadPayments,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList(List<TeacherSalaryPaymentModel> payments) {
    if (payments.isEmpty) {
      return _buildEmptyState();
    }

    // Group payments by month for better organization
    final groupedPayments = <String, List<TeacherSalaryPaymentModel>>{};
    for (final payment in payments) {
      final key = DateFormat('MMMM yyyy').format(DateTime(payment.year, payment.month));
      groupedPayments.putIfAbsent(key, () => []).add(payment);
    }

    // Sort months in descending order
    final sortedKeys = groupedPayments.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(payments),
          const SizedBox(height: 32),
          
          Text(
            'Payment History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          ...sortedKeys.map((monthYear) {
            final monthPayments = groupedPayments[monthYear]!;
            return _buildMonthSection(monthYear, monthPayments);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(List<TeacherSalaryPaymentModel> payments) {
    final totalAmount = payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    final thisMonthPayments = payments.where((payment) {
      final now = DateTime.now();
      return payment.year == now.year && payment.month == now.month;
    }).toList();
    final thisMonthAmount = thisMonthPayments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    
    // Get unique teachers count
    final uniqueTeachers = payments.map((p) => p.teacherId).toSet().length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Payments',
            '\$${NumberFormat('#,##0.00').format(totalAmount)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'This Month',
            '\$${NumberFormat('#,##0.00').format(thisMonthAmount)}',
            Icons.calendar_month,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Teachers Paid',
            '$uniqueTeachers',
            Icons.people,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Total Transactions',
            '${payments.length}',
            Icons.receipt_long,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String monthYear, List<TeacherSalaryPaymentModel> payments) {
    final totalAmount = payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthYear,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payments.length} payments • ${NumberFormat('#,##0.00').format(totalAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentTile(payment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(TeacherSalaryPaymentModel payment) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.payment,
          color: Colors.green,
          size: 24,
        ),
      ),
      title: Text(
        payment.teacherName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                payment.branchName,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(payment.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (payment.description != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.note, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    payment.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            NumberFormat('#,##0.00').format(payment.amount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(payment);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: Colors.grey[400],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.payment_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payments Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No salary payments have been made yet.\nPayments will appear here once created.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPayments,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TeacherSalaryPaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Payment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this payment?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Teacher: ${payment.teacherName}'),
                  Text('Amount: ${NumberFormat('#,##0.00').format(payment.amount)}'),
                  Text('Period: ${DateFormat('MMMM yyyy').format(DateTime(payment.year, payment.month))}'),
                  Text('Date: ${DateFormat('MMM dd, yyyy').format(payment.createdAt)}'),
                  if (payment.description != null)
                    Text('Description: ${payment.description}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone. The payment record will be permanently deleted.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocConsumer<TeacherSalaryBloc, TeacherSalaryState>(
            listener: (context, state) {
              if (state is TeacherSalaryOperationSuccess) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              final isLoading = state is TeacherSalaryOperationLoading;
              
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<TeacherSalaryBloc>().add(
                          SalaryPaymentDeleteRequested(paymentId: payment.id),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Delete'),
              );
            },
          ),
        ],
      ),
    );
  }
}