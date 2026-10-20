import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Loaded in main() before the first frame so the saved language is used
/// immediately.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Overridden in main()'),
);

const _key = 'locale';

/// The app language: the user's saved choice, otherwise the device language
/// when it is Swahili, otherwise English.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    if (saved != null) return Locale(saved);
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'sw' ? 'sw' : 'en');
  }

  void set(Locale locale) {
    state = locale;
    ref.read(sharedPreferencesProvider).setString(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
