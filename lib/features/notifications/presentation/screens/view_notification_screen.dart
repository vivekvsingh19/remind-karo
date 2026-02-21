import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/notification_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ViewNotificationScreen extends StatelessWidget {
  final NotificationModel notification;

  const ViewNotificationScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCardRow(
                      notification.title.isNotEmpty
                          ? notification.title
                          : 'Customer Name',
                    ),
                    const SizedBox(height: 12),
                    _buildDateTimeRow(notification.createdAt),
                    const SizedBox(height: 12),
                    _buildCardRow('Payment Type'), // or category
                    const SizedBox(height: 12),
                    _buildDescriptionBox(notification.body),
                    const SizedBox(height: 20),
                    _buildActionRow(
                      'WhatsApp',
                      Iconsax.message,
                      Iconsax.send_1,
                      onTapAction: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildActionRow(
                      'Call',
                      Iconsax.call,
                      Iconsax.call,
                      onTapAction: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildCardRowWithPrefix(
                      'Dont Repeat',
                      Iconsax.repeate_music,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Mark As Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                'View',
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

  Widget _buildCardRow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildCardRowWithPrefix(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow(DateTime created) {
    final dateStr = DateFormat('dd/M/yyyy').format(created);
    final timeStr = DateFormat('hh.mm').format(created);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.calendar_1, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            dateStr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 24),
          const Icon(Iconsax.clock, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionBox(String fallbackText) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Description',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }

  Widget _buildActionRow(
    String text,
    IconData prefixIcon,
    IconData suffixIcon, {
    required VoidCallback onTapAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, size: 20, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const Spacer(),
          const Icon(Iconsax.eye, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          const Icon(Iconsax.edit, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          InkWell(
            onTap: onTapAction,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(suffixIcon, size: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
