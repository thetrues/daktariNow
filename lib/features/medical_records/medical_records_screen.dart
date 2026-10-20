import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/medical_record.dart';
import '../../shared/file_actions.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/common.dart';
import '../auth/auth_controller.dart';

/// The signed-in patient's own records.
final myRecordsProvider = FutureProvider.autoDispose<List<MedicalRecord>>(
  (ref) => ref.watch(recordRepositoryProvider).mine(),
);

/// A patient's records as seen by their doctor during a consultation.
final patientRecordsProvider =
    FutureProvider.autoDispose.family<List<MedicalRecord>, String>(
  (ref, patientId) => ref.watch(recordRepositoryProvider).forPatient(patientId),
);

extension RecordCategoryStyle on RecordCategory {
  (IconData, Color, Color) get style => switch (this) {
        RecordCategory.prescription => (
            Icons.receipt_long_rounded,
            AppColors.primary,
            AppColors.primarySoft
          ),
        RecordCategory.labReport => (
            Icons.science_rounded,
            AppColors.purple,
            AppColors.purpleSoft
          ),
        RecordCategory.xRay => (
            Icons.monitor_heart_rounded,
            const Color(0xFF3B82F6),
            const Color(0xFFE6F0FF)
          ),
        RecordCategory.vaccination => (
            Icons.vaccines_rounded,
            AppColors.amber,
            AppColors.amberSoft
          ),
        RecordCategory.summary => (
            Icons.favorite_rounded,
            AppColors.accent,
            AppColors.accentSoft
          ),
        RecordCategory.other => (
            Icons.description_rounded,
            AppColors.textSecondary,
            AppColors.background
          ),
      };
}

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final records = ref.watch(myRecordsProvider);
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return PageScaffold(
      title: l.medicalRecords,
      bottom: FilledButton.icon(
        onPressed: () => _addRecord(context, ref),
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(l.addNewRecord),
      ),
      children: [
        AppCard(
          child: Row(
            children: [
              Avatar(initials: user.initials, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                        [
                          if (user.bloodGroup != null)
                            l.bloodGroupValue(user.bloodGroup!),
                          if (user.allergies.isNotEmpty)
                            l.allergiesValue(user.allergies.join(', ')),
                        ].join(' · ').ifEmpty(user.email),
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: l.editHealthInfo,
                onPressed: () => context.push(Routes.healthInfo),
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: records,
          onRetry: () => ref.invalidate(myRecordsProvider),
          builder: (items) => items.isEmpty
              ? AppCard(child: Text(l.noRecordsYet))
              : RecordList(
                  records: items,
                  deletableBy: user.id,
                  onDeleted: () => ref.invalidate(myRecordsProvider),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Also reused inside the doctor's consultation room.
class RecordList extends ConsumerWidget {
  const RecordList({
    super.key,
    required this.records,
    this.dense = false,
    this.deletableBy,
    this.onDeleted,
  });

  final List<MedicalRecord> records;
  final bool dense;

  /// Records created by this user id can be deleted from the detail sheet.
  final String? deletableBy;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final r in records)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: EdgeInsets.all(dense ? 12 : 16),
              onTap: () => _showRecord(context, ref, r,
                  canDelete: deletableBy != null && r.createdById == deletableBy,
                  onDeleted: onDeleted),
              child: Row(
                children: [
                  IconBadge(
                    icon: r.category.style.$1,
                    color: r.category.style.$2,
                    background: r.category.style.$3,
                    size: dense ? 38 : 46,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.title,
                            style: text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          dense && r.notes != null
                              ? r.notes!
                              : context.l10n.updatedOn(
                                  DateFormat('d MMM yyyy').format(r.updatedAt)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (r.file != null)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.attach_file_rounded,
                          size: 18, color: AppColors.textMuted),
                    ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

void _showRecord(
  BuildContext context,
  WidgetRef ref,
  MedicalRecord r, {
  bool canDelete = false,
  VoidCallback? onDeleted,
}) {
  Future<void> delete(BuildContext ctx) async {
    try {
      await ref.read(recordRepositoryProvider).delete(r.id);
      if (ctx.mounted) Navigator.pop(ctx);
      onDeleted?.call();
    } catch (e) {
      if (ctx.mounted) showError(ctx, e);
    }
  }

  final l = context.l10n;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.title,
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(
              [
                r.category.label(l),
                if (r.createdByName != null) l.addedBy(r.createdByName!),
                DateFormat('d MMM yyyy').format(r.updatedAt),
              ].join(' · '),
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SelectableText(r.notes?.isNotEmpty ?? false ? r.notes! : l.noNotes),
            if (r.file != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => openStoredFile(ctx, ref, r.file!),
                icon: Icon(r.file!.isImage
                    ? Icons.image_outlined
                    : Icons.picture_as_pdf_outlined),
                label: Text(l.openFile(
                    r.file!.filename, fileSizeLabel(r.file!.sizeBytes))),
              ),
            ],
            if (canDelete) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () => delete(ctx),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l.deleteRecord),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Future<void> _addRecord(BuildContext context, WidgetRef ref) async {
  final added = await showDialog<bool>(
    context: context,
    builder: (_) => const _AddRecordDialog(),
  );
  if (added == true) ref.invalidate(myRecordsProvider);
}

class _AddRecordDialog extends ConsumerStatefulWidget {
  const _AddRecordDialog();

  @override
  ConsumerState<_AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends ConsumerState<_AddRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _notes = TextEditingController();
  RecordCategory _category = RecordCategory.labReport;
  StoredFileInfo? _file;
  bool _uploading = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _attach() async {
    setState(() => _uploading = true);
    final file = await pickAndUpload(context, ref, FilePurpose.medicalRecord);
    if (!mounted) return;
    setState(() {
      _uploading = false;
      if (file != null) {
        _file = file;
        if (_title.text.isEmpty) {
          _title.text = file.filename.replaceAll(RegExp(r'\.[^.]+$'), '');
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(recordRepositoryProvider).create(
            category: _category,
            title: _title.text.trim(),
            notes: _notes.text.trim(),
            fileId: _file?.id,
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.addRecord),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<RecordCategory>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l.type),
                items: [
                  for (final c in RecordCategory.values)
                    if (c != RecordCategory.prescription)
                      DropdownMenuItem(value: c, child: Text(c.label(l))),
                ],
                onChanged: (c) => setState(() => _category = c ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.title,
                  hintText: l.recordTitleHint,
                ),
                validator: (v) => (v?.trim().length ?? 0) < 2 ? l.addTitle : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: InputDecoration(labelText: l.notesOptional),
              ),
              const SizedBox(height: 12),
              if (_file == null)
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _attach,
                  icon: _uploading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.attach_file_rounded),
                  label: Text(l.attachPdfOrPhoto),
                )
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  title: Text(_file!.filename, overflow: TextOverflow.ellipsis),
                  subtitle: Text(fileSizeLabel(_file!.sizeBytes)),
                  trailing: IconButton(
                    tooltip: l.removeAttachment,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _file = null),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(
          onPressed: _saving || _uploading ? null : _save,
          child: Text(l.save),
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
