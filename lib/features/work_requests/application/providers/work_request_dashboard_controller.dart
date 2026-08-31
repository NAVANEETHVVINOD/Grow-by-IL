import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/work_request_options.dart';
import '../../models/work_request_summary.dart';
import '../../services/work_request_data_source.dart';

enum WorkRequestSortBy {
  newest,
  oldest,
  priorityDescending,
  alphabetical,
}

extension WorkRequestSortByLabel on WorkRequestSortBy {
  String get label {
    return switch (this) {
      WorkRequestSortBy.newest => 'Newest First',
      WorkRequestSortBy.oldest => 'Oldest First',
      WorkRequestSortBy.priorityDescending => 'Highest Priority',
      WorkRequestSortBy.alphabetical => 'Alphabetical (A-Z)',
    };
  }
}

class WorkRequestDashboardState {
  const WorkRequestDashboardState({
    required this.requests,
    required this.allRequests,
    this.isLoading = true,
    this.searchQuery = '',
    this.statusFilter,
    this.priorityFilter,
    this.sortBy = WorkRequestSortBy.newest,
  });

  final List<WorkRequestSummary> requests;
  final List<WorkRequestSummary> allRequests;
  final bool isLoading;
  final String searchQuery;
  final WorkRequestStatus? statusFilter;
  final WorkRequestPriority? priorityFilter;
  final WorkRequestSortBy sortBy;

  int get draftCount =>
      allRequests.where((r) => r.status == WorkRequestStatus.draft).length;
  int get submittedCount => allRequests
      .where((r) =>
          r.status == WorkRequestStatus.submitted ||
          r.status == WorkRequestStatus.underReview)
      .length;
  int get approvedCount => allRequests
      .where((r) =>
          r.status == WorkRequestStatus.approved ||
          r.status == WorkRequestStatus.queued)
      .length;
  int get completedCount =>
      allRequests.where((r) => r.status == WorkRequestStatus.completed).length;

  WorkRequestDashboardState copyWith({
    List<WorkRequestSummary>? requests,
    List<WorkRequestSummary>? allRequests,
    bool? isLoading,
    String? searchQuery,
    WorkRequestStatus? statusFilter,
    bool clearStatusFilter = false,
    WorkRequestPriority? priorityFilter,
    bool clearPriorityFilter = false,
    WorkRequestSortBy? sortBy,
  }) {
    return WorkRequestDashboardState(
      requests: requests ?? this.requests,
      allRequests: allRequests ?? this.allRequests,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      priorityFilter:
          clearPriorityFilter ? null : priorityFilter ?? this.priorityFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class WorkRequestDashboardController
    extends StateNotifier<WorkRequestDashboardState> {
  WorkRequestDashboardController({
    required WorkRequestDataSource dataSource,
  })  : _dataSource = dataSource,
        super(const WorkRequestDashboardState(requests: [], allRequests: [])) {
    _initSubscription();
  }

  final WorkRequestDataSource _dataSource;
  StreamSubscription<List<WorkRequestSummary>>? _subscription;

  void _initSubscription() {
    _subscription = _dataSource.watchAll().listen((list) {
      if (mounted) {
        state = state.copyWith(allRequests: list, isLoading: false);
        _applyFiltersAndSorting();
      }
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSorting();
  }

  void setStatusFilter(WorkRequestStatus? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    _applyFiltersAndSorting();
  }

  void setPriorityFilter(WorkRequestPriority? priority) {
    state = state.copyWith(
      priorityFilter: priority,
      clearPriorityFilter: priority == null,
    );
    _applyFiltersAndSorting();
  }

  void setSortBy(WorkRequestSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFiltersAndSorting();
  }

  void _applyFiltersAndSorting() {
    var filteredList = List<WorkRequestSummary>.from(state.allRequests);

    // 1. Text Search Filter (title, purpose, subcategories)
    if (state.searchQuery.trim().isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filteredList = filteredList.where((req) {
        final titleMatch = req.title.toLowerCase().contains(query);
        final purposeMatch = req.purpose.toLowerCase().contains(query);
        final subcategoryMatch = req.subcategoryLabels.any(
          (sub) => sub.toLowerCase().contains(query),
        );
        return titleMatch || purposeMatch || subcategoryMatch;
      }).toList();
    }

    // 2. Status Filter
    if (state.statusFilter != null) {
      filteredList = filteredList
          .where((req) => req.status == state.statusFilter)
          .toList();
    }

    // 3. Priority Filter
    if (state.priorityFilter != null) {
      filteredList = filteredList
          .where((req) => req.priority == state.priorityFilter)
          .toList();
    }

    // 4. Sorting
    filteredList.sort((a, b) {
      switch (state.sortBy) {
        case WorkRequestSortBy.newest:
          return b.createdAt.compareTo(a.createdAt);
        case WorkRequestSortBy.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case WorkRequestSortBy.priorityDescending:
          final aWeight = _priorityWeight(a.priority);
          final bWeight = _priorityWeight(b.priority);
          final weightCompare = bWeight.compareTo(aWeight);
          if (weightCompare != 0) return weightCompare;
          // Fallback to newest
          return b.createdAt.compareTo(a.createdAt);
        case WorkRequestSortBy.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    state = state.copyWith(requests: filteredList);
  }

  int _priorityWeight(WorkRequestPriority priority) {
    return switch (priority) {
      WorkRequestPriority.low => 0,
      WorkRequestPriority.normal => 1,
      WorkRequestPriority.high => 2,
    };
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final workRequestDashboardControllerProvider =
    StateNotifierProvider.autoDispose<WorkRequestDashboardController,
        WorkRequestDashboardState>((ref) {
  final dataSource = ref.watch(workRequestDataSourceProvider);
  return WorkRequestDashboardController(dataSource: dataSource);
});
