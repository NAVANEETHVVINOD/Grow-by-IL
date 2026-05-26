import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Represents a pending offline profile mutation that needs to be synced with Supabase.
class PendingProfileMutation {
  const PendingProfileMutation({
    required this.id,
    required this.table,
    required this.rowId,
    required this.payload,
    required this.type,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
    this.failedPermanently = false,
    this.lastKnownServerUpdatedAt,
  });

  final String id;
  final String table;
  final String rowId;
  final Map<String, dynamic> payload;
  final String type; // 'upsert', 'delete'
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final bool failedPermanently;
  final DateTime? lastKnownServerUpdatedAt;

  factory PendingProfileMutation.fromJson(Map<String, dynamic> json) {
    return PendingProfileMutation(
      id: json['id'] as String,
      table: json['table'] as String,
      rowId: json['rowId'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      type: json['type'] as String? ?? 'upsert',
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
      failedPermanently: json['failedPermanently'] as bool? ?? false,
      lastKnownServerUpdatedAt: json['lastKnownServerUpdatedAt'] != null
          ? DateTime.parse(json['lastKnownServerUpdatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'table': table,
        'rowId': rowId,
        'payload': payload,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'lastAttemptAt': lastAttemptAt?.toIso8601String(),
        'failedPermanently': failedPermanently,
        'lastKnownServerUpdatedAt': lastKnownServerUpdatedAt?.toIso8601String(),
      };

  PendingProfileMutation copyWith({
    int? retryCount,
    DateTime? lastAttemptAt,
    bool? failedPermanently,
    DateTime? lastKnownServerUpdatedAt,
  }) {
    return PendingProfileMutation(
      id: id,
      table: table,
      rowId: rowId,
      payload: payload,
      type: type,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      failedPermanently: failedPermanently ?? this.failedPermanently,
      lastKnownServerUpdatedAt: lastKnownServerUpdatedAt ?? this.lastKnownServerUpdatedAt,
    );
  }
}

/// Persistent queue manager using SharedPreferences.
class PendingProfileMutationQueue {
  PendingProfileMutationQueue._();

  static const String _queueKey = 'pending_profile_mutations';

  /// Loads all pending mutations from disk.
  static Future<List<PendingProfileMutation>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_queueKey) ?? [];
    return list
        .map((item) => PendingProfileMutation.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList();
  }

  /// Saves the full list of pending mutations to disk.
  static Future<void> saveQueue(List<PendingProfileMutation> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final list = queue.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_queueKey, list);
  }

  /// Adds a new mutation to the queue, performing deduplication on (table, rowId).
  static Future<void> addMutation({
    required String table,
    required String rowId,
    required Map<String, dynamic> payload,
    String type = 'upsert',
    DateTime? lastKnownServerUpdatedAt,
  }) async {
    final queue = await loadQueue();
    
    // Deduplication: Collapse edits by removing old matching mutations
    queue.removeWhere((item) => item.table == table && item.rowId == rowId);
    
    final newMutation = PendingProfileMutation(
      id: const Uuid().v4(),
      table: table,
      rowId: rowId,
      payload: payload,
      type: type,
      createdAt: DateTime.now().toUtc(),
      lastKnownServerUpdatedAt: lastKnownServerUpdatedAt,
    );
    
    queue.add(newMutation);
    await saveQueue(queue);
  }

  /// Calculates exponential backoff retry delay.
  static Duration getRetryDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;
    // 2^attempt capped at 60 seconds
    final seconds = (1 << attempt).clamp(1, 60);
    return Duration(seconds: seconds);
  }

  /// Handles incrementing retry counts and marking permanent failure if limit is hit.
  static Future<void> reportFailure(String id) async {
    final queue = await loadQueue();
    final index = queue.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = queue[index];
      final newRetryCount = item.retryCount + 1;
      final isPermanentlyFailed = newRetryCount >= 5;
      
      queue[index] = item.copyWith(
        retryCount: newRetryCount,
        lastAttemptAt: DateTime.now().toUtc(),
        failedPermanently: isPermanentlyFailed,
      );
      await saveQueue(queue);
    }
  }

  /// Removes a successfully processed mutation from the queue.
  static Future<void> removeMutation(String id) async {
    final queue = await loadQueue();
    queue.removeWhere((item) => item.id == id);
    await saveQueue(queue);
  }
}
