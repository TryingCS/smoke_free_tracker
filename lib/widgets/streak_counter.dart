import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakCounter extends StatefulWidget {
  final DateTime? streakStart;
  final Duration currentDuration;
  final List<Map<String, dynamic>> relapses;
  final VoidCallback onStartStreak;
  final Function(String?) onRegisterRelapse;

  const StreakCounter({
    super.key,
    required this.streakStart,
    required this.currentDuration,
    required this.relapses,
    required this.onStartStreak,
    required this.onRegisterRelapse,
  });

  @override
  State<StreakCounter> createState() => _StreakCounterState();
}

class _StreakCounterState extends State<StreakCounter> {
  final TextEditingController _relapseNoteController = TextEditingController();

  String _formatDuration(Duration duration) {
    return '${duration.inDays}d ${(duration.inHours % 24).toString().padLeft(2, '0')}h '
        '${(duration.inMinutes % 60).toString().padLeft(2, '0')}m '
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}s';
  }

  void _showRelapseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Relapse'),
        content: TextField(
          controller: _relapseNoteController,
          decoration: const InputDecoration(
            labelText: 'Optional note about this relapse',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final note = _relapseNoteController.text.trim().isNotEmpty
                  ? _relapseNoteController.text.trim()
                  : null;
              widget.onRegisterRelapse(note);
              _relapseNoteController.clear();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Relapse'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              widget.streakStart == null
                  ? Icons.smoking_rooms
                  : Icons.smoke_free,
              size: 80,
              color: widget.streakStart == null
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              widget.streakStart == null
                  ? 'No active streak'
                  : 'Current Streak',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _formatDuration(widget.currentDuration),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.streakStart != null
                  ? 'Started ${DateFormat('MMM dd, yyyy HH:mm').format(widget.streakStart!)}'
                  : 'Tap "Start Tracking" to begin',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (widget.streakStart == null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.onStartStreak,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Tracking',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            if (widget.streakStart != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _showRelapseDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register Relapse',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (widget.relapses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 40),
                  const Text(
                    'Relapse History',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...widget.relapses
                      .map(
                        (relapse) => Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.warning,
                              color: Colors.red,
                            ),
                            title: Text(
                              DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(DateTime.parse(relapse['created_at'])),
                            ),
                            subtitle: relapse['note'] != null
                                ? Text(relapse['note'])
                                : const Text('No note provided'),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
