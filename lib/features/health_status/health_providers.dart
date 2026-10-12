import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/data/repositories.dart';
import '../../core/models/health.dart';
import '../../shared/widgets/common.dart';
import '../auth/auth_controller.dart';

/// Latest reading of each type, keyed by type.
final latestVitalsProvider = FutureProvider<Map<VitalType, VitalReading>>((ref) async {
  ref.watch(sessionUserIdProvider);
  final list = await ref.watch(vitalsRepositoryProvider).latest();
  return {for (final v in list) v.type: v};
});

/// Last 30 days of one type, newest first.
final vitalHistoryProvider =
    FutureProvider.family<List<VitalReading>, VitalType>((ref, type) {
  ref.watch(sessionUserIdProvider);
  return ref.watch(vitalsRepositoryProvider).history(type);
});

void refreshVitals(WidgetRef ref) {
  ref.invalidate(latestVitalsProvider);
  ref.invalidate(vitalHistoryProvider);
}

/// Opens the "add reading" dialog and saves it. Returns true when saved.
Future<bool> addVitalReading(
  BuildContext context,
  WidgetRef ref, {
  VitalType initial = VitalType.heartRate,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _AddVitalDialog(initial: initial),
  );
  if (saved == true) refreshVitals(ref);
  return saved == true;
}

class _AddVitalDialog extends ConsumerStatefulWidget {
  const _AddVitalDialog({required this.initial});

  final VitalType initial;

  @override
  ConsumerState<_AddVitalDialog> createState() => _AddVitalDialogState();
}

class _AddVitalDialogState extends ConsumerState<_AddVitalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _value2 = TextEditingController();
  late VitalType _type = widget.initial;
  DateTime _at = DateTime.now();
  bool _saving = false;

  static const _hints = {
    VitalType.heartRate: 'e.g. 72',
    VitalType.bloodPressure: 'Upper, e.g. 120',
    VitalType.bloodSugar: 'e.g. 5.4',
    VitalType.weight: 'e.g. 68.5',
    VitalType.temperature: 'e.g. 36.8',
  };

  @override
  void dispose() {
    _value.dispose();
    _value2.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _at,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_at),
    );
    if (time == null) return;
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _at = picked.isAfter(DateTime.now()) ? DateTime.now() : picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(vitalsRepositoryProvider).add(
            _type,
            double.parse(_value.text.replaceAll(',', '.')),
            value2: _type.hasTwoValues
                ? double.parse(_value2.text.replaceAll(',', '.'))
                : null,
            at: _at,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _number(String? v) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    return n == null ? 'Enter a number' : null;
  }

  @override
  Widget build(BuildContext context) {
    final numberInput = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}([.,]\d?)?')),
    ];
    return AlertDialog(
      title: const Text('Add reading'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<VitalType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in VitalType.values)
                    DropdownMenuItem(value: t, child: Text(t.label)),
                ],
                onChanged: (t) => setState(() => _type = t ?? _type),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _value,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberInput,
                      decoration: InputDecoration(
                        labelText: _type.hasTwoValues ? 'Systolic' : 'Value',
                        hintText: _hints[_type],
                        suffixText: _type.unit,
                      ),
                      validator: _number,
                    ),
                  ),
                  if (_type.hasTwoValues) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _value2,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: numberInput,
                        decoration: const InputDecoration(
                          labelText: 'Diastolic',
                          hintText: 'Lower, e.g. 80',
                        ),
                        validator: _number,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: Text(DateFormat('d MMM yyyy, h:mm a').format(_at)),
                subtitle: const Text('When it was measured'),
                trailing: TextButton(onPressed: _pickTime, child: const Text('Change')),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
      ],
    );
  }
}
