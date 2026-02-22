import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../theme/app_theme.dart';

/// A reusable circular avatar that syncs with the authenticated user's
/// profile picture across the entire app via [AuthBloc].
///
/// Falls back to the user's initial letter if no photo is set.
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

        if (photoUrl != null && photoUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(photoUrl),
            backgroundColor: AppTheme.primaryColor,
          );
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            initial,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.85,
            ),
          ),
        );
      },
    );
  }
}
