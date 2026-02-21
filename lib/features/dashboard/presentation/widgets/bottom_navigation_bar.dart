import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';

/// Custom bottom navigation bar widget
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryLight,
        showUnselectedLabels: true,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Home',
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
                    child: const Icon(Iconsax.notification_status),
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
                    child: const Icon(Iconsax.notification),
                  );
                }
                return const Icon(Iconsax.notification);
              },
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.transparent),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.task_square),
            activeIcon: Icon(Iconsax.task_square),
            label: 'Manage',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            activeIcon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
