sealed class CalcResult {
  const CalcResult();
}

class CalcSuccess extends CalcResult {
  const CalcSuccess(this.value);
  final double value;
}

class CalcFailure extends CalcResult {
  const CalcFailure(this.message);
  final String message;
}

CalcResult calculate(String? rawA, String? rawOperation, String? rawB) {
  final a = double.tryParse(rawA?.replaceAll(',', '.') ?? '');
  final b = double.tryParse(rawB?.replaceAll(',', '.') ?? '');
  if (a == null || b == null) {
    return const CalcFailure('В адресе переданы не числа');
  }

  return switch (rawOperation) {
    '+' => CalcSuccess(a + b),
    '-' => CalcSuccess(a - b),
    '*' => CalcSuccess(a * b),
    '/' =>
      b == 0
          ? const CalcFailure('Деление на ноль невозможно')
          : CalcSuccess(a / b),
    null => const CalcFailure('Не выбрана операция'),
    _ => const CalcFailure('Неизвестная операция'),
  };
}

String formatNumber(double number) {
  final rounded = (number * 1000000).round() / 1000000;
  return rounded
      .toStringAsFixed(6)
      .replaceFirst(RegExp(r'\.0+$'), '')
      .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
}
