import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../models/director.dart';
import '../models/director_query.dart';
import '../state/load_status.dart';
import '../state/director_list_notifier.dart';
import '../widgets/entity_table.dart';
import '../widgets/load_state_view.dart';
import '../widgets/pagination_bar.dart';

const directorCountries = [
  'Великобритания',
  'Германия',
  'Мексика',
  'Новая Зеландия',
  'США',
];

class DirectorListScreen extends StatefulWidget {
  const DirectorListScreen({required this.uri, super.key});

  final Uri uri;

  @override
  State<DirectorListScreen> createState() => _DirectorListScreenState();
}

class _DirectorListScreenState extends State<DirectorListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;
  bool _settingControllers = false;
  String? _country;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncQuery(widget.uri));
  }

  @override
  void didUpdateWidget(covariant DirectorListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri.toString() != widget.uri.toString()) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _syncQuery(widget.uri),
      );
    }
  }

  void _syncQuery(Uri uri) {
    if (!mounted) return;
    final query = DirectorQuery.fromUri(uri);
    final notifier = context.read<DirectorListNotifier>();
    _settingControllers = true;
    _searchController.text = query.search;
    _country = query.country;
    _settingControllers = false;
    if (notifier.query != query) unawaited(notifier.applyQuery(query));
  }

  void _onSearchChanged() {
    if (_settingControllers) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final notifier = context.read<DirectorListNotifier>();
      _go(notifier.query.copyWith(search: _searchController.text));
    });
  }

  void _go(DirectorQuery query) =>
      context.go(query.toUri('/directors').toString());

  void _sort(String field) {
    final current = context.read<DirectorListNotifier>().query;
    _go(
      current.copyWith(
        sortField: field,
        sortAscending: field == current.sortField
            ? !current.sortAscending
            : true,
      ),
    );
  }

  Future<void> _confirmDelete(Director director, {bool hard = false}) async {
    final notifier = context.read<DirectorListNotifier>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          hard
              ? 'Удалить навсегда?'
              : (director.isDeleted
                    ? 'Восстановить режиссёра?'
                    : 'Скрыть режиссёра?'),
        ),
        content: Text(
          hard
              ? 'Запись «${director.name}» будет удалена навсегда.'
              : director.isDeleted
              ? 'Режиссёр снова появится в каталоге.'
              : 'Режиссёр получит deletedAt и исчезнет из обычного списка.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              hard
                  ? 'Удалить'
                  : director.isDeleted
                  ? 'Восстановить'
                  : 'Скрыть',
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (hard) {
      await notifier.hardDelete(director.id);
    } else if (director.isDeleted) {
      await notifier.restore(director.id);
    } else {
      await notifier.softDelete(director.id);
    }
  }

  Future<void> _deleteSelected() async {
    final notifier = context.read<DirectorListNotifier>();
    if (notifier.selected.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скрыть выбранных режиссёров?'),
        content: Text('Будет скрыто записей: ${notifier.selected.length}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Скрыть'),
          ),
        ],
      ),
    );
    if (confirmed == true) await notifier.deleteSelected();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Режиссёры'),
      actions: [
        IconButton(
          tooltip: 'Добавить режиссёра',
          onPressed: () => context.go('/directors/0'),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: Consumer<DirectorListNotifier>(
      builder: (context, notifier, _) => Column(
        children: [
          _toolbar(context, notifier),
          Expanded(child: _content(context, notifier)),
          if (notifier.status == LoadStatus.success)
            PaginationBar<Director>(
              result: notifier.result,
              onPage: (page) =>
                  _go(notifier.query.copyWith(page: page, resetPage: false)),
              onSize: (size) => _go(notifier.query.copyWith(size: size)),
            ),
        ],
      ),
    ),
  );

  Widget _toolbar(BuildContext context, DirectorListNotifier notifier) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Поиск по имени, стране или биографии',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: 'Фильтры',
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(
                    _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                  ),
                ),
              ],
            ),
            if (_showFilters) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(_country),
                      initialValue: _country,
                      decoration: const InputDecoration(
                        labelText: 'Страна',
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Все страны'),
                        ),
                        ...directorCountries.map(
                          (country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => _country = value),
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () =>
                        _go(notifier.query.copyWith(country: _country)),
                    child: const Text('Применить'),
                  ),
                  TextButton(
                    onPressed: () => _go(const DirectorQuery()),
                    child: const Text('Сбросить'),
                  ),
                  FilterChip(
                    label: const Text('Показать удалённых'),
                    selected: notifier.query.includeDeleted,
                    onSelected: (value) =>
                        _go(notifier.query.copyWith(includeDeleted: value)),
                  ),
                ],
              ),
            ],
            if (notifier.hasSelection) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Выбрано: ${notifier.selected.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Скрыть выбранных'),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _content(BuildContext context, DirectorListNotifier notifier) =>
      LoadStateView(
        status: notifier.status,
        error: notifier.error,
        onRetry: notifier.load,
        emptyLabel: 'Режиссёры не найдены',
        child: notifier.result.items.isEmpty
            ? LoadStateView.empty(
                context,
                'Режиссёры не найдены',
                () => _go(const DirectorQuery()),
              )
            : screenSizeOf(context) == ScreenSize.compact
            ? EntityCardList<Director>(
                items: notifier.result.items,
                builder: _buildCard,
              )
            : EntityTable<Director>(
                items: notifier.result.items,
                idOf: (director) => director.id,
                selected: notifier.selected,
                onToggleSelect: notifier.toggleSelection,
                sortField: notifier.query.sortField,
                sortAscending: notifier.query.sortAscending,
                onSort: _sort,
                columns: [
                  TableColumnSpec(
                    label: 'Имя',
                    sortField: 'name',
                    build: (d) => Text(
                      d.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TableColumnSpec(
                    label: 'Страна',
                    sortField: 'country',
                    build: (d) => Text(d.country),
                  ),
                  TableColumnSpec(
                    label: 'Год рождения',
                    sortField: 'birthYear',
                    numeric: true,
                    build: (d) => Text('${d.birthYear}'),
                  ),
                ],
                actions: (director) => [
                  IconButton(
                    tooltip: 'Открыть карточку',
                    onPressed: () => context.go('/directors/${director.id}'),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  IconButton(
                    tooltip: director.isDeleted ? 'Восстановить' : 'Скрыть',
                    onPressed: () => _confirmDelete(director),
                    icon: Icon(
                      director.isDeleted ? Icons.restore : Icons.delete_outline,
                    ),
                  ),
                ],
              ),
      );

  Widget _buildCard(BuildContext context, Director director) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text(director.name.substring(0, 1))),
      title: Text(
        director.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${director.country} · род. ${director.birthYear}\n${director.bio}',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: IconButton(
        onPressed: () => context.go('/directors/${director.id}'),
        icon: const Icon(Icons.open_in_new),
      ),
    ),
  );

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
