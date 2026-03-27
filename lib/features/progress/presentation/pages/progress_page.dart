import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/layouts/internal_base_layout.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_ProgressSnapshot> snapshots = <_ProgressSnapshot>[
      _ProgressSnapshot(
        label: 'Sem 1',
        weightKg: 74.8,
        waistCm: 84,
        hipCm: 99,
        chestCm: 95,
      ),
      _ProgressSnapshot(
        label: 'Sem 2',
        weightKg: 74.2,
        waistCm: 83,
        hipCm: 98,
        chestCm: 95,
      ),
      _ProgressSnapshot(
        label: 'Sem 3',
        weightKg: 73.7,
        waistCm: 82,
        hipCm: 97,
        chestCm: 94,
      ),
      _ProgressSnapshot(
        label: 'Sem 4',
        weightKg: 73.3,
        waistCm: 81,
        hipCm: 96,
        chestCm: 94,
      ),
      _ProgressSnapshot(
        label: 'Sem 5',
        weightKg: 72.9,
        waistCm: 80,
        hipCm: 96,
        chestCm: 93,
      ),
    ];

    const _AdherenceSummary adherence = _AdherenceSummary(
      streakDays: 9,
      adherenceRate: 0.82,
      completedDays: 23,
      evaluatedDays: 28,
    );

    final _ProgressSnapshot first = snapshots.first;
    final _ProgressSnapshot latest = snapshots.last;

    return InternalBaseLayout(
      title: 'Progreso',
      currentIndex: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _WeightCard(latest: latest, baseline: first),
            const SizedBox(height: 16),
            _MeasurementsCard(latest: latest, baseline: first),
            const SizedBox(height: 16),
            _AdherenceCard(adherence: adherence),
            const SizedBox(height: 16),
            _TrendCard(snapshots: snapshots),
            const SizedBox(height: 16),
            _HistoryCard(snapshots: snapshots),
          ],
        ),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.latest, required this.baseline});

  final _ProgressSnapshot latest;
  final _ProgressSnapshot baseline;

  @override
  Widget build(BuildContext context) {
    final double delta = latest.weightKg - baseline.weightKg;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Peso', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${latest.weightKg.toStringAsFixed(1)} kg', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              delta <= 0
                  ? 'Cambio total: ${delta.abs().toStringAsFixed(1)} kg menos.'
                  : 'Cambio total: ${delta.toStringAsFixed(1)} kg más.',
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementsCard extends StatelessWidget {
  const _MeasurementsCard({required this.latest, required this.baseline});

  final _ProgressSnapshot latest;
  final _ProgressSnapshot baseline;

  String _buildDelta(double latestValue, double baselineValue) {
    final double delta = latestValue - baselineValue;
    if (delta == 0) {
      return 'sin cambios';
    }
    final String direction = delta < 0 ? '▼' : '▲';
    return '$direction ${delta.abs().toStringAsFixed(1)} cm';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Medidas corporales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _MeasurementRow(
              label: 'Cintura',
              current: '${latest.waistCm.toStringAsFixed(0)} cm',
              delta: _buildDelta(latest.waistCm, baseline.waistCm),
            ),
            _MeasurementRow(
              label: 'Cadera',
              current: '${latest.hipCm.toStringAsFixed(0)} cm',
              delta: _buildDelta(latest.hipCm, baseline.hipCm),
            ),
            _MeasurementRow(
              label: 'Pecho',
              current: '${latest.chestCm.toStringAsFixed(0)} cm',
              delta: _buildDelta(latest.chestCm, baseline.chestCm),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({required this.label, required this.current, required this.delta});

  final String label;
  final String current;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(current, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 10),
          Text(delta),
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.adherence});

  final _AdherenceSummary adherence;

  @override
  Widget build(BuildContext context) {
    final int percentage = (adherence.adherenceRate * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Rachas y adherencia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Racha actual: ${adherence.streakDays} días'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: adherence.adherenceRate),
            const SizedBox(height: 8),
            Text('$percentage% de adherencia (${adherence.completedDays}/${adherence.evaluatedDays} días)'),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.snapshots});

  final List<_ProgressSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final List<double> points = snapshots.map((e) => e.weightKg).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Tendencia de peso (5 semanas)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _TrendLinePainter(
                  points: points,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.snapshots});

  final List<_ProgressSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final Iterable<_ProgressSnapshot> history = snapshots.reversed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Historial', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final _ProgressSnapshot snapshot in history)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(snapshot.label)),
                    Text('${snapshot.weightKg.toStringAsFixed(1)} kg · Cintura ${snapshot.waistCm.toStringAsFixed(0)} cm'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  _TrendLinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint gridPaint = Paint()
      ..color = color.withAlpha(38)
      ..strokeWidth = 1;

    final double minY = points.reduce(math.min);
    final double maxY = points.reduce(math.max);
    final double range = (maxY - minY).abs() < 0.01 ? 1 : maxY - minY;

    for (int i = 1; i <= 3; i++) {
      final double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Path path = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = i * (size.width / (points.length - 1));
      final double normalized = (points[i] - minY) / range;
      final double y = size.height - (normalized * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _ProgressSnapshot {
  const _ProgressSnapshot({
    required this.label,
    required this.weightKg,
    required this.waistCm,
    required this.hipCm,
    required this.chestCm,
  });

  final String label;
  final double weightKg;
  final double waistCm;
  final double hipCm;
  final double chestCm;
}

class _AdherenceSummary {
  const _AdherenceSummary({
    required this.streakDays,
    required this.adherenceRate,
    required this.completedDays,
    required this.evaluatedDays,
  });

  final int streakDays;
  final double adherenceRate;
  final int completedDays;
  final int evaluatedDays;
}
