import 'package:flutter/material.dart';

/// Persistent, non-dismissible reminder that this app only does
/// arithmetic on values a doctor prescribed — it is not medical advice.
/// Shown on every screen, not just once on launch.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.tertiaryContainer,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This app only does arithmetic on your doctor-prescribed settings. '
              'It is not medical advice — always use your own judgment and '
              'consult your care team.',
              style: TextStyle(fontSize: 12, color: colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
