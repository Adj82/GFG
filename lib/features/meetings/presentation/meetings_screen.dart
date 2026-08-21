import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, // Mock
        itemBuilder: (context, index) {
          return const Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.ink,
                child: Icon(Icons.videocam, color: Colors.white),
              ),
              title: Text('Weekly Chapter Sync', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Today • 06:00 PM • Google Meet',
                style: TextStyle(color: AppColors.mediumGrey),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
