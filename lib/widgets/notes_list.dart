import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotesList extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(String) onAddNote;
  final Function(String) onDeleteNote;

  const NotesList({
    super.key,
    required this.notes,
    required this.onAddNote,
    required this.onDeleteNote,
  });

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  final TextEditingController _noteController = TextEditingController();

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      widget.onAddNote(_noteController.text.trim());
      _noteController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Write your thoughts...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _addNote,
                        icon: const Icon(Icons.send),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.notes.length,
              itemBuilder: (context, index) {
                final note = widget.notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(note['content']),
                    subtitle: Text(
                      DateFormat(
                        'MMM dd, HH:mm',
                      ).format(DateTime.parse(note['created_at'])),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => widget.onDeleteNote(note['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
