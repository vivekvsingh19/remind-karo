import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../reminders/presentation/bloc/reminder_bloc.dart';
import '../../../reminders/presentation/screens/manage_reminders_screen.dart';
import '../../../../core/widgets/user_avatar.dart';

/// Dashboard screen showing reminders overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String _successRatePeriod = '7 Days';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFCF8F8,
      ), // Light pinkish-white background like design
      body: SafeArea(
        bottom: false,
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
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildCalendar(context),
                          const SizedBox(height: 16),
                          _buildStatsGrid(context),
                          const SizedBox(height: 16),
                          _buildSuccessRate(context),
                          const SizedBox(height: 24),
                          _buildUpcomingReminders(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name =
            (state.userProfile?.name != null &&
                state.userProfile!.name.isNotEmpty)
            ? state.userProfile!.name
            : 'User';
        // Get just the first name
        final firstName = name.split(' ').first;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: 'Hello, ',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: firstName,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(children: [const UserAvatarWidget(radius: 20)]),
          ],
        );
      },
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final now = _selectedDate;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Starting day of week (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)

    // Adjust so Sunday is 0 for grid calculation if we start grid with Sunday
    // Design: Su Mo Tu ...
    // Dart: Mon=1 ... Sun=7.
    // If Sun(7) -> 0 offset.
    // If Mon(1) -> 1 offset.
    final int offset = firstWeekday == 7 ? 0 : firstWeekday;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDropdown(
                DateFormat('MMM').format(now),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(width: 8),
              _buildDropdown(
                DateFormat('yyyy').format(now),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDatePickerMode: DatePickerMode.year,
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weekdays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
              return SizedBox(
                width: 30,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 8, // reduced spacing
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + offset,
            itemBuilder: (context, index) {
              if (index < offset) {
                return const SizedBox();
              }
              final day = index - offset + 1;
              final isSelected = day == _selectedDate.day;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      day,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Reminders This Month',
            style: TextStyle(
              color: Colors.black45,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final stats = state.stats;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1, // Adjusted aspect ratio
          children: [
            _buildStatCard(
              context,
              'Total',
              stats?.total.toString() ?? '0',
              Iconsax.trend_up,
              const Color(0xFFEFF4FF),
              const Color(0xFF5A6BCC),
            ),
            _buildStatCard(
              context,
              'Completed',
              stats?.completed.toString() ?? '0',
              Iconsax.tick_circle,
              const Color(0xFFF0FDF4),
              const Color(0xFF4ADE80),
            ),
            _buildStatCard(
              context,
              'Pending',
              stats?.pending.toString() ?? '0',
              Iconsax.clock,
              const Color(0xFFFFFBEB),
              const Color(0xFFFBBF24),
            ),
            _buildStatCard(
              context,
              'Negetive', // Keep "Negetive" as in design image
              stats?.overdue.toString() ?? '0',
              Iconsax.close_circle,
              const Color(0xFFFEF2F2),
              const Color(0xFFEF4444),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRate(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Success Rates',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildDropdown(
                _successRatePeriod,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['7 Days', '30 Days', '90 Days', '1 Year']
                          .map(
                            (e) => ListTile(
                              title: Text(e),
                              onTap: () {
                                setState(() => _successRatePeriod = e);
                                Navigator.pop(ctx);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120, // Increased height
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReminders(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UPCOMING',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final upcoming = state.reminders
                  .where(
                    (r) =>
                        r.status == ReminderStatus.pending &&
                        r.scheduledTime.isAfter(DateTime.now()),
                  )
                  .take(3) // Design shows 3 items
                  .toList();

              if (upcoming.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No upcoming reminders')),
                );
              }

              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcoming.length,
                    itemBuilder: (context, index) {
                      final reminder = upcoming[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Timestamp line
                              SizedBox(
                                width: 20,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 1.5,
                                      height: 8,
                                      color: index == 0
                                          ? Colors.transparent
                                          : Colors.grey.shade300,
                                    ),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        color: index != upcoming.length - 1
                                            ? Colors.grey.shade300
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reminder.customerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                DashboardStringExtension(
                                                  reminder.category.name,
                                                ).capitalize(),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        DateFormat('hh.mm a')
                                            .format(reminder.scheduledTime)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
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
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Manage Reminder
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageRemindersScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Manage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryColor.withValues(alpha: 0.3),
          AppTheme.primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    // Start slightly off screen
    path.moveTo(0, size.height * 0.8);

    // Smooth bezier curve
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.9,
      size.width * 0.6,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.7,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);

    // Close path for fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension DashboardStringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
