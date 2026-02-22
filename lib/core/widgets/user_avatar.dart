import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../services/avatar_service.dart';
import '../theme/app_theme.dart';

/// A reusable circular avatar that syncs with the authenticated user's
/// profile picture across the entire app.
///
/// Priority order:
/// 1. Network photo from server (photoUrl)
/// 2. Locally selected avatar from [AvatarService.current]
/// 3. User's initial letter as fallback
class UserAvatarWidget extends StatelessWidget {
  final double radius;

  const UserAvatarWidget({super.key, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final photoUrl = state.userProfile?.photoUrl;
        final name = state.userProfile?.name ?? '';
        final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

        // Priority 1: Network photo from server
        if (photoUrl != null && photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(photoUrl),
            backgroundColor: AppTheme.primaryColor,
          );
        }

        // Priority 2: Listen to the ValueNotifier for instant reactivity
        return ValueListenableBuilder<String>(
          valueListenable: AvatarService.current,
          builder: (context, avatarPath, _) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: AppTheme.primaryColor,
              child: ClipOval(
                child: Image.asset(
                  avatarPath,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.85,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
