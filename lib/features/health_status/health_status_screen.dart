import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/health.dart';
import '../../shared/widgets/common.dart';
import 'health_providers.dart';

/// Readings the patient logs themselves (from a BP cuff, glucometer,
/// scale…). Doctors see the latest values during a consultation.
class HealthStatusScreen extends ConsumerStatefulWidget {
  const HealthStatusScreen({super.key});

  @override
  ConsumerState<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends ConsumerState<HealthStatusScreen> {
  VitalType _type = VitalType.heartRate;

  Future<void> _delete(VitalReading r) async {
    try {
      await ref.read(vitalsRepositoryProvider).delete(r.id);
      refreshVitals(ref);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final history = ref.watch(vitalHistoryProvider(_type));
    final l = context.l10n;

    return PageScaffold(
      title: l.healthStatus,
      showBack: true,
      bottom: FilledButton.icon(
        onPressed: () => addVitalReading(context, ref, initial: _type),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addReading),
      ),
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final t in VitalType.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.label(l)),
                    selected: _type == t,
                    labelStyle: TextStyle(
                      color: _type == t ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _type = t),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: history,
          onRetry: () => ref.invalidate(vitalHistoryProvider(_type)),
          builder: (readings) {
            if (readings.isEmpty) {
              return AppCard(
                child: Column(
                  children: [
                    IconBadge(
                      icon: _type.icon,
                      color: _type.color,
                      background: _type.color.withValues(alpha: 0.12),
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(l.noReadingsYetFor(_type.label(l).toLowerCase()),
                        style: text.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      l.logReadingsHint,
                      textAlign: TextAlign.center,
                      style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            final latest = readings.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconBadge(
                        icon: _type.icon,
                        color: _type.color,
                        background: _type.color.withValues(alpha: 0.12),
                        size: 64,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.latestOf(_type.label(l).toLowerCase()),
                                style: text.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary)),
                            Text.rich(TextSpan(
                              text: '${latest.display} ',
                              style: text.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              children: [TextSpan(text: _type.unit, style: text.bodyMedium)],
                            )),
                            Text(
                              DateFormat('d MMM, h:mm a').format(latest.recordedAt),
                              style: text.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (readings.length > 1) ...[
                  SectionHeader(l.last30Days),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
                    child: SizedBox(height: 200, child: _TrendChart(readings: readings)),
                  ),
                ],
                SectionHeader(l.readings),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final r in readings)
                        ListTile(
                          title: Text('${r.display} ${_type.unit}'),
                          subtitle: Text(DateFormat('EEE d MMM, h:mm a').format(r.recordedAt)),
                          trailing: IconButton(
                            tooltip: l.deleteReading,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () => _delete(r),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.notADiagnosis,
                  style: text.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.readings});

  final List<VitalReading> readings;

  @override
  Widget build(BuildContext context) {
    final type = readings.first.type;
    final ordered = readings.reversed.toList();
    final start = ordered.first.recordedAt;
    double x(VitalReading r) =>
        r.recordedAt.difference(start).inMinutes / (60 * 24);

    LineChartBarData line(List<FlSpot> spots, Color color) => LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          color: color,
          barWidth: 2.5,
          dotData: const FlDotData(show: true),
        );

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 7,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('d MMM').format(start.add(Duration(minutes: (v * 1440).round()))),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(0),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ),
        lineBarsData: [
          line([for (final r in ordered) FlSpot(x(r), r.value)], type.color),
          if (type.hasTwoValues)
            line([
              for (final r in ordered)
                if (r.value2 != null) FlSpot(x(r), r.value2!),
            ], AppColors.primaryDark.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
