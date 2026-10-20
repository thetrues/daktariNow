import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/consultation.dart';
import '../../core/models/medical_record.dart';
import '../../shared/widgets/common.dart';
import '../appointments/appointment_providers.dart';

/// Doctor's prescription and lab-request form inside the room. Once a
/// prescription has been sent it is shown read-only.
class PrescribePanel extends ConsumerStatefulWidget {
  const PrescribePanel({super.key, required this.detail});

  final ConsultationDetail detail;

  @override
  ConsumerState<PrescribePanel> createState() => _PrescribePanelState();
}

class _PrescribePanelState extends ConsumerState<PrescribePanel> {
  static const _labTests = [
    'Full blood count',
    'Lipid profile',
    'ECG',
    'Blood sugar (fasting)',
    'Urinalysis',
    'Chest X-ray',
  ];

  final _notes = TextEditingController();
  final _medicine = TextEditingController();
  final _dosage = TextEditingController();
  final _duration = TextEditingController();
  final _items = <PrescriptionItem>[];
  final _labs = <String>{};
  bool _sending = false;

  String get _id => widget.detail.consultation.id;

  @override
  void dispose() {
    for (final c in [_notes, _medicine, _dosage, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    if (_medicine.text.trim().isEmpty) return;
    setState(() {
      _items.add(PrescriptionItem(
        medicine: _medicine.text.trim(),
        dosage: _dosage.text.trim().isEmpty
            ? context.l10n.asDirected
            : _dosage.text.trim(),
        duration: _duration.text.trim().isEmpty ? '—' : _duration.text.trim(),
      ));
      _medicine.clear();
      _dosage.clear();
      _duration.clear();
    });
  }

  Future<void> _send() async {
    final alreadyPrescribed = widget.detail.hasPrescription;
    setState(() => _sending = true);
    final repo = ref.read(consultationRepositoryProvider);
    try {
      if (_items.isNotEmpty && !alreadyPrescribed) {
        await repo.prescribe(_id, _items, notes: _notes.text.trim());
      }
      if (_labs.isNotEmpty) await repo.requestLabs(_id, _labs.toList());
      if (!mounted) return;
      showInfo(context, context.l10n.sentToPatient);
      setState(() {
        _items.clear();
        _labs.clear();
      });
      ref.invalidate(consultationDetailProvider(_id));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    final title = text.titleSmall?.copyWith(fontWeight: FontWeight.w700);
    final d = widget.detail;
    final active = d.consultation.status == ConsultationStatus.inProgress;
    final requested = d.labRequests.map((l) => l.testName).toSet();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!active)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppCard(
              color: AppColors.amberSoft,
              child: Text(
                d.consultation.status == ConsultationStatus.booked
                    ? l.startToPrescribe
                    : l.consultationEnded,
              ),
            ),
          ),
        Text(l.prescription, style: title),
        const SizedBox(height: 8),
        if (d.hasPrescription) ...[
          PrescriptionSummary(detail: d),
          const SizedBox(height: 8),
        ] else ...[
          for (final (i, item) in _items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.medication_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.medicine,
                              style: text.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text('${item.dosage} · ${item.duration}',
                              style: text.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l.remove,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _items.removeAt(i)),
                    ),
                  ],
                ),
              ),
            ),
          TextField(
            controller: _medicine,
            enabled: active,
            decoration: InputDecoration(hintText: l.medicineStrength),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dosage,
                  enabled: active,
                  decoration: InputDecoration(hintText: l.dosageHint),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _duration,
                  enabled: active,
                  onSubmitted: (_) => _addItem(),
                  decoration: InputDecoration(hintText: l.durationHint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: active ? _addItem : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(l.addMedicine),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            enabled: active,
            maxLines: 2,
            decoration: InputDecoration(hintText: l.notesForPatient),
          ),
        ],
        const SizedBox(height: 20),
        Text(l.labTests, style: title),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _labTests)
              FilterChip(
                label: Text(t),
                selected: _labs.contains(t) || requested.contains(t),
                selectedColor: AppColors.primarySoft,
                checkmarkColor: AppColors.primary,
                showCheckmark: true,
                onSelected: !active || requested.contains(t)
                    ? null
                    : (on) => setState(() => on ? _labs.add(t) : _labs.remove(t)),
              ),
          ],
        ),
        if (requested.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l.alreadyRequested(requested.join(', ')),
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: !active ||
                  _sending ||
                  ((_items.isEmpty || d.hasPrescription) && _labs.isEmpty)
              ? null
              : _send,
          icon: const Icon(Icons.send_rounded),
          label: Text(l.sendToPatient),
        ),
      ],
    );
  }
}

/// Read-only prescription and lab list; shown to both parties.
class PrescriptionSummary extends StatelessWidget {
  const PrescriptionSummary({super.key, required this.detail});

  final ConsultationDetail detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in detail.prescriptionItems)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medication_rounded, color: AppColors.primary),
              title: Text(item.medicine,
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text('${item.dosage} · ${item.duration}', style: muted),
            ),
          if (detail.prescriptionNotes?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(detail.prescriptionNotes!, style: muted),
            ),
          if (detail.labRequests.isNotEmpty) ...[
            if (detail.prescriptionItems.isNotEmpty) const Divider(height: 20),
            Text(context.l10n.labTestsRequested,
                style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final l in detail.labRequests)
                  Chip(
                    avatar: const Icon(Icons.biotech_outlined, size: 16),
                    label: Text(l.testName),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
