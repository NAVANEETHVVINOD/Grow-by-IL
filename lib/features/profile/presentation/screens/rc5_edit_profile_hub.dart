import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class RC5EditProfileHub extends StatelessWidget {
  const RC5EditProfileHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HubTile(
            icon: Icons.person_rounded,
            title: 'Basic Profile',
            subtitle: 'Name, bio, department, profile image',
            onTap: () => context.push('/profile/edit/basic'),
          ),
          _HubTile(
            icon: Icons.link_rounded,
            title: 'Social Links',
            subtitle: 'GitHub, LinkedIn, and website',
            onTap: () => context.push('/profile/edit/social-links'),
          ),
          _HubTile(
            icon: Icons.badge_rounded,
            title: 'Portfolio Settings',
            subtitle: 'Public/private profile visibility',
            onTap: () => context.push('/profile/edit/visibility'),
          ),
          _HubTile(
            icon: Icons.folder_copy_rounded,
            title: 'Projects',
            subtitle: 'Project highlights and portfolio order',
          ),
          _HubTile(
            icon: Icons.work_rounded,
            title: 'Work Experience',
            subtitle: 'Internships and part-time roles',
          ),
          _HubTile(
            icon: Icons.school_rounded,
            title: 'Education',
            subtitle: 'Department, batch, and timeline',
            onTap: () => context.push('/profile/edit/education'),
          ),
          _HubTile(
            icon: Icons.volunteer_activism_rounded,
            title: 'Volunteering',
            subtitle: 'Community and social participation',
          ),
          _HubTile(
            icon: Icons.code_rounded,
            title: 'Code Languages',
            subtitle: 'Familiarity levels and tools',
            onTap: () => context.push('/profile/edit/skills'),
          ),
          _HubTile(
            icon: Icons.interests_rounded,
            title: 'Interests',
            subtitle: 'Maker interests and activity focus',
            onTap: () => context.push('/profile/edit/interests'),
          ),
          const SizedBox(height: RC5DesignTokens.space5),
          RC5Button(
            label: 'Done',
            icon: Icons.check_rounded,
            fullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RC5DesignTokens.space3),
      child: RC5Card(
        backgroundColor: Colors.white,
        shadowOpacity: 0.65,
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Detailed edit pages come in the next profile slice.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
        child: Row(
          children: [
            Icon(icon, color: RC5DesignTokens.ink),
            const SizedBox(width: RC5DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RC5DesignTokens.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
