import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/query_helper.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/models/tool_model.dart';
import '../../../shared/models/user_model.dart';

class ToolRepository {
  ToolRepository(this._client);
  final SupabaseClient _client;

  Future<List<ToolModel>> getTools({
    String? category,
    String? searchQuery,
  }) async {
    final sw = Stopwatch()..start();
    AppLogger.action(LogCategory.tools, 'getTools', {
      'category': category,
      'query': searchQuery,
    });
    try {
      var query = _client.from('tools').select();
      if (category != null && category != 'All') {
        query = query.eq(
          'category',
          category.toLowerCase().replaceAll(' ', '_'),
        );
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }
      final data = await guardedSupabaseCall(query);
      final result =
          (data as List).map((row) => ToolModel.fromJson(row)).toList();
      AppLogger.info(LogCategory.tools,
          'QUERY getTools | ${sw.elapsedMilliseconds}ms | ${result.length} rows');
      return result;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'QUERY getTools FAILED | ${sw.elapsedMilliseconds}ms',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch a single tool by ID.
  Future<ToolModel> getToolById(String id) async {
    AppLogger.action(LogCategory.tools, 'getToolById', {'id': id});
    try {
      final data = await guardedSupabaseCall(
        _client.from('tools').select().eq('id', id).single(),
      );
      return ToolModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'getToolById failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Create a new booking with overlap validation.
  Future<BookingModel> createBooking({
    required String toolId,
    required String userId,
    required DateTime slotStart,
    required DateTime slotEnd,
    String? projectId,
  }) async {
    final sw = Stopwatch()..start();
    AppLogger.action(LogCategory.tools, 'createBooking', {
      'toolId': toolId,
      'userId': userId,
      'start': slotStart,
      'end': slotEnd,
    });

    try {
      // 1. Overlap Validation (MVP Repository check)
      // Check if there are any active or approved bookings that overlap with the requested slot
      final overlapping = await guardedSupabaseCall(
        _client
            .from('tool_bookings')
            .select()
            .eq('tool_id', toolId)
            .inFilter('status', ['approved', 'active'])
            .filter('slot_start', 'lt', slotEnd.toIso8601String())
            .filter('slot_end', 'gt', slotStart.toIso8601String()),
      );

      if ((overlapping as List).isNotEmpty) {
        throw Exception('This time slot overlaps with an existing booking.');
      }

      // 2. Initial status: Default to pending for RC2 safety
      final tool = await getToolById(toolId);
      const status = 'pending';

      // 3. Insert booking (using UTC)
      final data = await guardedSupabaseCall(
        _client
            .from('tool_bookings')
            .insert({
              'tool_id': toolId,
              'user_id': userId,
              'project_id': projectId,
              'slot_start': slotStart.toUtc().toIso8601String(),
              'slot_end': slotEnd.toUtc().toIso8601String(),
              'status': status,
            })
            .select()
            .single(),
      );

      // 4. Create Notification
      try {
        await guardedSupabaseCall(
          _client.from('notifications').insert({
            'user_id': userId,
            'type': 'tool_booking',
            'title':
                status == 'pending' ? 'Booking Pending' : 'Booking Approved!',
            'message': 'Your booking for ${tool.name} is $status.',
            'related_id': data['id'],
          }),
        );
      } catch (notifErr) {
        AppLogger.warn(
          LogCategory.tools,
          'Notification creation failed (likely RLS): $notifErr',
        );
      }

      final result = BookingModel.fromJson(data);
      AppLogger.info(LogCategory.tools,
          'QUERY createBooking | ${sw.elapsedMilliseconds}ms | status: $status');
      return result;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'QUERY createBooking FAILED | ${sw.elapsedMilliseconds}ms',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Approve a pending booking (OpHead/Admin only).
  Future<void> approveBooking(String bookingId, UserModel actor) async {
    AppLogger.action(LogCategory.tools, 'approveBooking', {
      'bookingId': bookingId,
      'actor': actor.email,
    });

    // Repository-level role guard
    if (!AppRole.isAdminRole(actor.role)) {
      throw Exception(AppStrings.unauthorizedAdmin);
    }

    try {
      await guardedSupabaseCall(
        _client.from('tool_bookings').update({
          'status': 'approved',
          'approved_by': actor.id,
          'approved_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', bookingId),
      );

      AppLogger.info(
        LogCategory.tools,
        'Booking $bookingId approved by ${actor.name}',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'approveBooking failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Reject a pending booking (OpHead/Admin only).
  Future<void> rejectBooking(String bookingId, UserModel actor) async {
    AppLogger.action(LogCategory.tools, 'rejectBooking', {
      'bookingId': bookingId,
      'actor': actor.email,
    });

    try {
      // 1. Update status to rejected
      await guardedSupabaseCall(
        _client.from('tool_bookings').update({
          'status': 'rejected',
        }).eq('id', bookingId),
      );

      AppLogger.info(
        LogCategory.tools,
        'Booking $bookingId rejected by ${actor.name}',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'rejectBooking failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Check out a tool (set to active).
  Future<void> checkoutTool(String bookingId) async {
    AppLogger.action(LogCategory.tools, 'checkoutTool', {
      'bookingId': bookingId,
    });
    try {
      await guardedSupabaseCall(
        _client.from('tool_bookings').update({
          'status': 'active',
          'checkout_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', bookingId),
      );
      AppLogger.info(
        LogCategory.tools,
        'Tool checkout successful for booking $bookingId',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'checkoutTool failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Return a tool (set to returned).
  Future<void> returnTool(String bookingId) async {
    AppLogger.action(LogCategory.tools, 'returnTool', {'bookingId': bookingId});
    try {
      await guardedSupabaseCall(
        _client.from('tool_bookings').update({
          'status': 'returned',
          'returned_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', bookingId),
      );
      AppLogger.info(
        LogCategory.tools,
        'Tool return successful for booking $bookingId',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'returnTool failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch user's bookings (including project-linked ones).
  Future<List<BookingModel>> getMyBookings(String userId) async {
    final sw = Stopwatch()..start();
    try {
      // 1. Get projects where user is a member
      final projectData = await guardedSupabaseCall(
        _client
            .from('project_members')
            .select('project_id')
            .eq('user_id', userId),
      );

      final projectIds =
          (projectData as List).map((p) => p['project_id'] as String).toList();

      // 2. Query bookings for user OR user's projects
      var query = _client.from('tool_bookings').select();

      if (projectIds.isNotEmpty) {
        query = query.or(
          'user_id.eq.$userId,project_id.in.(${projectIds.join(",")})',
        );
      } else {
        query = query.eq('user_id', userId);
      }

      final data = await guardedSupabaseCall(
        query.order('created_at', ascending: false),
      );
      final result =
          (data as List).map((row) => BookingModel.fromJson(row)).toList();
      AppLogger.info(LogCategory.tools,
          'QUERY getMyBookings | ${sw.elapsedMilliseconds}ms | ${result.length} rows');
      return result;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'QUERY getMyBookings FAILED | ${sw.elapsedMilliseconds}ms',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch overdue bookings (Admin).
  Future<List<BookingModel>> getOverdueBookings() async {
    try {
      final data = await guardedSupabaseCall(
        _client
            .from('tool_bookings')
            .select()
            .eq('status', 'active')
            .lt('slot_end', DateTime.now().toUtc().toIso8601String()),
      );
      return (data as List).map((row) => BookingModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.tools,
        'getOverdueBookings failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
