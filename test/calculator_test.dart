import 'package:calc_web/logic/calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculate', () {
    test('adds numbers', () {
      expect(calculate('2', '+', '3'), isA<CalcSuccess>());
      expect((calculate('2', '+', '3') as CalcSuccess).value, 5);
    });

    test('subtracts numbers', () {
      expect((calculate('8', '-', '3') as CalcSuccess).value, 5);
    });

    test('multiplies numbers', () {
      expect((calculate('2.5', '*', '4') as CalcSuccess).value, 10);
    });

    test('divides numbers', () {
      expect((calculate('7', '/', '2') as CalcSuccess).value, 3.5);
    });

    test('rejects division by zero', () {
      expect(calculate('7', '/', '0'), isA<CalcFailure>());
    });

    test('rejects invalid number and unknown operation', () {
      expect(calculate('a', '+', '2'), isA<CalcFailure>());
      expect(calculate('1', '%', '2'), isA<CalcFailure>());
    });

    test('formats a value without floating-point tail', () {
      expect(formatNumber(10 / 3), '3.333333');
      expect(formatNumber(3.0), '3');
    });
  });
}
