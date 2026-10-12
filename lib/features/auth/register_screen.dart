import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/app_user.dart';
import 'auth_controller.dart';
import 'auth_form_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

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
  UserRole _role = UserRole.patient;
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
    final isDoctor = _role == UserRole.doctor;
    final specialties = ref.watch(specialtiesProvider);

    return AuthFormLayout(
      title: 'Create account',
      subtitle: isDoctor
          ? 'Doctor accounts are reviewed by our team before going live.'
          : 'Get care from verified specialists.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(
                  value: UserRole.patient,
                  icon: Icon(Icons.person_outline),
                  label: Text("I'm a patient"),
                ),
                ButtonSegment(
                  value: UserRole.doctor,
                  icon: Icon(Icons.medical_services_outlined),
                  label: Text("I'm a doctor"),
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
              decoration: const InputDecoration(
                hintText: 'Full name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  v != null && v.trim().length >= 2 ? null : 'Enter your name',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Enter a valid email',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                hintText: 'Phone (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              validator: (v) =>
                  v != null && v.length >= 8 ? null : 'At least 8 characters',
            ),
            if (isDoctor) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _specialtyId,
                decoration: InputDecoration(
                  hintText: specialties.isLoading
                      ? 'Loading specialties…'
                      : 'Specialty',
                  prefixIcon: const Icon(Icons.local_hospital_outlined),
                  errorText: specialties.hasError
                      ? 'Could not load specialties'
                      : null,
                ),
                items: [
                  for (final s in specialties.value ?? const [])
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _specialtyId = v),
                validator: (v) => v == null ? 'Choose a specialty' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _license,
                decoration: const InputDecoration(
                  hintText: 'Medical license number',
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
                validator: (v) => v != null && v.trim().length >= 3
                    ? null
                    : 'License number is required',
              ),
              const SizedBox(height: 8),
              Text(
                "You'll upload your license and ID after signing up.",
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
                  : Text(isDoctor ? 'Submit for verification' : 'Create account'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
