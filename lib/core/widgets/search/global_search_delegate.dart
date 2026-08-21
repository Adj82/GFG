import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class GlobalSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    if (query.isEmpty) return const Center(child: Text('Search for tasks, events or members...'));
    
    // Mock Search Results
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.task_alt, color: AppColors.primaryGreen),
          title: Text('Task: $query results'),
          subtitle: const Text('Found in Technical Domain'),
        ),
        ListTile(
          leading: const Icon(Icons.person, color: AppColors.deepAccent),
          title: Text('Member: $query profile'),
          subtitle: const Text('Found in Core Team'),
        ),
      ],
    );
  }
}
