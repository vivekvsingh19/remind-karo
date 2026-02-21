import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repositories/reminder_repository.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_form_cubit.dart';
import 'package:iconsax/iconsax.dart';

/// Screen for adding a new reminder with step-based form
class AddReminderScreen extends StatelessWidget {
  final ReminderCategory? initialCategory;

  const AddReminderScreen({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    // For testing purposes, we'll use a mock userId if one isn't available
    final userId = authState.userProfile?.id ?? 'mock_user_id';

    return BlocProvider(
      create: (context) {
        final cubit = ReminderFormCubit(
          repository: context.read<ReminderRepository>(),
          userId: userId,
        );
        if (initialCategory != null) {
          cubit.setCategory(initialCategory!);
          cubit.nextStep();
        }
        return cubit;
      },
      child: const _AddReminderContent(),
    );
  }
}

class _AddReminderContent extends StatefulWidget {
  const _AddReminderContent();

  @override
  State<_AddReminderContent> createState() => _AddReminderContentState();
}

class _AddReminderContentState extends State<_AddReminderContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReminderFormCubit, ReminderFormState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFCF8F8),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildStepContent(state),
                    ),
                  ),
                  _buildBottomButtons(state),
                ],
              ),
            ),
          ),
        );
      },
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
                onPressed: () {
                  if (context.read<ReminderFormCubit>().state.currentStep > 0) {
                    context.read<ReminderFormCubit>().previousStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                  color: Colors.black54,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Task',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
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

  Widget _buildStepContent(ReminderFormState state) {
    switch (state.currentStep) {
      case 0:
        return _buildCategoryStep(state);
      case 1:
        return _buildCustomerStep(state);
      case 2:
        return _buildDetailsStep(state);
      case 3:
        return _buildScheduleStep(state);
      case 4:
        return _buildReviewStep(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryStep(ReminderFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        ...ReminderCategory.values.map((category) {
          final isSelected = state.category == category;
          return _buildCategoryOption(
            category: category,
            isSelected: isSelected,
            onTap: () {
              context.read<ReminderFormCubit>().setCategory(category);
            },
          );
        }),
      ],
    );
  }

  Widget _buildCategoryOption({
    required ReminderCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon;
    if (category == ReminderCategory.payment) {
      icon = Iconsax.card;
    } else if (category == ReminderCategory.product) {
      icon = Iconsax.box;
    } else {
      icon = Icons.meeting_room_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF6E1) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              category.name[0].toUpperCase() + category.name.substring(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStep(ReminderFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Customer Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        _buildCenteredPillField(
          controller: _nameController,
          hintText: 'Name',
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              name: value,
            );
          },
        ),
        const SizedBox(height: 20),
        _buildCenteredPillField(
          controller: _phoneController,
          hintText: 'WhatsApp number',
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              phone: value,
            );
          },
        ),
        const SizedBox(height: 20),
        _buildCenteredPillField(
          controller:
              _notesController, // using notes for Phone Number for now since schema has only 1 phone
          hintText: 'Phone Number',
          onChanged: (value) {
            // we will discard or save to notes
          },
        ),
        const SizedBox(height: 20),
        _buildCenteredPillField(
          controller: _notesController,
          hintText: 'Additional notes(location/details)',
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              notes: value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCenteredPillField({
    required TextEditingController controller,
    required String hintText,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDetailsStep(ReminderFormState state) {
    // Generate message when description changes
    void generateMessage() {
      if (_descriptionController.text.isNotEmpty && state.category != null) {
        final message = WhatsAppService().generateReminderMessage(
          category: state.category!.value,
          customerName: _nameController.text,
          description: _descriptionController.text,
        );
        _messageController.text = message;
        context.read<ReminderFormCubit>().updateReminderDetails(
          description: _descriptionController.text,
          message: message,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reminder Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            TextButton.icon(
              onPressed: generateMessage,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Auto-Generate'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildCenteredPillField(
          controller: _descriptionController,
          hintText: 'Add Product Description',
          onChanged: (value) {
            generateMessage();
          },
        ),
        const SizedBox(height: 20),
        _buildCenteredPillField(
          controller: _messageController,
          hintText: 'WhatsApp Message',
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateReminderDetails(
              message: value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildScheduleStep(ReminderFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Reminder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'When should this reminder be sent?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
        ),
        const SizedBox(height: 32),
        // Date picker
        _buildDateTimePicker(
          label: 'Date',
          icon: Icons.calendar_today,
          value: state.scheduledDate != null
              ? '${state.scheduledDate!.day}/${state.scheduledDate!.month}/${state.scheduledDate!.year}'
              : 'Select date',
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: state.scheduledDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && mounted) {
              context.read<ReminderFormCubit>().updateSchedule(date: date);
            }
          },
        ),
        const SizedBox(height: 16),
        // Time picker
        _buildDateTimePicker(
          label: 'Time',
          icon: Icons.access_time,
          value: state.scheduledTime != null
              ? '${state.scheduledTime!.hour.toString().padLeft(2, '0')}:${state.scheduledTime!.minute.toString().padLeft(2, '0')}'
              : 'Select time',
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                state.scheduledTime ?? DateTime.now(),
              ),
            );
            if (time != null && mounted) {
              final now = DateTime.now();
              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              );
              context.read<ReminderFormCubit>().updateSchedule(time: dateTime);
            }
          },
        ),
        const SizedBox(height: 32),
        // Alarm toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.alarm, color: AppTheme.warningColor),
                      SizedBox(width: 12),
                      Text('Set Alarm'),
                    ],
                  ),
                  Switch.adaptive(
                    value: state.hasAlarm,
                    onChanged: (value) {
                      context.read<ReminderFormCubit>().updateAlarm(
                        hasAlarm: value,
                      );
                    },
                  ),
                ],
              ),
              if (state.hasAlarm) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildDateTimePicker(
                  label: 'Alarm Date',
                  icon: Icons.calendar_today,
                  value: state.alarmDate != null
                      ? '${state.alarmDate!.day}/${state.alarmDate!.month}/${state.alarmDate!.year}'
                      : 'Select date',
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.alarmDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && mounted) {
                      context.read<ReminderFormCubit>().updateAlarm(date: date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDateTimePicker(
                  label: 'Alarm Time',
                  icon: Icons.access_time,
                  value: state.alarmTime != null
                      ? '${state.alarmTime!.hour.toString().padLeft(2, '0')}:${state.alarmTime!.minute.toString().padLeft(2, '0')}'
                      : 'Select time',
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        state.alarmTime ?? DateTime.now(),
                      ),
                    );
                    if (time != null && mounted) {
                      final now = DateTime.now();
                      final dateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        time.hour,
                        time.minute,
                      );
                      context.read<ReminderFormCubit>().updateAlarm(
                        time: dateTime,
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(ReminderFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Reminder',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Make sure everything looks correct before submitting',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
        ),
        const SizedBox(height: 32),
        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              _buildReviewRow(
                'Category',
                '${state.category?.emoji ?? ''} ${state.category?.label ?? ''}',
              ),
              const Divider(height: 24),
              // Customer
              _buildReviewRow(
                'Customer',
                '${_nameController.text}\n+91 ${_phoneController.text}',
              ),
              const Divider(height: 24),
              // Description
              _buildReviewRow('Description', _descriptionController.text),
              const Divider(height: 24),
              // Schedule
              _buildReviewRow(
                'Scheduled For',
                state.combinedScheduledTime != null
                    ? '${state.scheduledDate!.day}/${state.scheduledDate!.month}/${state.scheduledDate!.year} at ${state.scheduledTime!.hour.toString().padLeft(2, '0')}:${state.scheduledTime!.minute.toString().padLeft(2, '0')}'
                    : 'Not set',
              ),
              if (state.hasAlarm) ...[
                const Divider(height: 24),
                _buildReviewRow(
                  'Alarm',
                  state.combinedAlarmTime != null
                      ? '${state.alarmDate!.day}/${state.alarmDate!.month}/${state.alarmDate!.year} at ${state.alarmTime!.hour.toString().padLeft(2, '0')}:${state.alarmTime!.minute.toString().padLeft(2, '0')}'
                      : 'Not set',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Message preview
        Text(
          'WhatsApp Message Preview',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFDCF8C6),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Text(
            _messageController.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryLight),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(ReminderFormState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
          ),
          onPressed: _canProceed(state) ? () => _handleNext(state) : null,
          child: Text(
            state.isLoading
                ? 'Processing...'
                : (state.currentStep == 4 ? 'Create Task' : 'Next'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  bool _canProceed(ReminderFormState state) {
    switch (state.currentStep) {
      case 0:
        return state.canProceedStep1;
      case 1:
        return state.customerName.isNotEmpty && state.customerPhone.isNotEmpty;
      case 2:
        return state.description.isNotEmpty && state.message.isNotEmpty;
      case 3:
        return state.scheduledDate != null && state.scheduledTime != null;
      case 4:
        return true; // Always enable on review step
      default:
        return false;
    }
  }

  Future<void> _handleNext(ReminderFormState state) async {
    if (state.currentStep < 4) {
      // Validate current step before proceeding
      if (state.currentStep == 1 || state.currentStep == 2) {
        if (!(_formKey.currentState?.validate() ?? false)) return;
      }
      context.read<ReminderFormCubit>().nextStep();
    } else {
      // Submit
      await context.read<ReminderFormCubit>().submit();
      if (mounted) {
        _showSuccessScreen(context);
      }
    }
  }

  void _showSuccessScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        child: Container(
          color: const Color(0xFFFCF8F8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTheme.successColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),
              const SizedBox(height: 32),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your reminder has been created\nsuccessfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Pop dialog
                      Navigator.of(context).pop(); // Pop AddReminderScreen
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
