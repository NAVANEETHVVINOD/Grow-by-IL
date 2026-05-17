import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';

import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';

class GlobalSearchDelegate extends SearchDelegate {
  GlobalSearchDelegate(this.ref);
  final WidgetRef ref;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for tools, projects, or events'));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    // Note: In a real app, we'd use a dedicated search repository.
    // For MVP, we filter the already cached providers.
    final tools = ref.watch(toolsProvider).valueOrNull ?? [];
    final projects = ref.watch(publicProjectsProvider).valueOrNull ?? [];
    final events = ref.watch(activeEventsProvider).valueOrNull ?? [];

    final filteredTools = tools
        .where((t) => t.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final filteredProjects = projects
        .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final filteredEvents = events
        .where((e) => e.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredTools.isEmpty &&
        filteredProjects.isEmpty &&
        filteredEvents.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      children: [
        if (filteredTools.isNotEmpty) ...[
          _buildHeader('Tools'),
          ...filteredTools.map(
            (t) => ListTile(
              leading: const Icon(Icons.build),
              title: Text(t.name),
              subtitle: Text(t.category),
              onTap: () {
                close(context, null);
                context.push('/tools'); // Or specific tool detail if available
              },
            ),
          ),
        ],
        if (filteredProjects.isNotEmpty) ...[
          _buildHeader('Projects'),
          ...filteredProjects.map(
            (p) => ListTile(
              leading: const Icon(Icons.rocket_launch),
              title: Text(p.title),
              subtitle: Text(p.visibility),
              onTap: () {
                close(context, null);
                context.push('/projects/${p.id}');
              },
            ),
          ),
        ],
        if (filteredEvents.isNotEmpty) ...[
          _buildHeader('Events'),
          ...filteredEvents.map(
            (e) => ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(e.title),
              subtitle: Text(e.type),
              onTap: () {
                close(context, null);
                context.push('/events/${e.id}');
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
