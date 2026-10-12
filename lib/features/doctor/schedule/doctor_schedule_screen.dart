import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/repositories.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/widgets/common.dart';
import '../doctor_providers.dart';

/// Converts hourly toggles to API windows: consecutive hours on the same
/// day become one window (09,10,11 → 09:00–12:00).
@visibleForTesting
List<AvailabilityWindow> hoursToWindows(Map<int, Set<int>> hours) {
  final windows = <AvailabilityWindow>[];
  for (final day in hours.keys.toList()..sort()) {
    final sorted = hours[day]!.toList()..sort();
    int? start;
    int? prev;
    for (final h in sorted) {
      if (start == null) {
        start = prev = h;
      } else if (h == prev! + 1) {
        prev = h;
      } else {
        windows.add(AvailabilityWindow(day, start * 60, (prev + 1) * 60));
        start = prev = h;
      }
    }
    if (start != null) {
      windows.add(AvailabilityWindow(day, start * 60, (prev! + 1) * 60));
    }
  }
  return windows;
}

/// Inverse of [hoursToWindows]: any hour a window touches is marked on.
@visibleForTesting
Map<int, Set<int>> windowsToHours(List<AvailabilityWindow> windows) {
  final hours = <int, Set<int>>{};
  for (final w in windows) {
    for (var h = w.startMinute ~/ 60; h * 60 < w.endMinute; h++) {
      hours.putIfAbsent(w.weekday, () => {}).add(h);
    }
  }
  return hours;
}

/// Weekly availability editor. Patients can only book slots enabled here.
class DoctorScheduleScreen extends ConsumerStatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  ConsumerState<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends ConsumerState<DoctorScheduleScreen> {
  static const _hours = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// ISO weekday (1–7) → enabled hours. Null until loaded.
  Map<int, Set<int>>? _available;
  bool _dirty = false;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(doctorSelfRepositoryProvider)
          .setAvailability(hoursToWindows(_available!));
      ref.invalidate(availabilityProvider);
      if (mounted) {
        setState(() => _dirty = false);
        showInfo(context, 'Availability saved');
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remote = ref.watch(availabilityProvider);
    final timezone = ref.watch(doctorProfileProvider).value?['timezone'];
    if (_available == null && remote.hasValue) {
      _available = windowsToHours(remote.value!);
    }

    return PageScaffold(
      title: 'My Schedule',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: _dirty && !_saving ? _save : null,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(_dirty ? 'Save' : 'Saved'),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          ),
        ),
      ],
      children: [
        Text(
          'Tap an hour to toggle it. Patients only see enabled times'
          '${timezone == null ? '' : ' (your timezone: $timezone)'}.',
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (_available == null)
          AsyncView(
            value: remote,
            onRetry: () => ref.invalidate(availabilityProvider),
            builder: (_) => const SizedBox.shrink(),
          )
        else
          AppCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 4,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 44,
                columns: [
                  const DataColumn(label: Text('Time')),
                  for (final d in _weekdays) DataColumn(label: Text(d)),
                ],
                rows: [
                  for (final h in _hours)
                    DataRow(cells: [
                      DataCell(Text(
                          DateFormat('h a').format(DateTime(2000, 1, 1, h)))),
                      for (var d = 1; d <= 7; d++) DataCell(_slot(d, h)),
                    ]),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _slot(int day, int hour) {
    final on = _available![day]?.contains(hour) ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() {
        final set = _available!.putIfAbsent(day, () => {});
        on ? set.remove(hour) : set.add(hour);
        _dirty = true;
      }),
      child: Container(
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: on ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? AppColors.primary : AppColors.border),
        ),
        child: on
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
