import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../reminders/presentation/screens/manage_reminders_screen.dart';
import '../../../reminders/presentation/screens/add_reminder_screen.dart';
import 'dashboard_screen.dart';

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SizedBox(), // Placeholder for Add Reminder
    ManageRemindersScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderScreen()),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryLight,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.element_3),
              activeIcon: Icon(
                Iconsax.element_35,
              ), // Using filled variant if available or fallback
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.add_circle, size: 30),
              activeIcon: Icon(Iconsax.add_circle5, size: 30),
              label: 'Add',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.task_square),
              activeIcon: Icon(Iconsax.task_square5),
              label: 'Manage',
            ),
            BottomNavigationBarItem(
              icon: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return Badge(
                      label: Text(
                        state.unreadCount > 99
                            ? '99+'
                            : state.unreadCount.toString(),
                      ),
                      child: const Icon(Iconsax.notification),
                    );
                  }
                  return const Icon(Iconsax.notification);
                },
              ),
              activeIcon: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return Badge(
                      label: Text(
                        state.unreadCount > 99
                            ? '99+'
                            : state.unreadCount.toString(),
                      ),
                      child: const Icon(Iconsax.notification5),
                    );
                  }
                  return const Icon(Iconsax.notification5);
                },
              ),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              activeIcon: Icon(Iconsax.user_square),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
