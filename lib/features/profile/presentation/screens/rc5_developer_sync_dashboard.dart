import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/core/constants/feature_flags.dart';
import 'package:grow/features/profile/domain/pending_profile_mutation.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';

/// RC5 Developer Sync Dashboard — debug diagnostics screen.
///
/// Visible only when [FeatureFlags.kEnableDebugSyncDashboard] is true.
/// Shows queue status, connectivity, replay controls, failed mutation
/// inspector, and an in-memory replay log console.
class RC5DeveloperSyncDashboard extends ConsumerStatefulWidget {
  const RC5DeveloperSyncDashboard({super.key});

  @override
  ConsumerState<RC5DeveloperSyncDashboard> createState() =>
      _RC5DeveloperSyncDashboardState();
}

class _RC5DeveloperSyncDashboardState
    extends ConsumerState<RC5DeveloperSyncDashboard> {
  List<PendingProfileMutation> _queue = [];
  bool _isLoading = true;
  String _buildNumber = '...';
  final List<String> _replayLog = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final queue = await PendingProfileMutationQueue.loadQueue();
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _queue = queue;
          _buildNumber = info.buildNumber;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _addLog('Error loading queue: $e');
      }
    }
  }

  void _addLog(String message) {
    setState(() {
      _replayLog.insert(0, '[${DateTime.now().toIso8601String()}] $message');
      if (_replayLog.length > 50) _replayLog.removeLast();
    });
  }

  int get _failedCount => _queue.where((m) => m.failedPermanently).length;

  int get _pendingCount => _queue.where((m) => !m.failedPermanently).length;

  Color get _statusColor {
    if (_queue.isEmpty) return RC5DesignTokens.success;
    if (_failedCount > 0) return RC5DesignTokens.error;
    return RC5DesignTokens.warning;
  }

  Future<void> _clearQueue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Queue'),
        content: const Text(
          'This will permanently remove all pending mutations. '
          'Any unsynced changes will be lost. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PendingProfileMutationQueue.saveQueue([]);
      _addLog('Queue cleared manually');
      await _loadAll();
    }
  }

  Future<void> _forceReplay() async {
    _addLog('Force replay started…');
    try {
      final repo = ProfileEcosystemRepository();
      await repo.replayQueue();
      _addLog('Force replay completed');
    } catch (e) {
      _addLog('Force replay error: $e');
    }
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(
        title: const Text('Sync Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(RC5DesignTokens.space4),
              children: [
                _buildMetadataHeader(),
                const SizedBox(height: RC5DesignTokens.space4),
                _buildQueueStatusCard(),
                const SizedBox(height: RC5DesignTokens.space4),
                _buildConnectivityCard(),
                const SizedBox(height: RC5DesignTokens.space4),
                _buildControlsSection(),
                const SizedBox(height: RC5DesignTokens.space4),
                _buildFailedMutationInspector(),
                const SizedBox(height: RC5DesignTokens.space4),
                _buildReplayLogConsole(),
              ],
            ),
    );
  }

  // ─── BUILD METADATA HEADER ────────────────────────────

  Widget _buildMetadataHeader() {
    return Container(
      padding: const EdgeInsets.all(RC5DesignTokens.space3),
      decoration: BoxDecoration(
        color: RC5DesignTokens.surface,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusSm),
        border: Border.all(
          color: RC5DesignTokens.border,
          width: RC5DesignTokens.borderWidth,
        ),
        boxShadow: RC5DesignTokens.neoShadow(opacity: 0.15),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: RC5DesignTokens.textSecondary),
          const SizedBox(width: RC5DesignTokens.space2),
          Expanded(
            child: Text(
              'Commit: dev  •  Schema: 006  •  Queue: 1.0  •  Build: $_buildNumber',
              style: RC5DesignTokens.body.copyWith(
                fontSize: 12,
                color: RC5DesignTokens.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUEUE STATUS CARD ────────────────────────────────

  Widget _buildQueueStatusCard() {
    return _DashboardCard(
      title: 'Queue Status',
      icon: Icons.sync_rounded,
      borderColor: _statusColor,
      children: [
        _StatRow(label: 'Total mutations', value: '${_queue.length}'),
        _StatRow(label: 'Pending', value: '$_pendingCount'),
        _StatRow(
          label: 'Permanently failed',
          value: '$_failedCount',
          valueColor: _failedCount > 0 ? RC5DesignTokens.error : null,
        ),
      ],
    );
  }

  // ─── CONNECTIVITY STATE CARD ──────────────────────────

  Widget _buildConnectivityCard() {
    final session = Supabase.instance.client.auth.currentSession;
    final isActive = session != null;

    return _DashboardCard(
      title: 'Connectivity',
      icon: Icons.cloud_rounded,
      borderColor: isActive ? RC5DesignTokens.success : RC5DesignTokens.error,
      children: [
        _StatRow(
          label: 'Supabase session',
          value: isActive ? 'Active' : 'Null',
          valueColor: isActive ? Colors.green : RC5DesignTokens.error,
        ),
      ],
    );
  }

  // ─── CONTROLS SECTION ─────────────────────────────────

  Widget _buildControlsSection() {
    return _DashboardCard(
      title: 'Controls',
      icon: Icons.tune_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Pause Replay', style: RC5DesignTokens.body),
          subtitle: Text(
            PendingProfileMutationQueue.isReplayPaused
                ? 'Queue replay is paused'
                : 'Queue replay is active',
            style: RC5DesignTokens.body.copyWith(
              fontSize: 12,
              color: RC5DesignTokens.textSecondary,
            ),
          ),
          value: PendingProfileMutationQueue.isReplayPaused,
          onChanged: (v) {
            setState(() {
              PendingProfileMutationQueue.isReplayPaused = v;
            });
            _addLog(v ? 'Replay paused' : 'Replay resumed');
          },
        ),
        const SizedBox(height: RC5DesignTokens.space3),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearQueue,
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Clear Queue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RC5DesignTokens.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: RC5DesignTokens.space3),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _forceReplay,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Force Replay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RC5DesignTokens.ink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── FAILED MUTATION INSPECTOR ────────────────────────

  Widget _buildFailedMutationInspector() {
    final failed = _queue.where((m) => m.failedPermanently).toList();

    return _DashboardCard(
      title: 'Failed Mutations (${failed.length})',
      icon: Icons.error_outline_rounded,
      borderColor:
          failed.isNotEmpty ? RC5DesignTokens.error : RC5DesignTokens.border,
      children: failed.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: RC5DesignTokens.space3),
                child: Text(
                  'No permanently failed mutations.',
                  style: RC5DesignTokens.body.copyWith(
                    color: RC5DesignTokens.textSecondary,
                  ),
                ),
              ),
            ]
          : failed.map((m) => _buildMutationTile(m)).toList(),
    );
  }

  Widget _buildMutationTile(PendingProfileMutation m) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        '${m.table} / ${m.type}',
        style: RC5DesignTokens.body.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Row: ${m.rowId}  •  Retries: ${m.retryCount}',
        style: RC5DesignTokens.body.copyWith(
          fontSize: 12,
          color: RC5DesignTokens.textSecondary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: RC5DesignTokens.space3),
          child: Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              _tableRow('ID', m.id),
              _tableRow('Table', m.table),
              _tableRow('Row ID', m.rowId),
              _tableRow('Type', m.type),
              _tableRow('Retry Count', '${m.retryCount}'),
              _tableRow('Created At', m.createdAt.toIso8601String()),
              _tableRow(
                  'Last Attempt', m.lastAttemptAt?.toIso8601String() ?? 'N/A'),
              _tableRow('Payload',
                  const JsonEncoder.withIndent('  ').convert(m.payload)),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              right: RC5DesignTokens.space3, bottom: RC5DesignTokens.space1),
          child: Text(
            '$label:',
            style: RC5DesignTokens.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: RC5DesignTokens.space1),
          child: Text(
            value,
            style: RC5DesignTokens.body.copyWith(
              fontSize: 12,
              fontFamily: 'monospace',
              color: RC5DesignTokens.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ─── REPLAY LOG CONSOLE ───────────────────────────────

  Widget _buildReplayLogConsole() {
    return _DashboardCard(
      title: 'Replay Log',
      icon: Icons.terminal_rounded,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          padding: const EdgeInsets.all(RC5DesignTokens.space2),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(RC5DesignTokens.radiusSm),
          ),
          child: _replayLog.isEmpty
              ? Center(
                  child: Text(
                    'No replay events yet.\nUse "Force Replay" to trigger.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  reverse: false,
                  itemCount: _replayLog.length,
                  itemBuilder: (_, i) => Text(
                    _replayLog[i],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF4EC9B0),
                      height: 1.5,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── SHARED DASHBOARD CARD ──────────────────────────────

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.children,
    this.borderColor,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RC5DesignTokens.space4),
      decoration: BoxDecoration(
        color: RC5DesignTokens.surface,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusSm),
        border: Border.all(
          color: borderColor ?? RC5DesignTokens.border,
          width: RC5DesignTokens.borderWidth,
        ),
        boxShadow: RC5DesignTokens.neoShadow(opacity: 0.15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: RC5DesignTokens.ink),
              const SizedBox(width: RC5DesignTokens.space2),
              Text(title, style: RC5DesignTokens.cardTitle),
            ],
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          ...children,
        ],
      ),
    );
  }
}

// ─── STAT ROW ───────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RC5DesignTokens.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: RC5DesignTokens.body.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? RC5DesignTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}
