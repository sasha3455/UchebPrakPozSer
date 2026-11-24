import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/app_settings.dart';
import '../widgets/app_page.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({required this.settings, super.key});
  final AppSettings settings;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _operation = '+';

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите число';
    }
    if (double.tryParse(value.trim().replaceAll(',', '.')) == null) {
      return 'Это не число';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final query = Uri(
      queryParameters: {
        'a': _aController.text.trim().replaceAll(',', '.'),
        'op': _operation,
        'b': _bController.text.trim().replaceAll(',', '.'),
      },
    ).query;
    context.go('/calculator/result?$query');
  }

  @override
  Widget build(BuildContext context) => AppPage(
    settings: widget.settings,
    title: 'Калькулятор',
    child: Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Введите два числа и выберите действие.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _aController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(labelText: 'Первое число'),
            validator: _numberValidator,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _operation,
            decoration: const InputDecoration(labelText: 'Операция'),
            items: const ['+', '-', '*', '/']
                .map(
                  (operation) => DropdownMenuItem(
                    value: operation,
                    child: Text(operation),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _operation = value ?? '+'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: const InputDecoration(labelText: 'Второе число'),
            validator: _numberValidator,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _submit, child: const Text('Вычислить')),
        ],
      ),
    ),
  );
}
