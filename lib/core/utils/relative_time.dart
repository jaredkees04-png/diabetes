/// A short "time ago" label for the dashboard, e.g. "Just now", "5m ago",
/// "3h ago", "2d ago".
String relativeTime(DateTime timestamp, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(timestamp);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  return '${difference.inDays}d ago';
}
