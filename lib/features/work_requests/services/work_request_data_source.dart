import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/work_request_detail.dart';
import '../models/work_request_draft.dart';
import '../models/work_request_summary.dart';
import 'mock_work_request_data_source.dart';

abstract class WorkRequestDataSource {
  Stream<List<WorkRequestSummary>> watchAll();
  Future<void> submit(WorkRequestDraft draft);
  Future<WorkRequestDetail?> fetchDetail(String id);
  void seed();
  void clear();
  void reset();
}

final workRequestDataSourceProvider = Provider<WorkRequestDataSource>((ref) {
  final dataSource = MockWorkRequestDataSource();
  ref.onDispose(() => dataSource.dispose());
  return dataSource;
});
