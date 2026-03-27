import 'package:flutter/material.dart';

class FutureExtensionsHint extends StatelessWidget {
  const FutureExtensionsHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Base lista para próximas fases: recetas, planes alimenticios y lista de compras.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
