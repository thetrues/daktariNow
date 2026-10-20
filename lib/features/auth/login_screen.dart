import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import 'auth_controller.dart';
import 'auth_form_layout.dart';

/// Accounts created by the backend's `npm run db:seed` (debug builds only).
const _seedPassword = 'Password123!';
const _seedAccounts = [
  (false, Icons.person_outline, 'alex.johnson@medic.local'),
  (true, Icons.medical_services_outlined, 'sarah.johnson@medic.local'),
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // On success the router redirect sends the user to the right shell.
      await ref
          .read(authControllerProvider.notifier)
          .signIn(_email.text.trim(), _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _useSeed(String email) {
    _email.text = email;
    _password.text = _seedPassword;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthFormLayout(
      title: l.welcomeBack,
      subtitle: l.signInSubtitle,
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                controller: _password,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: l.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? l.showPassword : l.hidePassword,
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? l.enterPassword : null,
              ),
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
                    : Text(l.signIn),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(Routes.register),
                child: Text(l.noAccountCreate),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  l.seededAccounts,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (isDoctor, icon, email) in _seedAccounts)
                      ActionChip(
                        avatar: Icon(icon, size: 18),
                        label: Text(isDoctor ? l.doctor : l.patient),
                        onPressed: _loading ? null : () => _useSeed(email),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
