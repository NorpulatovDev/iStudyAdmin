import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/teacher_salary_bloc.dart';
import '../../../teachers/presentation/bloc/teacher_bloc.dart';
import '../../../teachers/data/models/teacher_model.dart';
import '../../data/models/salary_calculation_model.dart';
import 'salary_calculation_page.dart';
import 'salary_payment_page.dart';

class SalaryPage extends StatefulWidget {
  final int? branchId;

  const SalaryPage({super.key, this.branchId});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load teachers for branch
    context.read<TeacherBloc>().add(
          TeacherLoadByBranchRequested(branchId: widget.branchId),
        );

    // Load salary calculations for current month
    context.read<TeacherSalaryBloc>().add(
          SalaryCalculateForBranchRequested(
            year: _selectedDate.year,
            month: _selectedDate.month,
            branchId: widget.branchId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildDateSelector(),
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<TeacherSalaryBloc, TeacherSalaryState>(
                  listener: (context, state) {
                    if (state is TeacherSalaryOperationSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _loadData(); // Refresh data
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
                ),
              ],
              child: Row(
                children: [
                  // Sidebar with teacher list
                  Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: _buildTeachersList(),
                  ),
                  // Main content area
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
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
            const Icon(Icons.attach_money, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Teacher Salary Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _navigateToPaymentPage,
              icon: const Icon(Icons.payment, size: 18),
              label: const Text('View Payments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            'Salary Period:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: InkWell(
              onTap: _showDatePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Teachers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<TeacherBloc, TeacherState>(
            builder: (context, state) {
              if (state is TeacherLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is TeacherLoaded) {
                if (state.teachers.isEmpty) {
                  return _buildEmptyTeachersState();
                }
                return _buildTeachersListView(state.teachers);
              }

              if (state is TeacherError) {
                return _buildErrorState(state.message);
              }

              return const Center(
                child: Text('No teachers data available'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeachersListView(List<TeacherModel> teachers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              teacher.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "${teacher.salaryTypeDisplayName}: ${teacher.paymentPercentage}%",
                  style: TextStyle(
                    color: _getSalaryTypeColor(teacher.salaryType),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Base: ${NumberFormat('#,##0').format(teacher.baseSalary)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
            onTap: () => _navigateToSalaryCalculation(teacher),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: BlocBuilder<TeacherSalaryBloc, TeacherSalaryState>(
        builder: (context, state) {
          if (state is TeacherSalaryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherSalaryCalculationsLoaded) {
            return _buildSalaryOverview(state.salaryCalculations);
          }

          if (state is TeacherSalaryError) {
            return _buildErrorState(state.message);
          }

          return _buildWelcomeState();
        },
      ),
    );
  }

  Widget _buildSalaryOverview(List<SalaryCalculationModel> calculations) {
  final totalSalary = calculations.fold<double>(
    0.0,
    (sum, calc) => sum + calc.totalSalary,
  );
  final totalPaid = calculations.fold<double>(
    0.0,
    (sum, calc) => sum + calc.alreadyPaid,
  );
  final totalRemaining = calculations.fold<double>(
    0.0,
    (sum, calc) => sum + calc.remainingAmount,
  );

  return SingleChildScrollView( // Make entire content scrollable
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salary Overview - ${DateFormat('MMMM yyyy').format(_selectedDate)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Salary',
                '${NumberFormat('#,##0.0').format(totalSalary)} UZS',
                Icons.attach_money,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Paid',
                '${NumberFormat('#,##0.0').format(totalPaid)} UZS',
                Icons.payment,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Remaining',
                '${NumberFormat('#,##0.0').format(totalRemaining)} UZS',
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Teachers',
                '${calculations.length}',
                Icons.people,
                Colors.purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Salary Calculations Table
        Text(
          'Teacher Salary Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),

        // Table Container - Remove Expanded and make it take natural height
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: calculations.isEmpty
              ? _buildEmptyCalculationsState()
              : _buildCalculationsTable(calculations),
        ),
        
        // Add bottom padding for better scrolling experience
        const SizedBox(height: 24),
      ],
    ),
  );
}


  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
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

  // Changes to _buildCalculationsTable method in salary_management_page.dart

  Widget _buildCalculationsTable(List<SalaryCalculationModel> calculations) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                MediaQuery.of(context).size.width - 48, // Account for padding
          ),
          child: DataTable(
            columnSpacing: 16, // Reduced from default 56
            horizontalMargin: 16, // Reduced from default 24
            headingRowHeight: 48,
            dataRowHeight: 64, // Increased to accommodate multiline text
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300]!,
            ),
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            columns: const [
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Teacher',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Base\nSalary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Payment\nBased',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Total\nSalary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Already\nPaid',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Remaining',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            rows: calculations.map((calc) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 120, // Fixed width for teacher name column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            calc.teacherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            calc.branchName,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 80, // Fixed width for numeric columns
                      child: Text(
                        NumberFormat('#,##0').format(calc.baseSalary),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 80,
                      child: Text(
                        NumberFormat('#,##0').format(calc.paymentBasedSalary),
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 90,
                      child: Text(
                        NumberFormat('#,##0').format(calc.totalSalary),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 80,
                      child: Text(
                        NumberFormat('#,##0').format(calc.alreadyPaid),
                        style: TextStyle(
                          color: calc.alreadyPaid > 0
                              ? Colors.green[700]
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 80,
                      child: Text(
                        NumberFormat('#,##0').format(calc.remainingAmount),
                        style: TextStyle(
                          color: calc.remainingAmount > 0
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 100, // Fixed width for actions
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _navigateToSalaryCalculationWithModel(calc),
                            icon: const Icon(Icons.visibility, size: 16),
                            tooltip: 'View Details',
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: const EdgeInsets.all(4),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              foregroundColor: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (calc.remainingAmount > 0)
                            IconButton(
                              onPressed: () => _showPaymentDialog(calc),
                              icon: const Icon(Icons.payment, size: 16),
                              tooltip: 'Make Payment',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green[50],
                                foregroundColor: Colors.green[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

// Alternative: Add a card-based layout option for better mobile experience
// This can be used as a fallback if the table becomes too cramped

  Widget _buildCalculationsCards(List<SalaryCalculationModel> calculations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: calculations.length,
      itemBuilder: (context, index) {
        final calc = calculations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with teacher name and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calc.teacherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            calc.branchName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: calc.remainingAmount > 0
                            ? Colors.orange[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        calc.remainingAmount > 0 ? 'Pending' : 'Paid',
                        style: TextStyle(
                          fontSize: 10,
                          color: calc.remainingAmount > 0
                              ? Colors.orange[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Salary details in grid
                Row(
                  children: [
                    Expanded(
                      child: _buildSalaryInfoItem(
                        'Base Salary',
                        NumberFormat('#,##0').format(calc.baseSalary),
                      ),
                    ),
                    Expanded(
                      child: _buildSalaryInfoItem(
                        'Payment Based',
                        NumberFormat('#,##0').format(calc.paymentBasedSalary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSalaryInfoItem(
                        'Total Salary',
                        NumberFormat('#,##0').format(calc.totalSalary),
                        isHighlight: true,
                      ),
                    ),
                    Expanded(
                      child: _buildSalaryInfoItem(
                        'Remaining',
                        NumberFormat('#,##0').format(calc.remainingAmount),
                        color: calc.remainingAmount > 0
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _navigateToSalaryCalculationWithModel(calc),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (calc.remainingAmount > 0) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPaymentDialog(calc),
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Pay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalaryInfoItem(String label, String value,
      {bool isHighlight = false, Color? color}) {
    return Column(
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
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTeachersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Teachers Found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add teachers to view salary calculations',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCalculationsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Salary Calculations',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a teacher to view salary details',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(48),
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
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.attach_money,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Teacher Salary Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a month and teacher to calculate salaries,\nmanage payments, and view salary history.',
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
              onPressed: _loadData,
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

  Color _getSalaryTypeColor(String salaryType) {
    switch (salaryType) {
      case 'FIXED':
        return Colors.blue;
      case 'PERCENTAGE':
        return Colors.green;
      case 'MIXED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showDatePicker() async {
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

      // Reload salary calculations for new date
      context.read<TeacherSalaryBloc>().add(
            SalaryCalculateForBranchRequested(
              year: _selectedDate.year,
              month: _selectedDate.month,
              branchId: widget.branchId,
            ),
          );
    }
  }

  void _navigateToSalaryCalculation(TeacherModel teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalaryCalculationPage(
          teacherId: teacher.id,
          year: _selectedDate.year,
          month: _selectedDate.month,
        ),
      ),
    );
  }

  void _navigateToSalaryCalculationWithModel(SalaryCalculationModel calc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalaryCalculationPage(
          teacherId: calc.teacherId,
          year: calc.year,
          month: calc.month,
        ),
      ),
    );
  }

  void _navigateToPaymentPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalaryPaymentPage(branchId: widget.branchId),
      ),
    );
  }

  void _showPaymentDialog(SalaryCalculationModel calc) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.payment,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            const Text('Make Payment'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher: ${calc.teacherName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remaining Amount: ${NumberFormat('#,##0.00').format(calc.remainingAmount)}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  hintText: 'Enter amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter description',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          BlocConsumer<TeacherSalaryBloc, TeacherSalaryState>(
            listener: (context, state) {
              if (state is TeacherSalaryOperationSuccess) {
                Navigator.pop(dialogContext);
              }
            },
            builder: (context, state) {
              final isLoading = state is TeacherSalaryOperationLoading;

              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0) {
                          context.read<TeacherSalaryBloc>().add(
                                SalaryPaymentCreateRequested(
                                  teacherId: calc.teacherId,
                                  year: calc.year,
                                  month: calc.month,
                                  amount: amount,
                                  description: descriptionController.text
                                          .trim()
                                          .isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                                  branchId: calc.branchId,
                                ),
                              );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Make Payment'),
              );
            },
          ),
        ],
      ),
    );
  }
}
