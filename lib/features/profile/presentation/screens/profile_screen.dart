import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Navigate to login on sign out
          if (state.step == AuthStep.phone) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                _buildProfileHeader(context, user?.name ?? 'User'),
                const SizedBox(height: 32),
                // Account section
                _buildSection(
                  context,
                  title: 'Account Information',
                  children: [
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.user,
                      title: 'Full Name',
                      subtitle: user?.name ?? 'Not set',
                      onTap: () {
                        // TODO: Navigate to edit profile
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.call,
                      title: 'Phone Number',
                      subtitle: user?.phoneNumber != null
                          ? '+91 ${user!.phoneNumber}'
                          : 'Not set',
                      onTap: null,
                    ),
                    if (user?.email != null)
                      _buildSettingsItem(
                        context,
                        icon: Iconsax.sms,
                        title: 'Email',
                        subtitle: user!.email!,
                        onTap: null,
                      ),
                    if (user?.id != null && user!.id.isNotEmpty)
                      _buildSettingsItem(
                        context,
                        icon: Iconsax.document,
                        title: 'User ID',
                        subtitle: user!.id,
                        onTap: null,
                      ),
                    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                      _buildSettingsItem(
                        context,
                        icon: Iconsax.image,
                        title: 'Profile Photo',
                        subtitle: 'Photo URL set',
                        onTap: null,
                      ),
                    if (user?.createdAt != null)
                      _buildSettingsItem(
                        context,
                        icon: Iconsax.calendar_1,
                        title: 'Account Created',
                        subtitle: _formatDate(user!.createdAt),
                        onTap: null,
                      ),
                    if (user?.updatedAt != null)
                      _buildSettingsItem(
                        context,
                        icon: Iconsax.edit,
                        title: 'Last Updated',
                        subtitle: _formatDate(user!.updatedAt),
                        onTap: null,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Settings section
                _buildSection(
                  context,
                  title: 'Settings',
                  children: [
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () {
                        // TODO: Navigate to notification settings
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.message,
                      title: 'WhatsApp Templates',
                      subtitle: 'Customize message templates',
                      onTap: () {
                        // TODO: Navigate to template settings
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.moon,
                      title: 'Appearance',
                      subtitle: 'Theme and display settings',
                      onTap: () {
                        // TODO: Navigate to appearance settings
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Support section
                _buildSection(
                  context,
                  title: 'Support',
                  children: [
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.info_circle,
                      title: 'Help & FAQ',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.shield_tick,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      icon: Iconsax.document_text,
                      title: 'Terms of Service',
                      onTap: () {
                        // TODO: Open terms
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Iconsax.logout),
                    label: const Text('Log Out'),
                  ),
                ),
                const SizedBox(height: 12),
                // Delete account button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteAccountConfirmation(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Iconsax.trash),
                    label: const Text('Delete Account'),
                  ),
                ),
                const SizedBox(height: 24),
                // Version info
                Center(
                  child: Text(
                    'RemindKaro v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  Widget _buildProfileHeader(BuildContext context, String name) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/profile.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Iconsax.arrow_right_3,
                color: AppTheme.textSecondaryLight,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Show error if deletion fails
          if (state.error != null && state.error!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          // Navigate to login on successful deletion
          if (state.step == AuthStep.phone &&
              !state.isLoading &&
              state.error == null) {
            Navigator.pop(dialogContext);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isLoading)
                      const SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.error != null && state.error!.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Error: ${state.error}',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            const AuthDeleteAccountRequested(),
                          );
                        },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
