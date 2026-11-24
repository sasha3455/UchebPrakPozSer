class Currency {
  const Currency(this.code, this.name, this.rublesPerUnit);

  final String code;
  final String name;
  final double rublesPerUnit;
  String get label => '$code — $name';
}

const currencies = [
  Currency('RUB', 'Российский рубль', 1),
  Currency('USD', 'Доллар США', 92.5),
  Currency('EUR', 'Евро', 100.4),
  Currency('CNY', 'Китайский юань', 12.8),
  Currency('GBP', 'Фунт стерлингов', 117.3),
  Currency('JPY', 'Японская иена', 0.61),
];

class ConversionResult {
  const ConversionResult._({this.value, this.message});
  const ConversionResult.success(double value) : this._(value: value);
  const ConversionResult.failure(String message) : this._(message: message);

  final double? value;
  final String? message;
  bool get isSuccess => value != null;
}

Currency? currencyByCode(String? code) {
  for (final currency in currencies) {
    if (currency.code == code) {
      return currency;
    }
  }
  return null;
}

ConversionResult convert(String? rawAmount, String? fromCode, String? toCode) {
  final amount = double.tryParse(rawAmount?.replaceAll(',', '.') ?? '');
  if (amount == null) {
    return const ConversionResult.failure(
      'В адресе передана некорректная сумма',
    );
  }
  if (amount < 0) {
    return const ConversionResult.failure('Сумма не может быть отрицательной');
  }
  final from = currencyByCode(fromCode);
  final to = currencyByCode(toCode);
  if (from == null || to == null) {
    return const ConversionResult.failure('Неизвестная валюта в адресе');
  }
  return ConversionResult.success(
    amount * from.rublesPerUnit / to.rublesPerUnit,
  );
}
