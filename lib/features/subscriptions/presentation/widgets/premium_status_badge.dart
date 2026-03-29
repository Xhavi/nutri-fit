import 'package:flutter/material.dart';

class PremiumStatusBadge extends StatelessWidget {
  const PremiumStatusBadge({
    required this.isPremium,
    this.label,
    super.key,
  });

  final bool isPremium;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(
        isPremium ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
        size: 16,
        color: isPremium ? scheme.onPrimaryContainer : scheme.onSecondaryContainer,
      ),
      backgroundColor: isPremium ? scheme.primaryContainer : scheme.secondaryContainer,
      label: Text(
        label ?? (isPremium ? 'AI Premium activo' : 'AI Premium bloqueado'),
        style: TextStyle(
          color: isPremium ? scheme.onPrimaryContainer : scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
