part of 'reminder_bloc.dart';

/// Reminder state
class ReminderState extends Equatable {
  final List<ReminderModel> reminders;
  final ReminderStats? stats;
  final bool isLoading;
  final bool isCreating;
  final bool isSending;
  final String? error;
  final String? successMessage;

  // Filter state
  final ReminderCategory? filterCategory;
  final ReminderStatus? filterStatus;
  final String searchQuery;

  const ReminderState({
    this.reminders = const [],
    this.stats,
    this.isLoading = false,
    this.isCreating = false,
    this.isSending = false,
    this.error,
    this.successMessage,
    this.filterCategory,
    this.filterStatus,
    this.searchQuery = '',
  });

  /// Initial state
  factory ReminderState.initial() => const ReminderState();

  /// Get filtered reminders
  List<ReminderModel> get filteredReminders {
    List<ReminderModel> filtered = List.from(reminders);

    // Filter by category
    if (filterCategory != null) {
      filtered = filtered.where((r) => r.category == filterCategory).toList();
    }

    // Filter by status
    if (filterStatus != null) {
      filtered = filtered.where((r) => r.status == filterStatus).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                r.customerName.toLowerCase().contains(query) ||
                r.description.toLowerCase().contains(query) ||
                r.customerPhone.contains(query),
          )
          .toList();
    }

    return filtered;
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      filterCategory != null || filterStatus != null || searchQuery.isNotEmpty;

  /// Copy with modifications
  ReminderState copyWith({
    List<ReminderModel>? reminders,
    ReminderStats? stats,
    bool? isLoading,
    bool? isCreating,
    bool? isSending,
    String? error,
    String? successMessage,
    ReminderCategory? filterCategory,
    ReminderStatus? filterStatus,
    String? searchQuery,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearCategoryFilter = false,
    bool clearStatusFilter = false,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      filterCategory: clearCategoryFilter
          ? null
          : (filterCategory ?? this.filterCategory),
      filterStatus: clearStatusFilter
          ? null
          : (filterStatus ?? this.filterStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    reminders,
    stats,
    isLoading,
    isCreating,
    isSending,
    error,
    successMessage,
    filterCategory,
    filterStatus,
    searchQuery,
  ];
}
