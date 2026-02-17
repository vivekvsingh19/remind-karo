import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/whatsapp_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/repositories/reminder_repository.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_form_cubit.dart';

/// Screen for adding a new reminder with step-based form
class AddReminderScreen extends StatelessWidget {
  final ReminderCategory? initialCategory;

  const AddReminderScreen({super.key, this.initialCategory});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.userProfile?.id;

    // Check if user is authenticated with valid ID
    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Reminder')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Please login to add reminders'),
            ],
          ),
        ),
      );
    }

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
          appBar: AppBar(
            title: Text(_getStepTitle(state.currentStep)),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(state.currentStep),
                  const SizedBox(height: 24),
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildStepContent(state),
                    ),
                  ),
                  // Bottom buttons
                  _buildBottomButtons(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Category';
      case 1:
        return 'Customer Details';
      case 2:
        return 'Reminder Details';
      case 3:
        return 'Schedule';
      case 4:
        return 'Review & Submit';
      default:
        return 'Add Reminder';
    }
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
              child: isCompleted
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  : null,
            ),
          );
        }),
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
        Text(
          'What type of reminder is this?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Select a category to help organize your reminders',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(category.color).withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? Color(category.color) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(category.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(category.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCategoryDescription(category),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Color(category.color)),
          ],
        ),
      ),
    );
  }

  String _getCategoryDescription(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.payment:
        return 'Payment reminders, invoices, dues';
      case ReminderCategory.product:
        return 'Product deliveries, orders, subscriptions';
      case ReminderCategory.meeting:
        return 'Meetings, appointments, calls';
    }
  }

  Widget _buildCustomerStep(ReminderFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the customer details for this reminder',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _nameController,
          labelText: 'Customer Name',
          hintText: 'Enter customer name',
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              name: value,
            );
          },
        ),
        const SizedBox(height: 20),
        PhoneTextField(
          controller: _phoneController,
          validator: Validators.validatePhoneNumber,
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              phone: value,
            );
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _notesController,
          labelText: 'Notes (Optional)',
          hintText: 'Any additional notes',
          prefixIcon: Icons.note_outlined,
          maxLines: 3,
          onChanged: (value) {
            context.read<ReminderFormCubit>().updateCustomerDetails(
              notes: value,
            );
          },
        ),
      ],
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
        Text('Reminder Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Describe the reminder and customize the message',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _descriptionController,
          labelText: 'Description',
          hintText: 'What is this reminder about?',
          prefixIcon: Icons.description_outlined,
          maxLines: 2,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a description' : null,
          onChanged: (value) {
            generateMessage();
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'WhatsApp Message',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: generateMessage,
              icon: const Icon(Icons.auto_fix_high, size: 18),
              label: const Text('Generate'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Message that will be sent via WhatsApp',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter a message' : null,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: SecondaryButton(
                text: 'Back',
                onPressed: () {
                  context.read<ReminderFormCubit>().previousStep();
                },
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: state.currentStep == 4 ? 'Create Reminder' : 'Continue',
              isLoading: state.isLoading,
              onPressed: _canProceed(state) ? () => _handleNext(state) : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed(ReminderFormState state) {
    switch (state.currentStep) {
      case 0:
        return state.canProceedStep1;
      case 1:
        return _formKey.currentState?.validate() ?? false;
      case 2:
        return state.canProceedStep3 || _descriptionController.text.isNotEmpty;
      case 3:
        return state.canProceedStep4;
      case 4:
        return state.canSubmit;
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
      final success = await context.read<ReminderFormCubit>().submit();
      if (success && mounted) {
        // Refresh reminders
        final authBloc = context.read<AuthBloc>();
        if (authBloc.state.isAuthenticated) {
          context.read<ReminderBloc>().add(
            ReminderStatsLoadRequested(
              userId: authBloc.state.userProfile?.id ?? '',
            ),
          );
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder created successfully! 🎉'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
