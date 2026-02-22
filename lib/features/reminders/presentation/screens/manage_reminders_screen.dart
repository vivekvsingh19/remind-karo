import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

import '../../data/models/reminder_model.dart';
import '../bloc/reminder_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildSearchBar(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Reminders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showFilterSheet(context),
                    child: Icon(Icons.filter_list, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ReminderBloc, ReminderState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reminders = state.filteredReminders;

                  if (reminders.isEmpty) {
                    return _buildEmptyState(state);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      return _ReminderListItem(
                        reminder: reminders[index],
                        onTap: () {
                          // Show details logic here if needed, or placeholder
                        },
                        onEdit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit feature coming soon'),
                            ),
                          );
                        },
                        onDelete: () {
                          context.read<ReminderBloc>().add(
                            ReminderDeleteRequested(
                              reminderId: reminders[index].id,
                            ),
                          );
                        },
                        onToggleVisibility: () {
                          // Toggle visibility logic
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.black54,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              alignment: Alignment.centerLeft,
            ),
          ],
          const Spacer(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.userProfile?.photoUrl != null) {
                return CircleAvatar(
                  backgroundImage: NetworkImage(state.userProfile!.photoUrl!),
                  radius: 18,
                );
              }
              return const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'MANAGE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<ReminderBloc>().add(
                ReminderFilterUpdated(searchQuery: value),
              );
            },
            decoration: InputDecoration(
              hintText: 'Search Reminders',
              hintStyle: TextStyle(
                color: Colors.grey.shade300,
                fontStyle: FontStyle.italic,
              ),
              prefixIcon: const SizedBox.shrink(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ReminderState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Reminders Found',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          if (state.hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear Filters'),
            ),
        ],
      ),
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
}

/// Reminder list item widget
class _ReminderListItem extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisibility;

  const _ReminderListItem({
    required this.reminder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFFF5F8,
        ), // Light pinkish/white background from design
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        Colors.deepPurple.shade100, // Light purple background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      reminder.customerName.isNotEmpty
                          ? reminder.customerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.deepPurple.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.category.label, // "Meeting"
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reminder.customerName, // "Vani automobiles"
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037), // Brownish text
                        ),
                      ),
                      Text(
                        'Status-${reminder.status.name.capitalize()}', // "Status-Pending"
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconBtn(Icons.remove_red_eye_outlined, onTap),
                    const SizedBox(width: 8),
                    _buildIconBtn(Iconsax.edit, onEdit),
                    const SizedBox(width: 8),
                    _buildIconBtn(
                      Icons.toggle_on_outlined,
                      onToggleVisibility,
                    ), // Design shows toggle icon
                    const SizedBox(width: 8),
                    _buildIconBtn(Iconsax.trash, onDelete),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: 20, color: Colors.grey.shade600),
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
                    label: Text(category.label),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
