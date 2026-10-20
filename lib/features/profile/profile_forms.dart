import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/locale_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/format.dart';
import '../../core/models/medical_record.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/file_actions.dart';
import '../../shared/widgets/common.dart';
import '../auth/auth_controller.dart';
import '../doctor/doctor_providers.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _user = ref.read(currentUserProvider);
  late final _name = TextEditingController(text: _user.name);
  late final _phone = TextEditingController(text: _user.phone ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final json = await ref.read(accountRepositoryProvider).updateMe(
            name: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.replaceAll(' ', ''),
          );
      ref.read(authControllerProvider.notifier).updateUser(json);
      if (mounted) {
        showInfo(context, context.l10n.saved);
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PageScaffold(
      title: l.personalInformation,
      showBack: true,
      bottom: FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
      children: [
        _Narrow(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.fullName),
                  validator: (v) => (v?.trim().length ?? 0) < 2 ? l.enterName : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l.phone,
                    hintText: '+255 7XX XXX XXX',
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null;
                    return RegExp(r'^\+?[0-9 ]{9,16}$').hasMatch(t) ? null : l.enterValidPhone;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _user.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: l.email,
                    helperText: l.changeEmailHelp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HealthInfoScreen extends ConsumerStatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  ConsumerState<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends ConsumerState<HealthInfoScreen> {
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  late final _user = ref.read(currentUserProvider);
  late String? _bloodGroup = _user.bloodGroup;
  late final List<String> _allergies = [..._user.allergies];
  final _allergy = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _allergy.dispose();
    super.dispose();
  }

  void _addAllergy() {
    final a = _allergy.text.trim();
    if (a.isEmpty || _allergies.contains(a)) return;
    setState(() {
      _allergies.add(a);
      _allergy.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final json = await ref.read(accountRepositoryProvider).updatePatientProfile(
            bloodGroup: _bloodGroup,
            allergies: _allergies,
          );
      ref.read(authControllerProvider.notifier).updateUser(json);
      if (mounted) {
        showInfo(context, context.l10n.saved);
        Navigator.of(context).maybePop();
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
    final l = context.l10n;
    return PageScaffold(
      title: l.healthInformation,
      showBack: true,
      bottom: FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
      children: [
        _Narrow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.sharedWithDoctor,
                  style: text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              SectionHeader(l.bloodGroup),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in _bloodGroups)
                    ChoiceChip(
                      label: Text(g),
                      selected: _bloodGroup == g,
                      labelStyle: TextStyle(
                        color: _bloodGroup == g ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (on) => setState(() => _bloodGroup = on ? g : null),
                    ),
                ],
              ),
              SectionHeader(l.allergies),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in _allergies)
                    InputChip(
                      label: Text(a),
                      onDeleted: () => setState(() => _allergies.remove(a)),
                    ),
                  if (_allergies.isEmpty)
                    Text(l.noneRecorded, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergy,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _addAllergy(),
                      decoration: InputDecoration(hintText: l.allergyHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l.addAllergy,
                    onPressed: _addAllergy,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final _hospitalsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(catalogRepositoryProvider).hospitals(),
);

class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends ConsumerState<ProfessionalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bio = TextEditingController();
  final _fee = TextEditingController();
  final _years = TextEditingController();
  String? _hospitalId;
  int _slotMinutes = 30;
  String _currency = 'TZS';
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _bio.dispose();
    _fee.dispose();
    _years.dispose();
    super.dispose();
  }

  void _fill(Map<String, dynamic> p) {
    if (_loaded) return;
    _loaded = true;
    _currency = p['currency'] as String;
    _bio.text = p['bio'] as String? ?? '';
    _fee.text = moneyInput(p['feeCents'] as int, _currency);
    _years.text = '${p['yearsExperience']}';
    _hospitalId = (p['hospital'] as Map<String, dynamic>?)?['id'] as String?;
    _slotMinutes = p['slotMinutes'] as int;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(doctorSelfRepositoryProvider).updateProfile({
        'bio': _bio.text.trim(),
        'feeCents': parseMoney(_fee.text, _currency),
        'yearsExperience': int.parse(_years.text),
        'slotMinutes': _slotMinutes,
        'hospitalId': ?_hospitalId,
      });
      ref.invalidate(doctorProfileProvider);
      if (mounted) {
        showInfo(context, context.l10n.profileUpdated);
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(doctorProfileProvider);
    final hospitals = ref.watch(_hospitalsProvider).value ?? const [];
    if (profile.hasValue) _fill(profile.value!);
    final l = context.l10n;

    return PageScaffold(
      title: l.professionalProfile,
      showBack: true,
      bottom: FilledButton(
        onPressed: _saving || !_loaded ? null : _save,
        child: Text(l.save),
      ),
      children: [
        if (!_loaded)
          AsyncView(
            value: profile,
            onRetry: () => ref.invalidate(doctorProfileProvider),
            builder: (_) => const SizedBox.shrink(),
          )
        else
          _Narrow(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _bio,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: l.aboutYou,
                      hintText: l.aboutYouHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fee,
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: displayDecimals(_currency) > 0),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(moneyInputPattern(_currency)),
                    ],
                    decoration: InputDecoration(
                      labelText: l.consultationFee,
                      prefixText: '${currencySymbol(_currency)} ',
                      helperText: l.feeHelper,
                      helperMaxLines: 2,
                    ),
                    validator: (v) {
                      final minor = parseMoney(v ?? '', _currency);
                      if (minor == null || minor <= 0) return l.enterYourFee;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _years,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l.yearsOfExperience),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n > 70 ? l.enter0to70 : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String?>(
                    initialValue: _hospitalId,
                    decoration: InputDecoration(labelText: l.hospitalClinic),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l.independent)),
                      for (final (id, label) in hospitals)
                        DropdownMenuItem(value: id, child: Text(label)),
                    ],
                    onChanged: (v) => setState(() => _hospitalId = v),
                  ),
                  SectionHeader(l.consultationLength),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 15, label: Text(l.minutesShort(15))),
                      const ButtonSegment(value: 20, label: Text('20')),
                      const ButtonSegment(value: 30, label: Text('30')),
                      const ButtonSegment(value: 45, label: Text('45')),
                      const ButtonSegment(value: 60, label: Text('60')),
                    ],
                    selected: {_slotMinutes},
                    onSelectionChanged: (s) => setState(() => _slotMinutes = s.first),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class DoctorDocumentsScreen extends StatelessWidget {
  const DoctorDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: context.l10n.verificationDocuments,
      showBack: true,
      children: const [_Narrow(child: DoctorDocuments())],
    );
  }
}

/// List + upload of license / ID documents. Used on the pending-verification
/// screen and from the doctor's profile.
class DoctorDocuments extends ConsumerStatefulWidget {
  const DoctorDocuments({super.key});

  @override
  ConsumerState<DoctorDocuments> createState() => _DoctorDocumentsState();
}

class _DoctorDocumentsState extends ConsumerState<DoctorDocuments> {
  static const _types = ['LICENSE', 'NATIONAL_ID', 'CERTIFICATE', 'OTHER'];
  bool _uploading = false;

  String _typeLabel(AppLocalizations l, Object? type) => switch (type) {
        'LICENSE' => l.docLicense,
        'NATIONAL_ID' => l.docNationalId,
        'CERTIFICATE' => l.docCertificate,
        'OTHER' => l.recordOther,
        _ => '$type',
      };

  Future<void> _upload() async {
    final l = context.l10n;
    final type = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.whatUploading),
        children: [
          for (final t in _types)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, t),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(_typeLabel(l, t)),
              ),
            ),
        ],
      ),
    );
    if (type == null || !mounted) return;
    setState(() => _uploading = true);
    try {
      final file = await pickAndUpload(context, ref, FilePurpose.verificationDocument);
      if (file == null) return;
      await ref.read(doctorSelfRepositoryProvider).addDocument(type, file.id);
      ref.invalidate(doctorProfileProvider);
      if (mounted) showInfo(context, l.docUploaded(_typeLabel(l, type)));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    final profile = ref.watch(doctorProfileProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AsyncView(
          value: profile,
          onRetry: () => ref.invalidate(doctorProfileProvider),
          builder: (p) {
            final docs = (p['documents'] as List).cast<Map<String, dynamic>>();
            if (docs.isEmpty) {
              return AppCard(
                color: AppColors.amberSoft,
                child: Text(l.uploadDocsIntro, style: text.bodyMedium),
              );
            }
            return AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final d in docs)
                    Builder(builder: (context) {
                      final f = d['file'] as Map<String, dynamic>?;
                      final file = f == null ? null : StoredFileInfo.fromJson(f);
                      return ListTile(
                        leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                        title: Text(_typeLabel(l, d['type'])),
                        subtitle: Text([
                          if (file != null) file.filename,
                          l.uploadedOn(DateFormat('d MMM yyyy').format(
                              DateTime.parse(d['uploadedAt'] as String).toLocal())),
                        ].join(' · ')),
                        trailing: file == null
                            ? null
                            : IconButton(
                                tooltip: l.open,
                                icon: const Icon(Icons.open_in_new_rounded),
                                onPressed: () => openStoredFile(context, ref, file),
                              ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _uploading ? null : _upload,
          icon: _uploading
              ? const SizedBox.square(
                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload_file_rounded),
          label: Text(l.uploadDocument),
        ),
        const SizedBox(height: 6),
        Text(l.fileTypesHint,
            style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

Future<void> changePassword(BuildContext context, WidgetRef ref) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
  if (done == true && context.mounted) {
    showInfo(context, context.l10n.passwordChanged);
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(_current.text, _next.text);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.changePassword),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _current,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(labelText: l.currentPassword),
                  validator: (v) => (v?.isEmpty ?? true) ? l.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _next,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(labelText: l.newPassword),
                  validator: (v) => (v?.length ?? 0) < 8 ? l.atLeast8Chars : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(labelText: l.confirmNewPassword),
                  validator: (v) => v != _next.text ? l.passwordsDontMatch : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(onPressed: _saving ? null : _save, child: Text(l.change)),
      ],
    );
  }
}

class _Narrow extends StatelessWidget {
  const _Narrow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child,
        ),
      );
}
