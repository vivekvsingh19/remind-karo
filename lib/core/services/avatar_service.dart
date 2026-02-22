import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to persist and retrieve the user's local avatar selection.
/// Exposes a [ValueNotifier] so all [UserAvatarWidget] instances
/// rebuild immediately when the avatar changes.
class AvatarService {
  static const String _prefKey = 'selected_avatar';

  /// All available avatar asset paths including the default one.
  static const List<String> avatarOptions = [
    'assets/icons/profile.png',
    'assets/icons/avatar_1.png',
    'assets/icons/avatar_2.png',
    'assets/icons/avatar_3.png',
    'assets/icons/avatar_4.png',
    'assets/icons/avatar_5.png',
  ];

  /// Reactive notifier — all [UserAvatarWidget] instances listen to this.
  /// Initial value is the default avatar; updated after [init] or [saveAvatar].
  static final ValueNotifier<String> current = ValueNotifier<String>(
    avatarOptions[0],
  );

  /// Call this once at app startup (e.g. in main) to restore the saved avatar.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    current.value = prefs.getString(_prefKey) ?? avatarOptions[0];
  }

  /// Save the selected avatar asset path and notify all listeners immediately.
  static Future<void> saveAvatar(String assetPath) async {
    current.value = assetPath; // Notify immediately (no async wait)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, assetPath);
  }

  /// Load the saved avatar asset path. Returns [avatarOptions[0]] if none saved.
  static Future<String> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? avatarOptions[0];
  }

  /// Clear the saved avatar (resets to default).
  static Future<void> clearAvatar() async {
    current.value = avatarOptions[0];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
