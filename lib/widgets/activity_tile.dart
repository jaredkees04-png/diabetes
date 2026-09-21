import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/models/activity_item.dart';

final _timestampFormat = DateFormat('MMM d • h:mm a');

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (item.kind) {
      ActivityKind.basal => Icons.schedule_outlined,
      ActivityKind.bolus => Icons.calculate_outlined,
      ActivityKind.glucose => Icons.bloodtype_outlined,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: item.flagged ? colorScheme.error : colorScheme.primary),
      title: Text(item.title),
      subtitle: Text(_timestampFormat.format(item.timestamp)),
    );
  }
}
