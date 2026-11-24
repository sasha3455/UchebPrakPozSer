import 'package:calc_web/logic/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts rubles to dollars using configured rate', () {
    final result = convert('185', 'RUB', 'USD');
    expect(result.isSuccess, isTrue);
    expect(result.value, 2);
  });

  test('rejects unknown currency and invalid amount', () {
    expect(convert('10', 'RUB', 'XXX').isSuccess, isFalse);
    expect(convert('text', 'RUB', 'USD').isSuccess, isFalse);
  });
}
