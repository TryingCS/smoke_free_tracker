// lib/widgets/leaderboard_widget.dart
import 'dart:async'; // ADD THIS IMPORT
import 'package:flutter/material.dart';

class LeaderboardWidget extends StatefulWidget {
  final List<Map<String, dynamic>> leaderboard;
  final String? currentUserNickname;

  const LeaderboardWidget({
    super.key,
    required this.leaderboard,
    this.currentUserNickname,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the durations every second
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Just trigger a rebuild to update durations
        });
      }
    });
  }

  String _formatDuration(DateTime start) {
    final duration = DateTime.now().difference(start);
    return '${duration.inDays}d ${(duration.inHours % 24).toString().padLeft(2, '0')}h '
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}m '
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    // Sort the leaderboard by current duration (real-time)
    final sortedLeaderboard =
        List<Map<String, dynamic>>.from(widget.leaderboard)
          ..sort((a, b) => DateTime.now()
              .difference(b['start'])
              .compareTo(DateTime.now().difference(a['start'])));

    // Find user's position
    int userPosition = -1;
    for (int i = 0; i < sortedLeaderboard.length; i++) {
      if (sortedLeaderboard[i]['nickname'] == widget.currentUserNickname) {
        userPosition = i;
        break;
      }
    }

    // Get top 10
    final top10 = sortedLeaderboard.take(10).toList();

    // If user not in top 10, add them at the end
    bool showUserSeparately = userPosition >= 10;
    Map<String, dynamic>? userEntry;
    if (showUserSeparately && userPosition < sortedLeaderboard.length) {
      userEntry = sortedLeaderboard[userPosition];
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Leaderboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Top 10 Longest Smoke-Free Streaks'),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: top10.length + (showUserSeparately ? 2 : 0),
              itemBuilder: (context, index) {
                // Add separator before user entry if outside top 10
                if (showUserSeparately && index == top10.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  );
                }

                if (showUserSeparately && index == top10.length + 1) {
                  return _buildLeaderboardItem(
                    userEntry!,
                    userPosition + 1,
                    true,
                  );
                }

                return _buildLeaderboardItem(
                  top10[index],
                  index + 1,
                  index == userPosition,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    Map<String, dynamic> entry,
    int position,
    bool isCurrentUser,
  ) {
    return Card(
      color: isCurrentUser
          ? Theme.of(context).primaryColor.withOpacity(0.2)
          : null,
      child: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$position',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          entry['nickname'],
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(_formatDuration(entry['start'])),
        trailing: isCurrentUser
            ? const Icon(Icons.person, color: Colors.green)
            : null,
      ),
    );
  }
}
