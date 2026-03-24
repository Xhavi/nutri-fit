import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.leading,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 8)],
        Text(label),
      ],
    );

    if (isSecondary) {
      return OutlinedButton(onPressed: onPressed, child: child);
    }

    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
