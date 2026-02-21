import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/notification_model.dart';
import '../bloc/notification_bloc.dart';
import 'view_notification_screen.dart';

/// Screen to display all notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0: Recent, 1: History

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final userId = authState.userProfile?.id ?? 'mock_user';
    context.read<NotificationBloc>().add(
      NotificationsSubscriptionRequested(userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildTabs()),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BlocConsumer<NotificationBloc, NotificationState>(
                        listener: (context, state) {
                          if (state.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error!),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                          if (state.successMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.successMessage!),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // Filter notifications based on tab
                          final now = DateTime.now();
                          final recentCutoff = now.subtract(
                            const Duration(hours: 24),
                          );

                          final allNotifications = state.notifications;
                          final recentNotifications = allNotifications.where((
                            n,
                          ) {
                            return n.createdAt.isAfter(recentCutoff);
                          }).toList();

                          final historyNotifications = allNotifications.where((
                            n,
                          ) {
                            return n.createdAt.isBefore(recentCutoff);
                          }).toList();

                          final currentList = _selectedTab == 0
                              ? recentNotifications
                              : historyNotifications;

                          if (currentList.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: currentList.length,
                            itemBuilder: (context, index) {
                              final notification = currentList[index];
                              return _NotificationCard(
                                notification: notification,
                                isHistory: _selectedTab == 1,
                                onTap: () {
                                  if (!notification.isRead) {
                                    context.read<NotificationBloc>().add(
                                      NotificationMarkAsReadRequested(
                                        notificationId: notification.id,
                                      ),
                                    );
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewNotificationScreen(
                                        notification: notification,
                                      ),
                                    ),
                                  );
                                },
                                onDismiss: () {
                                  context.read<NotificationBloc>().add(
                                    NotificationDeleteRequested(
                                      notificationId: notification.id,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                  color: Colors.black87,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.userProfile?.photoUrl != null) {
                return CircleAvatar(
                  backgroundImage: NetworkImage(state.userProfile!.photoUrl!),
                  radius: 20,
                );
              }
              return const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 20,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTabItem('Recent', 0), _buildTabItem('History', 1)],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(30) : Radius.zero,
            bottomLeft: index == 0 ? const Radius.circular(30) : Radius.zero,
            topRight: index == 1 ? const Radius.circular(30) : Radius.zero,
            bottomRight: index == 1 ? const Radius.circular(30) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 0
                ? 'No recent notifications'
                : 'No notification history',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification card widget
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isHistory;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.isHistory,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final typeName = notification.type.name; // E.g. 'alarm', 'general'
    // To fallback on 'Meeting' as per mockup for non-specific items
    final categoryText = typeName.isNotEmpty
        ? typeName[0].toUpperCase() + typeName.substring(1)
        : 'Meeting';

    return Dismissible(
      key: Key(notification.id), // Add Dismissible for slide-to-delete
      onDismissed: (_) => onDismiss(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isHistory) ...[
                    Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title.isNotEmpty
                              ? notification.title
                              : 'Notification',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatNotificationTime(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      categoryText.length > 8
                          ? 'Meeting'
                          : categoryText, // Quick fallback
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isHistory) ...[
                    const SizedBox(width: 12),
                    Icon(
                      notification.isRead
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: notification.isRead ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime date) {
    // Format: 5.15 PM  13 Feb
    return DateFormat('h.mm a  dd MMM').format(date).toUpperCase();
  }
}
