import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class WorkRequestsScreen extends StatelessWidget {
  const WorkRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _WorkRequestHeader(
                  onBack: () => context.pop(),
                  onCreate: () => _showPreviewNotice(context),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _OperationalSnapshot()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _LifecycleCard()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _RequestCategories()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _ActiveRequestsPreview()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 26)),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _MachineQueuePreview()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RC5Button(
          label: 'Start a Work Request',
          icon: Icons.add_rounded,
          fullWidth: true,
          onPressed: () => _showPreviewNotice(context),
        ),
      ),
    );
  }

  void _showPreviewNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Request builder arrives after PRD/SRS and schema approval.',
        ),
      ),
    );
  }
}

class _WorkRequestHeader extends StatelessWidget {
  const _WorkRequestHeader({
    required this.onBack,
    required this.onCreate,
  });

  final VoidCallback onBack;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
            const Spacer(),
            _StatusPill(
              label: 'V1 foundation',
              icon: Icons.verified_outlined,
              color: RC5DesignTokens.success,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Work Requests',
          style: RC5DesignTokens.hero.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 8),
        Text(
          'Turn ideas, fabrication needs, and technical help into trackable lab work across IDEA Lab and Fab Lab.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: RC5Button(
                label: 'New request',
                icon: Icons.auto_awesome_rounded,
                onPressed: onCreate,
              ),
            ),
            const SizedBox(width: 12),
            _IconButton(
              icon: Icons.tune_rounded,
              onTap: onCreate,
            ),
          ],
        ),
      ],
    );
  }
}

class _OperationalSnapshot extends StatelessWidget {
  const _OperationalSnapshot();

  @override
  Widget build(BuildContext context) {
    const items = [
      _MetricData(
        label: 'Drafts',
        value: '2',
        icon: Icons.edit_note_rounded,
        color: Color(0xFFFFF7A1),
      ),
      _MetricData(
        label: 'In review',
        value: '4',
        icon: Icons.manage_search_rounded,
        color: Color(0xFFDFF4FF),
      ),
      _MetricData(
        label: 'In queue',
        value: '7',
        icon: Icons.queue_rounded,
        color: Color(0xFFF5D6F7),
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == items.last ? 0 : 10,
                ),
                child: _MetricCard(data: item),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      padding: const EdgeInsets.all(14),
      backgroundColor: data.color,
      radius: 18,
      shadowOpacity: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: RC5DesignTokens.ink, size: 20),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: RC5DesignTokens.cardTitle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleCard extends StatelessWidget {
  const _LifecycleCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Draft',
      'Submitted',
      'Review',
      'Needs Changes',
      'Approved',
      'Task Planning',
      'In Progress',
      'Pickup',
      'Completed',
    ];

    return RC5Card(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Lifecycle',
            subtitle: 'Correctable issues loop through Needs Changes.',
            icon: Icons.schema_rounded,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final step in steps)
                RC5Chip(
                  label: step,
                  compact: true,
                  isSelected: step == 'Review' || step == 'In Progress',
                  color: step == 'Needs Changes'
                      ? RC5DesignTokens.warning
                      : RC5DesignTokens.ink,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7A1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RC5DesignTokens.border,
                width: RC5DesignTokens.borderWidth,
              ),
            ),
            child: Text(
              'Permanent rejection is reserved for safety, policy, prohibited work, or duplicate requests.',
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w800,
                color: RC5DesignTokens.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCategories extends StatelessWidget {
  const _RequestCategories();

  @override
  Widget build(BuildContext context) {
    const categories = [
      _CategoryData(
        title: 'Laser Cutting',
        subtitle: 'Sheets, acrylic, MDF',
        icon: Icons.content_cut_rounded,
        color: Color(0xFFFFD6D6),
      ),
      _CategoryData(
        title: '3D Printing',
        subtitle: 'Bambu, Snapmaker, Flashforge',
        icon: Icons.view_in_ar_rounded,
        color: Color(0xFFDFF4FF),
      ),
      _CategoryData(
        title: 'PCB Milling',
        subtitle: 'Boards and traces',
        icon: Icons.memory_rounded,
        color: Color(0xFFDDF5D7),
      ),
      _CategoryData(
        title: 'Design Help',
        subtitle: 'CAD, layout, review',
        icon: Icons.design_services_rounded,
        color: Color(0xFFF5D6F7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Request types',
          subtitle: 'Master data categories planned for V1.',
          icon: Icons.category_rounded,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.14,
          ),
          itemBuilder: (context, index) {
            return _CategoryCard(data: categories[index]);
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: data.color,
      padding: const EdgeInsets.all(14),
      radius: 18,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${data.title} request builder coming soon.')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: RC5DesignTokens.ink, size: 24),
          const Spacer(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveRequestsPreview extends StatelessWidget {
  const _ActiveRequestsPreview();

  @override
  Widget build(BuildContext context) {
    const requests = [
      _RequestData(
        title: 'Robotics chassis prototype',
        status: 'Needs Changes',
        owner: 'Machine Head review',
        priority: 'High',
        color: Color(0xFFFFF7A1),
      ),
      _RequestData(
        title: 'PCB enclosure mockup',
        status: 'Task Planning',
        owner: 'Design + 3D Print',
        priority: 'Normal',
        color: Color(0xFFDFF4FF),
      ),
      _RequestData(
        title: 'Workshop badge laser cut',
        status: 'Ready For Pickup',
        owner: 'Laser team',
        priority: 'Urgent',
        color: Color(0xFFDDF5D7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Active requests',
          subtitle: 'Preview data until the V1 schema is approved.',
          icon: Icons.assignment_rounded,
        ),
        const SizedBox(height: 16),
        for (final request in requests) ...[
          _RequestRow(data: request),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.data});

  final _RequestData data;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(16),
      radius: 18,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request detail screen coming soon.')),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: RC5DesignTokens.border,
                width: RC5DesignTokens.borderWidth,
              ),
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: RC5DesignTokens.ink,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.status} - ${data.owner}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC5DesignTokens.body.copyWith(
                    color: RC5DesignTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _PriorityBadge(label: data.priority),
        ],
      ),
    );
  }
}

class _MachineQueuePreview extends StatelessWidget {
  const _MachineQueuePreview();

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      gradient: RC5DesignTokens.monochromeGradient,
      borderColor: RC5DesignTokens.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: RC5DesignTokens.ink,
                    width: RC5DesignTokens.borderWidth,
                  ),
                ),
                child: const Icon(
                  Icons.precision_manufacturing_rounded,
                  color: RC5DesignTokens.ink,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Machine queue preview',
                  style: RC5DesignTokens.cardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _QueueLine(
            machine: 'Laser Cutter',
            task: 'Workshop badge cut',
            estimate: '45 min',
          ),
          const _QueueLine(
            machine: '3D Printer',
            task: 'PCB enclosure body',
            estimate: '3 hr',
          ),
          const _QueueLine(
            machine: 'PCB Milling',
            task: 'Sensor board trace',
            estimate: '1 hr',
          ),
        ],
      ),
    );
  }
}

class _QueueLine extends StatelessWidget {
  const _QueueLine({
    required this.machine,
    required this.task,
    required this.estimate,
  });

  final String machine;
  final String task;
  final String estimate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              machine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RC5DesignTokens.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RC5DesignTokens.body.copyWith(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            estimate,
            style: RC5DesignTokens.body.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: RC5DesignTokens.primary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RC5DesignTokens.ink,
              width: RC5DesignTokens.borderWidth,
            ),
          ),
          child: Icon(icon, color: RC5DesignTokens.ink, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RC5DesignTokens.sectionTitle),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: RC5DesignTokens.body.copyWith(
                  color: RC5DesignTokens.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: 16,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: RC5DesignTokens.ink, size: 22),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RC5DesignTokens.ink,
          width: RC5DesignTokens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RC5DesignTokens.ink, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: RC5DesignTokens.body.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Urgent' => const Color(0xFFFFD6D6),
      'High' => const Color(0xFFFFF7A1),
      _ => const Color(0xFFDFF4FF),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RC5DesignTokens.ink,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: RC5DesignTokens.body.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _CategoryData {
  const _CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _RequestData {
  const _RequestData({
    required this.title,
    required this.status,
    required this.owner,
    required this.priority,
    required this.color,
  });

  final String title;
  final String status;
  final String owner;
  final String priority;
  final Color color;
}
