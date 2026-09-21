import 'package:flutter/material.dart';

/// Shown once each time the app opens — the user must tap "Got it" to
/// dismiss. Reminds them this app only does arithmetic on values a doctor
/// prescribed; it is not medical advice.
Future<void> showDisclaimerDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.info_outline, color: colorScheme.primary),
        title: const Text('Before you start'),
        content: const Text(
          'This app only does arithmetic on your doctor-prescribed settings. '
          'It is not medical advice — always use your own judgment and '
          'consult your care team.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      );
    },
  );
}
