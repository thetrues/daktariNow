import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/app_user.dart';
import 'auth_controller.dart';
import 'auth_form_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.asDoctor = false});

  /// Start with "I'm a doctor" selected (from the landing page).
  final bool asDoctor;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _license = TextEditingController();
  late UserRole _role = widget.asDoctor ? UserRole.doctor : UserRole.patient;
  String? _specialtyId;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _license]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Doctors land on the verification screen via the router guard.
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            password: _password.text,
            role: _role,
            specialtyId: _specialtyId,
            licenseNumber: _license.text.trim(),
          );
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDoctor = _role == UserRole.doctor;
    final specialties = ref.watch(specialtiesProvider);

    return AuthFormLayout(
      title: l.createAccount,
      subtitle: isDoctor ? l.registerSubtitleDoctor : l.registerSubtitlePatient,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<UserRole>(
              segments: [
                ButtonSegment(
                  value: UserRole.patient,
                  icon: const Icon(Icons.person_outline),
                  label: Text(l.iAmAPatient),
                ),
                ButtonSegment(
                  value: UserRole.doctor,
                  icon: const Icon(Icons.medical_services_outlined),
                  label: Text(l.iAmADoctor),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(
                hintText: l.fullName,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  v != null && v.trim().length >= 2 ? null : l.enterName,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                hintText: l.email,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) =>
                  v != null && v.contains('@') ? null : l.enterValidEmail,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: InputDecoration(
                hintText: l.phoneOptional,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: l.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              validator: (v) =>
                  v != null && v.length >= 8 ? null : l.atLeast8Chars,
            ),
            if (isDoctor) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _specialtyId,
                decoration: InputDecoration(
                  hintText:
                      specialties.isLoading ? l.loadingSpecialties : l.specialty,
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  errorText:
                      specialties.hasError ? l.couldNotLoadSpecialties : null,
                ),
                items: [
                  for (final s in specialties.value ?? const [])
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _specialtyId = v),
                validator: (v) => v == null ? l.chooseSpecialty : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _license,
                decoration: InputDecoration(
                  hintText: l.licenseNumber,
                  prefixIcon: const Icon(Icons.verified_outlined),
                ),
                validator: (v) =>
                    v != null && v.trim().length >= 3 ? null : l.licenseRequired,
              ),
              const SizedBox(height: 8),
              Text(
                l.uploadDocsLater,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isDoctor ? l.submitForVerification : l.createAccount),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(Routes.login),
              child: Text(l.haveAccountSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
