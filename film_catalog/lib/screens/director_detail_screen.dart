import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/director.dart';
import '../state/director_list_notifier.dart';

class DirectorDetailScreen extends StatefulWidget {
  const DirectorDetailScreen({required this.id, super.key});
  final int id;

  @override
  State<DirectorDetailScreen> createState() => _DirectorDetailScreenState();
}

class _DirectorDetailScreenState extends State<DirectorDetailScreen> {
  Director? _director;
  bool _loading = true;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _country = TextEditingController();
  final _birthYear = TextEditingController();
  final _bio = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final director = widget.id == 0
        ? null
        : await context.read<DirectorListNotifier>().findById(widget.id);
    if (!mounted) return;
    if (director != null) {
      _director = director;
      _name.text = director.name;
      _country.text = director.country;
      _birthYear.text = '${director.birthYear}';
      _bio.text = director.bio;
    } else if (widget.id == 0) {
      _birthYear.text = '1970';
      _bio.text = 'Биография режиссёра';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<DirectorListNotifier>().save(
      Director(
        id: _director?.id ?? 0,
        name: _name.text.trim(),
        country: _country.text.trim(),
        birthYear: int.parse(_birthYear.text),
        bio: _bio.text.trim(),
        deletedAt: _director?.deletedAt,
      ),
    );
    if (mounted) context.go('/directors');
  }

  Future<void> _hardDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить навсегда?'),
        content: Text('Запись «${_director?.name}» будет удалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<DirectorListNotifier>().hardDelete(_director!.id);
      if (mounted) context.go('/directors');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == 0 ? 'Новый режиссёр' : 'Карточка режиссёра'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Имя и фамилия',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(labelText: 'Страна'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _birthYear,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Год рождения',
                    ),
                    validator: (value) => int.tryParse(value ?? '') == null
                        ? 'Введите год'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bio,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(labelText: 'Биография'),
                    validator: _required,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(_saving ? 'Сохранение…' : 'Сохранить'),
                  ),
                  if (_director != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _hardDelete,
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Удалить навсегда'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Заполните поле' : null;

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _birthYear.dispose();
    _bio.dispose();
    super.dispose();
  }
}
