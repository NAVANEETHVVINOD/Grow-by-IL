import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/shared/widgets/neo_card.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      _Resource(
        title: 'Laser Cutter Safety & Operations',
        category: 'Machine Safety',
        readTime: '6 min read',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFFEA00),
      ),
      _Resource(
        title: 'Preparing Vector Files for CNC Routing',
        category: 'Fabrication',
        readTime: '10 min read',
        icon: Icons.architecture_rounded,
        color: const Color(0xFF38BDF8),
      ),
      _Resource(
        title: 'ESP32 Realtime Database Setup',
        category: 'IoT & Firmware',
        readTime: '8 min read',
        icon: Icons.developer_board_rounded,
        color: const Color(0xFF2ECC71),
      ),
      _Resource(
        title: 'Arduino Basics for Beginners',
        category: 'Electronics',
        readTime: '5 min read',
        icon: Icons.integration_instructions_rounded,
        color: const Color(0xFFFF8EFA),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Knowledge Base',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              'Learning Paths',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access our community library of tutorials, safety guidelines, and electronics cheatsheets.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            ...resources.map((resource) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeoCard(
                  color: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening "${resource.title}"...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: resource.color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.navy, width: 2),
                        ),
                        child: Icon(resource.icon, color: AppColors.navy),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${resource.category} • ${resource.readTime}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Resource {
  const _Resource({
    required this.title,
    required this.category,
    required this.readTime,
    required this.icon,
    required this.color,
  });

  final String title;
  final String category;
  final String readTime;
  final IconData icon;
  final Color color;
}
