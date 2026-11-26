import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });

  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;
}

class EntityTable<T> extends StatelessWidget {
  const EntityTable({
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    super.key,
  });

  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  @override
  Widget build(BuildContext context) {
    final sortIndex = columns.indexWhere(
      (column) => column.sortField == sortField,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width - 40,
          ),
          child: DataTable(
            showCheckboxColumn: onToggleSelect != null,
            sortColumnIndex: sortIndex >= 0 ? sortIndex : null,
            sortAscending: sortAscending,
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            columns: [
              for (final column in columns)
                DataColumn(
                  numeric: column.numeric,
                  label: Text(
                    column.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onSort: column.sortField == null || onSort == null
                      ? null
                      : (_, ascending) => onSort!(column.sortField!),
                ),
              if (actions != null) const DataColumn(label: Text('Действия')),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  key: ValueKey(idOf(item)),
                  selected: selected.contains(idOf(item)),
                  onSelectChanged: onToggleSelect == null
                      ? null
                      : (_) => onToggleSelect!(idOf(item)),
                  cells: [
                    for (final column in columns) DataCell(column.build(item)),
                    if (actions != null)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!(item),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EntityCardList<T> extends StatelessWidget {
  const EntityCardList({required this.items, required this.builder, super.key});

  final List<T> items;
  final Widget Function(BuildContext context, T item) builder;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    itemCount: items.length,
    separatorBuilder: (_, index) => const SizedBox(height: 12),
    itemBuilder: (context, index) => builder(context, items[index]),
  );
}
