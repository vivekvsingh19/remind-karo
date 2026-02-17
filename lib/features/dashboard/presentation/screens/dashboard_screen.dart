import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../reminders/data/models/reminder_model.dart';
import '../../../reminders/presentation/bloc/reminder_bloc.dart';
import '../../../reminders/presentation/screens/add_reminder_screen.dart';

/// Dashboard screen showing reminders overview
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final authState = context.read<AuthBloc>().state;
            if (authState.isAuthenticated) {
              context.read<ReminderBloc>().add(
                ReminderStatsLoadRequested(
                  userId: authState.userProfile?.id ?? '',
                ),
              );
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildStatsCard(context),
                      const SizedBox(height: 24),
                      _buildUpcomingReminders(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state.userProfile?.name ?? 'User';
        final greeting = AppDateUtils.getGreeting();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionButton(
              context,
              icon: '💰',
              label: 'Payment',
              color: AppTheme.paymentColor,
              category: ReminderCategory.payment,
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              context,
              icon: '📦',
              label: 'Product',
              color: AppTheme.productColor,
              category: ReminderCategory.product,
            ),
            const SizedBox(width: 12),
            _buildQuickActionButton(
              context,
              icon: '📅',
              label: 'Meeting',
              color: AppTheme.meetingColor,
              category: ReminderCategory.meeting,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required ReminderCategory category,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReminderScreen(initialCategory: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final stats = state.stats;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'This Month',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppDateUtils.getCurrentMonthYear(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem(
                    'Total',
                    stats?.total.toString() ?? '0',
                    Colors.white,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    'Pending',
                    stats?.pending.toString() ?? '0',
                    Colors.amber.shade200,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    'Complete',
                    stats?.completed.toString() ?? '0',
                    Colors.green.shade200,
                  ),
                  _buildStatDivider(),
                  _buildStatItem(
                    'Overdue',
                    stats?.overdue.toString() ?? '0',
                    Colors.red.shade200,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildUpcomingReminders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Reminders',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // Navigate to reminders tab
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ReminderBloc, ReminderState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Get upcoming reminders (pending and due soon)
            final upcoming = state.reminders
                .where(
                  (r) =>
                      r.status == ReminderStatus.pending &&
                      r.scheduledTime.isAfter(DateTime.now()),
                )
                .take(5)
                .toList();

            if (upcoming.isEmpty) {
              return const EmptyStateWidget(
                icon: Iconsax.calendar_1,
                title: 'No Upcoming Reminders',
                subtitle: 'Add your first reminder to get started!',
              );
            }

            return Column(
              children: upcoming.map((reminder) {
                return _ReminderCard(reminder: reminder);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Reminder card widget
class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;

  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(reminder.categoryColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              reminder.categoryEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.customerName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppDateUtils.formatRelativeDate(reminder.scheduledTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: reminder.isDueSoon
                      ? AppTheme.warningColor
                      : AppTheme.textSecondaryLight,
                  fontWeight: reminder.isDueSoon
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatTime(reminder.scheduledTime),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
