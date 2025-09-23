// lib/features/main/presentation/widgets/app_drawer.dart - Mobile Restricted Version
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool availableOnMobileTablet; // Add this field

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.availableOnMobileTablet = false, // Default false
  });
}

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isMobileOrTablet; // Add this parameter

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isMobileOrTablet = false, // Add this
  });

  static const List<DrawerItem> _drawerItems = [
    DrawerItem(
      icon: Icons.school_outlined,
      title: 'Courses',
      subtitle: 'Manage courses',
      availableOnMobileTablet: true, // Only this is available on mobile/tablet
    ),
    DrawerItem(
      icon: Icons.people_outline,
      title: 'Students',
      subtitle: 'Student management',
      availableOnMobileTablet: false,
    ),
    DrawerItem(
      icon: Icons.person_outline,
      title: 'Teachers',
      subtitle: 'Teacher management',
      availableOnMobileTablet: false,
    ),
    DrawerItem(
      icon: Icons.payment_outlined,
      title: 'Payments',
      subtitle: 'Payment records',
      availableOnMobileTablet: false,
    ),
    DrawerItem(
      icon: Icons.attach_money_outlined, // Different icon
      title: 'Salary',
      subtitle: 'Salary Management',
      availableOnMobileTablet: false,
    ),
    DrawerItem(
      icon: Icons.receipt_long_outlined, // Different icon
      title: 'Expenses',
      subtitle: 'Expense Management',
      availableOnMobileTablet: false,
    ),
    DrawerItem(
      icon: Icons.analytics_outlined,
      title: 'Reports',
      subtitle: 'Report Management',
      availableOnMobileTablet: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            // Modified Drawer Header
            Container(
              height: isMobileOrTablet ? 220 : 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // App Logo/Icon
                          Container(
                            width: isMobileOrTablet ? 50 : 60,
                            height: isMobileOrTablet ? 50 : 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Colors.white,
                              size: isMobileOrTablet ? 28 : 32,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // App Title with device indicator
                          Row(
                            children: [
                              const Text(
                                'iStudy Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isMobileOrTablet) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isMobile ? 'Mobile' : 'Tablet',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          // User Info (keep existing)
                          Text(
                            state.user.username,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.user.role}${state.user.branchName != null ? ' • ${state.user.branchName}' : ''}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Access Notice for Mobile/Tablet
            if (isMobileOrTablet) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isMobile ? Icons.phone_android : Icons.tablet_android,
                          color: Colors.orange[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isMobile ? "Mobile" : "Tablet"} Access',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Limited features available.\nUse desktop for full access.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Modified Navigation Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _drawerItems.length,
                itemBuilder: (context, index) {
                  final item = _drawerItems[index];
                  final isSelected = selectedIndex == index;
                  final isAvailable = !isMobileOrTablet || item.availableOnMobileTablet;
                  final isRestricted = isMobileOrTablet && !item.availableOnMobileTablet;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : isRestricted
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : isRestricted
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                size: 22,
                              ),
                            ),
                            if (isRestricted)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : isRestricted
                                        ? Colors.grey[400]
                                        : const Color(0xFF1F2937),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isRestricted) ...[
                            Icon(
                              Icons.desktop_windows_outlined,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        isRestricted ? 'Desktop only' : item.subtitle,
                        style: TextStyle(
                          color: isRestricted ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => onItemTapped(index),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      enabled: isAvailable,
                    ),
                  );
                },
              ),
            ),

            // Modified Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isMobileOrTablet 
                            ? (isMobile ? Icons.phone_android : Icons.tablet_android)
                            : Icons.desktop_windows,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isMobileOrTablet 
                            ? '${isMobile ? "Mobile" : "Tablet"} v1.0.0'
                            : 'Desktop v1.0.0',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}