import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/events_service.dart';

class DeleteEventDialog extends StatefulWidget {
  final Event event;

  const DeleteEventDialog({super.key, required this.event});

  static Future<bool?> show(BuildContext context, Event event) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteEventDialog(event: event),
    );
  }

  @override
  State<DeleteEventDialog> createState() => _DeleteEventDialogState();
}

class _DeleteEventDialogState extends State<DeleteEventDialog> {
  final EventsService _eventsService = EventsService();
  bool _isDeleting = false;

  Future<void> _deleteEvent() async {
    setState(() => _isDeleting = true);

    try {
      await _eventsService.deleteEvent(widget.event.id);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Event deleted successfully')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete event: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Event'),
      content: Text(
        'Are you sure you want to delete this ${widget.event.type ?? "event"}?',
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isDeleting ? null : _deleteEvent,
          child: _isDeleting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
