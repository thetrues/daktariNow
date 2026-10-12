import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/core/money.dart';

void main() {
  group('TZS', () {
    test('shows whole shillings with the TSh symbol', () {
      expect(money(2500000, 'TZS'), 'TSh 25,000');
      expect(money(4500000, 'TZS'), 'TSh 45,000');
      expect(money(0, 'TZS'), 'TSh 0');
    });

    test('round-trips input in shillings to minor units', () {
      expect(moneyInput(2500000, 'TZS'), '25000');
      expect(parseMoney('25000', 'TZS'), 2500000);
      expect(parseMoney('1,250,000', 'TZS'), 125000000);
      expect(parseMoney('abc', 'TZS'), isNull);
    });

    test('inputs do not accept decimals', () {
      final pattern = moneyInputPattern('TZS');
      expect(pattern.stringMatch('25000.50'), '25000');
    });
  });

  test('other currencies keep their usual decimals', () {
    expect(money(2500, 'USD'), r'$25.00');
    expect(moneyInput(2500, 'USD'), '25.00');
    expect(parseMoney('25.5', 'USD'), 2550);
  });

  test('zero-decimal currencies use one minor unit per major unit', () {
    expect(minorPerMajor('UGX'), 1);
    expect(parseMoney('50000', 'UGX'), 50000);
  });
}
