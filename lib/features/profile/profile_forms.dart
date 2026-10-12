import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/format.dart';
import '../../core/models/medical_record.dart';
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
        showInfo(context, 'Saved');
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
    return PageScaffold(
      title: 'Personal information',
      showBack: true,
      bottom: FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
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
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+255 7XX XXX XXX',
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return null;
                    return RegExp(r'^\+?[0-9 ]{9,16}$').hasMatch(t) ? null : 'Enter a valid phone number';
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: _user.email,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: 'Contact support to change your email.',
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
        showInfo(context, 'Saved');
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
    return PageScaffold(
      title: 'Health information',
      showBack: true,
      bottom: FilledButton(onPressed: _saving ? null : _save, child: const Text('Save')),
      children: [
        _Narrow(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Shared with your doctor during consultations.',
                  style: text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SectionHeader('Blood group'),
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
              const SectionHeader('Allergies'),
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
                    Text('None recorded', style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
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
                      decoration: const InputDecoration(hintText: 'e.g. Penicillin, peanuts'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Add allergy',
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
        showInfo(context, 'Profile updated');
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

    return PageScaffold(
      title: 'Professional profile',
      showBack: true,
      bottom: FilledButton(
        onPressed: _saving || !_loaded ? null : _save,
        child: const Text('Save'),
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
                    decoration: const InputDecoration(
                      labelText: 'About you',
                      hintText: 'What you treat, languages you speak…',
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
                      labelText: 'Consultation fee',
                      prefixText: '${currencySymbol(_currency)} ',
                      helperText: 'What patients pay per consultation. '
                          'The platform commission is deducted from it.',
                    ),
                    validator: (v) {
                      final minor = parseMoney(v ?? '', _currency);
                      if (minor == null || minor <= 0) return 'Enter your fee';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _years,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Years of experience'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n > 70 ? 'Enter a number from 0 to 70' : null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String?>(
                    initialValue: _hospitalId,
                    decoration: const InputDecoration(labelText: 'Hospital / clinic'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Independent')),
                      for (final (id, label) in hospitals)
                        DropdownMenuItem(value: id, child: Text(label)),
                    ],
                    onChanged: (v) => setState(() => _hospitalId = v),
                  ),
                  const SectionHeader('Consultation length'),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 15, label: Text('15 min')),
                      ButtonSegment(value: 20, label: Text('20')),
                      ButtonSegment(value: 30, label: Text('30')),
                      ButtonSegment(value: 45, label: Text('45')),
                      ButtonSegment(value: 60, label: Text('60')),
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
    return const PageScaffold(
      title: 'Verification documents',
      showBack: true,
      children: [_Narrow(child: DoctorDocuments())],
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
  static const _types = {
    'LICENSE': 'Medical license',
    'NATIONAL_ID': 'National ID',
    'CERTIFICATE': 'Certificate',
    'OTHER': 'Other',
  };
  bool _uploading = false;

  Future<void> _upload() async {
    final type = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('What are you uploading?'),
        children: [
          for (final e in _types.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, e.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(e.value),
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
      if (mounted) showInfo(context, '${_types[type]} uploaded');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
                child: Text(
                  'Upload your medical license and national ID. Our team checks '
                  'them before you can accept patients.',
                  style: text.bodyMedium,
                ),
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
                        title: Text(_types[d['type']] ?? '${d['type']}'),
                        subtitle: Text([
                          if (file != null) file.filename,
                          'Uploaded ${DateFormat('d MMM yyyy').format(DateTime.parse(d['uploadedAt'] as String).toLocal())}',
                        ].join(' · ')),
                        trailing: file == null
                            ? null
                            : IconButton(
                                tooltip: 'Open',
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
          label: const Text('Upload document'),
        ),
        const SizedBox(height: 6),
        Text('PDF, JPG, PNG or WebP, up to 10 MB.',
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
    showInfo(context, 'Password changed. Other devices have been signed out.');
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
    return AlertDialog(
      title: const Text('Change password'),
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
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _next,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) => (v?.length ?? 0) < 8 ? 'At least 8 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                  validator: (v) => v != _next.text ? 'Passwords do not match' : null,
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
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: const Text('Change')),
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
