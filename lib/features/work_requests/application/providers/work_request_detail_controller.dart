import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/work_request_detail.dart';
import '../../services/work_request_data_source.dart';

/// Fetches a single Work Request's full detail by id from the current
/// data source. A plain FutureProvider.family is enough here - there is no
/// mutation, so a full StateNotifier controller would be unnecessary
/// ceremony for a read-only lookup.
final workRequestDetailProvider =
    FutureProvider.autoDispose.family<WorkRequestDetail?, String>(
  (ref, id) {
    final dataSource = ref.watch(workRequestDataSourceProvider);
    return dataSource.fetchDetail(id);
  },
);
