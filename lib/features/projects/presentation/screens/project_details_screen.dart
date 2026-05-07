import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/project_model.dart';
import '../../../../shared/models/project_member_model.dart';
import '../../../../shared/models/project_update_model.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/project_providers.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));
    final membersAsync = ref.watch(projectMembersProvider(widget.projectId));
    final membershipAsync = ref.watch(userMembershipProvider(widget.projectId));
    final updatesAsync = ref.watch(projectUpdatesProvider(widget.projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: projectAsync.when(
        data: (project) => CustomScrollView(
          slivers: [
            _buildSliverAppBar(project),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: _buildHeader(project, membershipAsync.valueOrNull),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                Container(
                  color: AppColors.background,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.navy,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.yellow,
                    indicatorWeight: 4,
                    labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'OVERVIEW'),
                      Tab(text: 'UPDATES'),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSizes.lg),
              sliver: SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(project, membersAsync),
                    _buildUpdatesTab(project, updatesAsync, membershipAsync.valueOrNull),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: projectAsync.when(
        data: (project) => _buildBottomActions(project, membershipAsync.valueOrNull),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSliverAppBar(ProjectModel project) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.navy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: project.coverImageUrl != null
            ? Image.network(project.coverImageUrl!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy.withOpacity(0.8), AppColors.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.architecture_rounded, size: 64, color: AppColors.yellow),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(ProjectModel project, ProjectMemberModel? membership) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _TypeBadge(type: project.type),
            const SizedBox(width: AppSizes.sm),
            _StatusBadge(status: project.status),
            const Spacer(),
            if (membership?.canManage ?? false)
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: AppColors.navy),
                onPressed: () => _showProjectActions(project, membership!),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          project.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(ProjectModel project, AsyncValue<List<ProjectMemberModel>> membersAsync) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            project.description ?? 'No description provided.',
            style: GoogleFonts.dmSans(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            'Team',
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: AppSizes.md),
          membersAsync.when(
            data: (members) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members.map((m) => _MemberChip(member: m)).toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, __) => Text('Failed to load members: $e'),
          ),
          const SizedBox(height: AppSizes.xl),
          if (project.externalLink != null) _buildExternalLink(project.externalLink!),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab(ProjectModel project, AsyncValue<List<ProjectUpdateModel>> updatesAsync, ProjectMemberModel? membership) {
    return Column(
      children: [
        if (membership != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.lg),
            child: NeoButton(
              label: 'Post Update',
              icon: Icons.add_comment_rounded,
              onPressed: () => _showAddUpdateSheet(project),
            ),
          ),
        Expanded(
          child: updatesAsync.when(
            data: (updates) {
              if (updates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history_rounded, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: AppSizes.md),
                      Text('No updates yet.', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: updates.length,
                itemBuilder: (context, index) => _UpdateCard(update: updates[index]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Text('Error: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildExternalLink(String url) {
    return NeoCard(
      color: Colors.white,
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: AppColors.navy),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              'View External Resources',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ProjectModel project, ProjectMemberModel? membership) {
    final isMember = membership != null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.navy, width: 2)),
      ),
      child: Row(
        children: [
          if (isMember)
            Expanded(
              child: NeoButton(
                label: 'Leave Project',
                color: Colors.white,
                onPressed: _isLoading ? null : () => _handleLeave(project.id),
              ),
            )
          else
            Expanded(
              child: NeoButton(
                label: 'Join Project',
                onPressed: _isLoading ? null : () => _handleJoin(project.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleJoin(String projectId) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(projectRepositoryProvider).joinProject(projectId, user.id);
      ref.invalidate(projectMembersProvider(projectId));
      ref.invalidate(userProjectsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined the team!'), backgroundColor: AppColors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLeave(String projectId) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Project?'),
        content: const Text('Are you sure you want to leave this team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Leave')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(projectRepositoryProvider).leaveProject(projectId, user.id);
      ref.invalidate(projectMembersProvider(projectId));
      ref.invalidate(userProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProjectActions(ProjectModel project, ProjectMemberModel membership) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Project Actions',
                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              if (membership.role == 'owner') ...[
                _buildActionButton(
                  label: 'Transfer Ownership',
                  icon: Icons.swap_horiz_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    _showTransferDialog(project);
                  },
                ),
                const SizedBox(height: AppSizes.md),
              ],
              _buildActionButton(
                label: 'Archive Project',
                icon: Icons.archive_outlined,
                color: AppColors.red,
                onTap: () {
                  Navigator.pop(context);
                  _handleArchive(project.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onTap, Color? color}) {
    return NeoCard(
      color: Colors.white,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.navy),
          const SizedBox(width: AppSizes.md),
          Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: color ?? AppColors.navy)),
        ],
      ),
    );
  }

  Future<void> _handleArchive(String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Project?'),
        content: const Text('Archived projects are hidden from Explore but preserved for history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Archive')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(projectRepositoryProvider).archiveProject(projectId);
      ref.invalidate(projectDetailProvider(projectId));
      ref.invalidate(publicProjectsProvider);
      ref.invalidate(userProjectsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTransferDialog(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ownership Transfer'),
        content: const Text('Please select a team member to transfer ownership to. (Coming soon)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddUpdateSheet(ProjectModel project) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: AppSizes.lg, right: AppSizes.lg, top: AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Post Update', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What\'s happening with the project?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            NeoButton(
              label: 'Post',
              onPressed: () async {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                final user = ref.read(currentUserProvider).valueOrNull;
                if (user == null) return;

                await ref.read(projectRepositoryProvider).addProjectUpdate(project.id, user.id, content);
                ref.invalidate(projectUpdatesProvider(project.id));
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.update});
  final ProjectUpdateModel update;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.surface,
                  backgroundImage: update.userAvatar != null ? NetworkImage(update.userAvatar!) : null,
                  child: update.userAvatar == null ? const Icon(Icons.person, size: 12) : null,
                ),
                const SizedBox(width: 8),
                Text(update.userName ?? 'User', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Text(update.createdAt.toLocal().toString().substring(5, 16), style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(update.content, style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(4)),
      child: Text(type.toUpperCase(), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = status == 'active' ? AppColors.green : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color, width: 1.5), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});
  final ProjectMemberModel member;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.navy, width: 1.5), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.yellow,
            child: Text((member.userName ?? '?')[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          Text(member.userName ?? 'User', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4)),
            child: Text(member.role.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
