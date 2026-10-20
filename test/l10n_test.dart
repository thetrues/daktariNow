import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String s) =>
    RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  final en = _arb('en');
  final sw = _arb('sw');
  final keys = en.keys.where((k) => !k.startsWith('@')).toSet();

  test('Swahili has every English string', () {
    final swKeys = sw.keys.where((k) => !k.startsWith('@')).toSet();
    expect(keys.difference(swKeys), isEmpty, reason: 'missing in app_sw.arb');
    expect(swKeys.difference(keys), isEmpty, reason: 'unused in app_sw.arb');
  });

  test('translations keep the same placeholders', () {
    for (final k in keys) {
      expect(
        _placeholders(sw[k] as String),
        _placeholders(en[k] as String),
        reason: k,
      );
    }
  });
}
