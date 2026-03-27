import 'package:flutter/material.dart';

class WaterTrackerCard extends StatelessWidget {
  const WaterTrackerCard({
    required this.waterMl,
    required this.onWaterChanged,
    super.key,
  });

  final int waterMl;
  final ValueChanged<int> onWaterChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Hidratación', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('$waterMl ml'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () => onWaterChanged(waterMl + 250),
                  child: const Text('+250 ml'),
                ),
                OutlinedButton(
                  onPressed: waterMl >= 250 ? () => onWaterChanged(waterMl - 250) : null,
                  child: const Text('-250 ml'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
