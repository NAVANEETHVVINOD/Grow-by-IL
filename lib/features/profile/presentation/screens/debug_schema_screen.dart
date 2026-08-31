import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/domain/pending_profile_mutation.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';

class DebugSchemaScreen extends ConsumerStatefulWidget {
  const DebugSchemaScreen({super.key});

  @override
  ConsumerState<DebugSchemaScreen> createState() => _DebugSchemaScreenState();
}

class _DebugSchemaScreenState extends ConsumerState<DebugSchemaScreen> {
  bool _isLoading = true;
  bool _schemaOk = false;
  int _queueSize = 0;
  int _pendingMutations = 0;
  bool _isReplayPaused = false;
  bool _profileLoaded = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDebugStatus();
  }

  Future<void> _loadDebugStatus() async {
    setState(() => _isLoading = true);

    try {
      // 1. Check Schema
      try {
        await Supabase.instance.client
            .from('user_profiles')
            .select('id')
            .limit(1);
        _schemaOk = true;
      } catch (e) {
        _schemaOk = false;
        _errorMessage = e.toString();
      }

      // 2. Queue Status
      final queue = await PendingProfileMutationQueue.loadQueue();
      _queueSize = queue.length;
      _pendingMutations = queue.where((m) => !m.failedPermanently).length;
      _isReplayPaused = PendingProfileMutationQueue.isReplayPaused;

      // 3. Profile Status
      final profileState = ref.read(rc5ProfileHeaderProvider);
      _profileLoaded = profileState.hasValue && profileState.value != null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _forceReplay() async {
    try {
      await ref.read(profileEcosystemRepositoryProvider).replayQueue();
      await _loadDebugStatus();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Replay triggered.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Replay failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Schema & Queue Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugStatus,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  title: const Text('Schema OK'),
                  trailing: Icon(
                    _schemaOk ? Icons.check_circle : Icons.error,
                    color: _schemaOk ? Colors.green : Colors.red,
                  ),
                  subtitle: _schemaOk ? null : Text(_errorMessage),
                ),
                ListTile(
                  title: const Text('Queue Size'),
                  trailing: Text('$_queueSize',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: const Text('Pending Mutations'),
                  trailing: Text('$_pendingMutations',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: const Text('Replay Status'),
                  trailing: Text(_isReplayPaused ? 'PAUSED' : 'ACTIVE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isReplayPaused ? Colors.orange : Colors.green,
                      )),
                ),
                ListTile(
                  title: const Text('Profile Loaded'),
                  trailing: Icon(
                    _profileLoaded ? Icons.check_circle : Icons.cancel,
                    color: _profileLoaded ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      _queueSize > 0 && !_isReplayPaused ? _forceReplay : null,
                  child: const Text('Force Queue Replay'),
                ),
              ],
            ),
    );
  }
}
