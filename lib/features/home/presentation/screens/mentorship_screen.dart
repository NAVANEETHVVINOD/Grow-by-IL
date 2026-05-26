import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mentors = [
      _Mentor(
        name: 'Navaneeth Kannan',
        role: 'Hardware & IoT Lead',
        expertise: 'Arduino, ESP32, Embedded C',
        color: const Color(0xFFF7EEB4), // Yellow
      ),
      _Mentor(
        name: 'Aiswarya Roy',
        role: 'Product Designer',
        expertise: 'UI/UX, Figma, Fabrication Design',
        color: const Color(0xFFE5E7EB), // Gray
      ),
      _Mentor(
        name: 'Rahul Sen',
        role: 'Full Stack Developer',
        expertise: 'Flutter, Node.js, Supabase',
        color: const Color(0xFFDFF4FF), // Blue
      ),
    ];

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(
        backgroundColor: RC5DesignTokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: RC5DesignTokens.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mentorship',
          style: GoogleFonts.spaceGrotesk(
            color: RC5DesignTokens.ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              'Get Mentorship & Support',
              style: RC5DesignTokens.hero,
            ),
            const SizedBox(height: 12),
            Text(
              'Stuck on a hardware blocker or design constraint? Connect with experienced makers in the community.',
              style: RC5DesignTokens.body.copyWith(
                color: RC5DesignTokens.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            ...mentors.map((mentor) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: NeoCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RC5Avatar(
                            displayName: mentor.name,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mentor.name,
                                  style: RC5DesignTokens.cardTitle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mentor.role,
                                  style: RC5DesignTokens.body.copyWith(
                                    fontSize: 12,
                                    color: RC5DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'EXPERTISE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: RC5DesignTokens.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor.expertise,
                        style: RC5DesignTokens.body.copyWith(
                          color: RC5DesignTokens.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RC5Button(
                        label: 'Request Consultation',
                        icon: Icons.chat_bubble_outline_rounded,
                        variant: RC5ButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Support request sent to ${mentor.name}!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
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

class _Mentor {
  const _Mentor({
    required this.name,
    required this.role,
    required this.expertise,
    required this.color,
  });

  final String name;
  final String role;
  final String expertise;
  final Color color;
}
