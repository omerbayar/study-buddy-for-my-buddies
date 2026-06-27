import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/translations.dart';
import '../models/bullet_item.dart';
import '../models/bullet_list_model.dart';
import '../repositories/study_repository.dart';

class BulletListScreen extends StatefulWidget {
  const BulletListScreen({super.key});

  @override
  State<BulletListScreen> createState() => _BulletListScreenState();
}

class _BulletListScreenState extends State<BulletListScreen> {
  String? _selectedListId;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<StudyRepository>();

    return ValueListenableBuilder(
      valueListenable: repo.watchBulletLists(),
      builder: (context, box, _) {
        final lists = repo.getBulletLists();

        if (_selectedListId == null && lists.isNotEmpty) {
          _selectedListId = lists.first.id;
        }
        if (_selectedListId != null &&
            !lists.any((l) => l.id == _selectedListId)) {
          _selectedListId = lists.isNotEmpty ? lists.first.id : null;
        }

        final selectedList = lists.where((l) => l.id == _selectedListId).firstOrNull;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return _WideLayout(
                lists: lists,
                selectedList: selectedList,
                onSelectList: (id) => setState(() => _selectedListId = id),
                onNewList: () => _showNewListDialog(context, repo),
                repo: repo,
              );
            }

            return _NarrowLayout(
              lists: lists,
              selectedList: selectedList,
              onSelectList: (id) => setState(() => _selectedListId = id),
              onNewList: () => _showNewListDialog(context, repo),
              repo: repo,
            );
          },
        );
      },
    );
  }

  void _showNewListDialog(BuildContext context, StudyRepository repo) {
    showDialog<void>(
      context: context,
      builder: (_) => _NewListDialog(repo: repo),
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.lists,
    required this.selectedList,
    required this.onSelectList,
    required this.onNewList,
    required this.repo,
  });

  final List<BulletListModel> lists;
  final BulletListModel? selectedList;
  final ValueChanged<String> onSelectList;
  final VoidCallback onNewList;
  final StudyRepository repo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 240,
          child: _ListSidebar(
            lists: lists,
            selectedId: selectedList?.id,
            onSelect: onSelectList,
            onNew: onNewList,
            repo: repo,
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: selectedList == null
              ? _EmptyState(onNew: onNewList)
              : _ListDetail(list: selectedList!, repo: repo),
        ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.lists,
    required this.selectedList,
    required this.onSelectList,
    required this.onNewList,
    required this.repo,
  });

  final List<BulletListModel> lists;
  final BulletListModel? selectedList;
  final ValueChanged<String> onSelectList;
  final VoidCallback onNewList;
  final StudyRepository repo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (lists.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedList?.id,
                    decoration: InputDecoration(
                      labelText: translate('bullet.title'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: lists.map((l) => DropdownMenuItem(
                      value: l.id,
                      child: Text(l.name, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (id) {
                      if (id != null) onSelectList(id);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: onNew,
                  icon: const Icon(Icons.add),
                  tooltip: translate('bullet.new_list'),
                ),
              ],
            ),
          ),
        Expanded(
          child: selectedList == null
              ? _EmptyState(onNew: onNew)
              : _ListDetail(list: selectedList!, repo: repo),
        ),
      ],
    );
  }

  VoidCallback get onNew => onNewList;
}

class _ListSidebar extends StatelessWidget {
  const _ListSidebar({
    required this.lists,
    required this.selectedId,
    required this.onSelect,
    required this.onNew,
    required this.repo,
  });

  final List<BulletListModel> lists;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNew;
  final StudyRepository repo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: lists.isEmpty
              ? Center(
                  child: Text(
                    translate('bullet.empty'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: lists.length,
                  itemBuilder: (context, i) {
                    final list = lists[i];
                    final isSelected = list.id == selectedId;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(80),
                      leading: Icon(
                        list.isRanged
                            ? Icons.format_list_numbered
                            : Icons.checklist,
                        size: 18,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        list.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      subtitle: Text(
                        '${list.items.length} ${translate('bullet.items_count')}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => onSelect(list.id),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        tooltip: translate('bullet.delete_list'),
                        onPressed: () =>
                            _confirmDelete(context, list, repo),
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(translate('bullet.new_list')),
          onTap: onNew,
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, BulletListModel list, StudyRepository repo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('bullet.delete_list')),
        content: Text(
            translate('bullet.delete_confirm', {'name': list.name})),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(translate('common.cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(translate('common.delete'))),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.deleteBulletList(list.id);
    }
  }
}

class _ListDetail extends StatefulWidget {
  const _ListDetail({required this.list, required this.repo});

  final BulletListModel list;
  final StudyRepository repo;

  @override
  State<_ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<_ListDetail> {
  final _addController = TextEditingController();
  final _addFocus = FocusNode();

  @override
  void dispose() {
    _addController.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    final doneCount = list.items.where((i) => i.done).length;
    final totalCount = list.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (totalCount > 0)
                      Text(
                        '$doneCount / $totalCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (list.isRanged)
                Chip(
                  label: Text(
                      '${list.rangeStart} → ${list.rangeEnd}'),
                  avatar: const Icon(Icons.format_list_numbered, size: 14),
                ),
            ],
          ),
        ),
        if (totalCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? doneCount / totalCount : 0,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: list.items.isEmpty
              ? Center(
                  child: Text(
                    translate('bullet.empty_list'),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: list.items.length,
                  itemBuilder: (context, i) {
                    final item = list.items[i];
                    return _ItemTile(
                      item: item,
                      isRanged: list.isRanged,
                      onToggle: () => _toggleItem(item),
                      onNoteChanged: list.isRanged
                          ? (note) => _updateNote(item, note)
                          : null,
                    );
                  },
                ),
        ),
        if (!list.isRanged) _FreeItemInput(
          controller: _addController,
          focusNode: _addFocus,
          onAdd: _addFreeItem,
        ),
      ],
    );
  }

  Future<void> _toggleItem(BulletItem item) async {
    final list = widget.list;
    final updatedItems = list.items
        .map((i) => i.id == item.id ? i.copyWith(done: !i.done) : i)
        .toList();
    final updated = BulletListModel(
      id: list.id,
      name: list.name,
      createdAt: list.createdAt,
      items: updatedItems,
      rangeStart: list.rangeStart,
      rangeEnd: list.rangeEnd,
    );
    await widget.repo.saveBulletList(updated);
  }

  Future<void> _updateNote(BulletItem item, String note) async {
    final list = widget.list;
    final updatedItems = list.items
        .map((i) => i.id == item.id
            ? i.copyWith(note: note.isEmpty ? null : note, clearNote: note.isEmpty)
            : i)
        .toList();
    final updated = BulletListModel(
      id: list.id,
      name: list.name,
      createdAt: list.createdAt,
      items: updatedItems,
      rangeStart: list.rangeStart,
      rangeEnd: list.rangeEnd,
    );
    await widget.repo.saveBulletList(updated);
  }

  Future<void> _addFreeItem(String label) async {
    if (label.isEmpty) return;
    final list = widget.list;
    final newItem = BulletItem(
      id: const Uuid().v4(),
      label: label,
      done: false,
      order: list.items.length,
    );
    final updated = BulletListModel(
      id: list.id,
      name: list.name,
      createdAt: list.createdAt,
      items: [...list.items, newItem],
      rangeStart: list.rangeStart,
      rangeEnd: list.rangeEnd,
    );
    await widget.repo.saveBulletList(updated);
    _addController.clear();
    _addFocus.requestFocus();
  }
}

class _ItemTile extends StatefulWidget {
  const _ItemTile({
    required this.item,
    required this.isRanged,
    required this.onToggle,
    this.onNoteChanged,
  });

  final BulletItem item;
  final bool isRanged;
  final VoidCallback onToggle;
  final ValueChanged<String>? onNoteChanged;

  @override
  State<_ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<_ItemTile> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.note ?? '');
  }

  @override
  void didUpdateWidget(_ItemTile old) {
    super.didUpdateWidget(old);
    if (old.item.note != widget.item.note &&
        widget.item.note != _noteController.text) {
      _noteController.text = widget.item.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDone = item.done;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: (_) => widget.onToggle(),
            ),
            if (widget.isRanged) ...[
              SizedBox(
                width: 44,
                child: Text(
                  '${item.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: translate('bullet.note_placeholder'),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                    fontSize: 14,
                  ),
                  onSubmitted: (v) => widget.onNoteChanged?.call(v),
                  onTapOutside: (_) =>
                      widget.onNoteChanged?.call(_noteController.text),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FreeItemInput extends StatelessWidget {
  const _FreeItemInput({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.viewInsetsOf(context).bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: translate('bullet.add_item'),
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: onAdd,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => onAdd(controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('☑️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            translate('bullet.empty'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add),
            label: Text(translate('bullet.new_list')),
          ),
        ],
      ),
    );
  }
}

class _NewListDialog extends StatefulWidget {
  const _NewListDialog({required this.repo});
  final StudyRepository repo;

  @override
  State<_NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<_NewListDialog> {
  final _nameController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  bool _useRange = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(translate('bullet.new_list')),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: translate('bullet.list_name'),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _useRange ? null : _save(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(translate('bullet.use_range')),
              value: _useRange,
              onChanged: (v) => setState(() {
                _useRange = v;
                _errorText = null;
              }),
            ),
            if (_useRange) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: translate('bullet.range_start'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() => _errorText = null),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('→'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _endController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: translate('bullet.range_end'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() => _errorText = null),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate('common.cancel'))),
        FilledButton(
            onPressed: _save, child: Text(translate('common.add'))),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    int? rangeStart;
    int? rangeEnd;
    List<BulletItem> items = [];

    if (_useRange) {
      final startVal = int.tryParse(_startController.text.trim());
      final endVal = int.tryParse(_endController.text.trim());

      if (startVal == null || endVal == null) {
        setState(() => _errorText = translate('bullet.error_invalid_number'));
        return;
      }

      if (startVal > endVal) {
        setState(() =>
            _errorText = translate('bullet.error_start_gt_end'));
        return;
      }

      final count = endVal - startVal + 1;
      if (count > 200) {
        setState(() => _errorText = translate(
            'bullet.error_range_too_large', {'max': 200}));
        return;
      }

      rangeStart = startVal;
      rangeEnd = endVal;
      items = List.generate(
        count,
        (i) => BulletItem(
          id: const Uuid().v4(),
          label: '',
          done: false,
          number: startVal + i,
          order: i,
        ),
      );
    }

    final list = BulletListModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      items: items,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    widget.repo.saveBulletList(list).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }
}
