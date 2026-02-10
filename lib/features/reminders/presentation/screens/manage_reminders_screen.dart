import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/reminder_model.dart';
import '../bloc/reminder_bloc.dart';

/// Screen to manage and view all reminders
class ManageRemindersScreen extends StatefulWidget {
  const ManageRemindersScreen({super.key});

  @override
  State<ManageRemindersScreen> createState() => _ManageRemindersScreenState();
}

class _ManageRemindersScreenState extends State<ManageRemindersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              hintText: 'Search by name, phone, or description...',
              onChanged: (value) {
                context.read<ReminderBloc>().add(
                  ReminderFilterUpdated(searchQuery: value),
                );
              },
              onClear: () {
                _searchController.clear();
                context.read<ReminderBloc>().add(
                  const ReminderFilterUpdated(searchQuery: ''),
                );
              },
            ),
          ),
          // Filter chips
          _buildFilterChips(),
          // Reminders list
          Expanded(
            child: BlocBuilder<ReminderBloc, ReminderState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reminders = state.filteredReminders;

                if (reminders.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inbox_outlined,
                    title: 'No Reminders Found',
                    subtitle: state.hasActiveFilters
                        ? 'Try adjusting your filters'
                        : 'Create your first reminder',
                    action: state.hasActiveFilters
                        ? TextButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear Filters'),
                          )
                        : null,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    return _ReminderListItem(
                      reminder: reminders[index],
                      onTap: () =>
                          _showReminderDetails(context, reminders[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Category chips
              ...ReminderCategory.values.map((category) {
                final isSelected = state.filterCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji),
                        const SizedBox(width: 4),
                        Text(category.label),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<ReminderBloc>().add(
                        ReminderFilterUpdated(
                          category: selected ? category : null,
                        ),
                      );
                    },
                  ),
                );
              }),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              // Status chips
              ...ReminderStatus.values.map((status) {
                final isSelected = state.filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<ReminderBloc>().add(
                        ReminderFilterUpdated(status: selected ? status : null),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ReminderBloc>().add(const ReminderFilterCleared());
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(onClearFilters: _clearFilters),
    );
  }

  void _showReminderDetails(BuildContext context, ReminderModel reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReminderDetailsSheet(reminder: reminder),
    );
  }
}

/// Reminder list item widget
class _ReminderListItem extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;

  const _ReminderListItem({required this.reminder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(
                        reminder.categoryColor,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      reminder.categoryEmoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.customerName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '+91 ${reminder.customerPhone}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, reminder.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reminder.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: reminder.isOverdue
                        ? AppTheme.errorColor
                        : reminder.isDueSoon
                        ? AppTheme.warningColor
                        : AppTheme.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppDateUtils.formatDateTime(reminder.scheduledTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: reminder.isOverdue
                          ? AppTheme.errorColor
                          : reminder.isDueSoon
                          ? AppTheme.warningColor
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                  const Spacer(),
                  if (reminder.hasAlarm)
                    const Icon(
                      Icons.alarm,
                      size: 16,
                      color: AppTheme.warningColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ReminderStatus status) {
    Color color;
    switch (status) {
      case ReminderStatus.pending:
        color = AppTheme.warningColor;
        break;
      case ReminderStatus.sent:
        color = AppTheme.infoColor;
        break;
      case ReminderStatus.completed:
        color = AppTheme.successColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatelessWidget {
  final VoidCallback onClearFilters;

  const _FilterBottomSheet({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Reminders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      onClearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text('Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReminderCategory.values.map((category) {
                  final isSelected = state.filterCategory == category;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji),
                        const SizedBox(width: 4),
                        Text(category.label),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<ReminderBloc>().add(
                        ReminderFilterUpdated(
                          category: selected ? category : null,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReminderStatus.values.map((status) {
                  final isSelected = state.filterStatus == status;
                  return FilterChip(
                    label: Text(status.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<ReminderBloc>().add(
                        ReminderFilterUpdated(status: selected ? status : null),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

/// Reminder details bottom sheet
class _ReminderDetailsSheet extends StatelessWidget {
  final ReminderModel reminder;

  const _ReminderDetailsSheet({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(reminder.categoryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  reminder.categoryEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.customerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+91 ${reminder.customerPhone}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Details
          _buildDetailRow(context, 'Category', reminder.category.label),
          _buildDetailRow(context, 'Description', reminder.description),
          _buildDetailRow(
            context,
            'Scheduled',
            AppDateUtils.formatDateTime(reminder.scheduledTime),
          ),
          if (reminder.notes != null && reminder.notes!.isNotEmpty)
            _buildDetailRow(context, 'Notes', reminder.notes!),
          if (reminder.hasAlarm && reminder.alarmTime != null)
            _buildDetailRow(
              context,
              'Alarm',
              AppDateUtils.formatDateTime(reminder.alarmTime!),
            ),
          const SizedBox(height: 16),
          Text('Message', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDCF8C6),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Text(reminder.message),
          ),
          const SizedBox(height: 24),
          // Actions
          Row(
            children: [
              if (reminder.status == ReminderStatus.pending)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<ReminderBloc>().add(
                        ReminderSendRequested(reminder: reminder),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                    label: const Text(
                      'Send via WhatsApp',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              if (reminder.status != ReminderStatus.completed)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<ReminderBloc>().add(
                        ReminderCompleteRequested(reminderId: reminder.id),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.successColor,
                    ),
                    label: const Text(
                      'Mark Complete',
                      style: TextStyle(color: AppTheme.successColor),
                    ),
                  ),
                ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorColor,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReminderBloc>().add(
                ReminderDeleteRequested(reminderId: reminder.id),
              );
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context); // Close bottom sheet
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
