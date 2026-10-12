import 'package:intl/intl.dart';

// Amounts from the API are ISO 4217 minor units of the platform currency
// (TZS: 1 TSh = 100). Keep this in sync with backend/src/config/env.ts.

const _zeroDecimal = {'UGX', 'RWF', 'BIF', 'JPY', 'KRW', 'XAF', 'XOF'};

/// Currencies shown in whole units because cents aren't used day to day.
const _wholeUnitDisplay = {'TZS', ..._zeroDecimal};

/// Minor units per major unit (TZS: 100).
int minorPerMajor(String currency) => _zeroDecimal.contains(currency) ? 1 : 100;

/// Decimal places shown and accepted in inputs (TZS: 0).
int displayDecimals(String currency) =>
    _wholeUnitDisplay.contains(currency) ? 0 : 2;

String currencySymbol(String currency) =>
    NumberFormat.simpleCurrency(name: currency).currencySymbol;

/// `TSh 25,000` / `$25.00`.
String money(int minor, String currency) {
  final symbol = currencySymbol(currency);
  return NumberFormat.currency(
    name: currency,
    symbol: symbol.length > 1 ? '$symbol ' : symbol,
    decimalDigits: displayDecimals(currency),
  ).format(minor / minorPerMajor(currency));
}

/// Plain number for an input field, e.g. `25000` for TSh 25,000.
String moneyInput(int minor, String currency) =>
    (minor / minorPerMajor(currency)).toStringAsFixed(displayDecimals(currency));

/// Parses what the user typed (commas allowed) into minor units, or null.
int? parseMoney(String text, String currency) {
  final value = double.tryParse(text.replaceAll(',', '').trim());
  if (value == null || value < 0) return null;
  return (value * minorPerMajor(currency)).round();
}

/// Input filter: digits and commas, plus decimals only where they're used.
RegExp moneyInputPattern(String currency) => displayDecimals(currency) == 0
    ? RegExp(r'^[\d,]*')
    : RegExp(r'^[\d,]*\.?\d{0,2}');
