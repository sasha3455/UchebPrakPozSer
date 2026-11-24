import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/currency.dart';
import '../services/app_settings.dart';
import '../widgets/app_page.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({required this.settings, super.key});
  final AppSettings settings;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    _from = currencyByCode(widget.settings.fromCurrency)?.code ?? 'RUB';
    _to = currencyByCode(widget.settings.toCurrency)?.code ?? 'USD';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    final amount = double.tryParse(value.trim().replaceAll(',', '.'));
    if (amount == null) return 'Это не число';
    if (amount < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  void _setCurrencies({String? from, String? to}) {
    setState(() {
      _from = from ?? _from;
      _to = to ?? _to;
    });
    widget.settings.saveCurrencies(_from, _to);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.settings.saveCurrencies(_from, _to);
    final query = Uri(
      queryParameters: {
        'amount': _amountController.text.trim().replaceAll(',', '.'),
        'from': _from,
        'to': _to,
      },
    ).query;
    context.go('/converter/result?$query');
  }

  @override
  Widget build(BuildContext context) => AppPage(
    settings: widget.settings,
    title: 'Конвертер валют',
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Курсы заданы константами в коде и выражены в рублях.'),
          const SizedBox(height: 24),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Сумма'),
            validator: _amountValidator,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _from,
            decoration: const InputDecoration(labelText: 'Из валюты'),
            items: currencies
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency.code,
                    child: Text(currency.label),
                  ),
                )
                .toList(),
            onChanged: (value) => _setCurrencies(from: value),
            validator: (value) => value == null ? 'Выберите валюту' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _to,
            decoration: const InputDecoration(labelText: 'В валюту'),
            items: currencies
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency.code,
                    child: Text(currency.label),
                  ),
                )
                .toList(),
            onChanged: (value) => _setCurrencies(to: value),
            validator: (value) => value == null ? 'Выберите валюту' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Конвертировать')),
        ],
      ),
    ),
  );
}
