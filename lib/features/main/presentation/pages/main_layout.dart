// lib/features/main/presentation/pages/main_layout.dart - Mobile Restricted Version
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:istudyadmin/features/courses/presentation/pages/courses_page.dart';
import 'package:istudyadmin/features/expenses/presentation/pages/expenses_management_page.dart';
import 'package:istudyadmin/features/salary/presentation/pages/salary_management_page.dart';
import 'package:istudyadmin/features/teachers/presentation/pages/teachers_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../students/presentation/pages/students_page.dart';
import '../../../payments/presentation/pages/payments_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../widgets/app_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get isMobile => MediaQuery.of(context).size.width < 1024;

  // Full pages for desktop/tablet
  final List<Widget> _allPages = [
    const CoursesPage(),
    const StudentsPage(),
    const TeachersPage(),
    const PaymentsPage(),
    const SalaryPage(),
    const ExpensesPage(),
    const ReportsPage(),
  ];

  final List<String> _allPageTitles = [
    'Courses',
    'Students',
    'Teachers',
    'Payments',
    'Salaries',
    'Expenses',
    'Reports',
  ];

  // Mobile-only pages (just courses)
  final List<Widget> _mobilePages = [
    const CoursesPage(),
  ];

  final List<String> _mobilePageTitles = [
    'Courses',
  ];

  List<Widget> get _pages => isMobile ? _mobilePages : _allPages;
  List<String> get _pageTitles => isMobile ? _mobilePageTitles : _allPageTitles;

  void _onDrawerItemTapped(int index) {
    // On mobile, only allow courses (index 0)
    if (isMobile && index != 0) {
      _showMobileRestrictionDialog();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  void _showMobileRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.phone_android,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Mobile Access Limited',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This feature is only available on desktop and tablet devices for the best user experience.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
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
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Available on Mobile:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Courses Management\n• Group Details\n• Student Information',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force courses page on mobile if somehow another index is selected
    if (isMobile && _selectedIndex >= _mobilePages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            if (isMobile) ...[
              Icon(
                Icons.phone_android,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _pageTitles[_selectedIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF1F2937),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (isMobile) ...[
            IconButton(
              icon: Icon(
                Icons.desktop_windows_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () => _showDesktopRecommendationDialog(),
              tooltip: 'Switch to Desktop',
            ),
          ],
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      state.user.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user.username,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${state.user.role}${state.user.branchName != null ? ' • ${state.user.branchName}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onDrawerItemTapped,
        isMobileOrTablet: isMobile,
      ),
      body: isMobile
          ? _buildMobileLayout()
          : IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryColor.withOpacity(0.05),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mobile version - Limited features. Use desktop for full access.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: _showDesktopRecommendationDialog,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Learn More',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ],
    );
  }

  void _showDesktopRecommendationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.desktop_windows,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Better on Desktop',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For the best iStudy Admin experience, we recommend using a desktop or tablet device.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
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
                      Icon(Icons.check_circle_outline, color: Colors.green[600], size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Full Features Available:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Complete student management\n'
                    '• Teacher administration\n'
                    '• Payment processing\n'
                    '• Detailed reports & analytics\n'
                    '• Salary & expense management',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue on Mobile'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}