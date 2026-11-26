import 'package:flutter/material.dart';

import '../models/page_result.dart';

class PaginationBar<T> extends StatelessWidget {
  const PaginationBar({
    required this.result,
    required this.onPage,
    required this.onSize,
    super.key,
  });

  final PageResult<T> result;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          'Страница ${result.page} из ${result.totalPages} · записей: ${result.total}',
        ),
        IconButton(
          tooltip: 'Первая страница',
          onPressed: result.hasPrevious ? () => onPage(1) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          tooltip: 'Предыдущая страница',
          onPressed: result.hasPrevious ? () => onPage(result.page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Следующая страница',
          onPressed: result.hasNext ? () => onPage(result.page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          tooltip: 'Последняя страница',
          onPressed: result.hasNext ? () => onPage(result.totalPages) : null,
          icon: const Icon(Icons.last_page),
        ),
        DropdownButton<int>(
          value: result.size,
          items: const [10, 25, 50]
              .map(
                (size) =>
                    DropdownMenuItem(value: size, child: Text('$size / стр.')),
              )
              .toList(),
          onChanged: (size) {
            if (size != null) onSize(size);
          },
        ),
      ],
    ),
  );
}
