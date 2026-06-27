import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/translations.dart';
import '../models/note.dart';
import '../repositories/study_repository.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _controller = TextEditingController();
  final _searchController = TextEditingController();
  final _inputFocus = FocusNode();
  final _rootFocus = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _inputFocus.dispose();
    _rootFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<StudyRepository>();

    return KeyboardListener(
      focusNode: _rootFocus,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final meta = HardwareKeyboard.instance.isMetaPressed ||
            HardwareKeyboard.instance.isControlPressed;
        if (!meta && e.logicalKey == LogicalKeyboardKey.slash) {
          _inputFocus.requestFocus();
          _searchController.clear();
          setState(() => _searchQuery = '');
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: translate('notes.search_hint'),
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: repo.watchNotes(),
              builder: (context, box, _) {
                final allNotes = repo.getNotes();
                final notes = _searchQuery.isEmpty
                    ? allNotes
                    : allNotes
                        .where((n) =>
                            n.content
                                .toLowerCase()
                                .contains(_searchQuery) ||
                            n.tags.any((t) => t.contains(_searchQuery)))
                        .toList();

                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? translate('notes.empty_title')
                              : translate('notes.no_results'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(translate('notes.empty_hint')),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, i) =>
                      _NoteTile(note: notes[i], repo: repo),
                );
              },
            ),
          ),
          _NoteInput(
            controller: _controller,
            focusNode: _inputFocus,
            repo: repo,
          ),
        ],
      ),
    );
  }
}

class _NoteInput extends StatelessWidget {
  const _NoteInput({
    required this.controller,
    required this.focusNode,
    required this.repo,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final StudyRepository repo;

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
          const Text('•  ', style: TextStyle(fontSize: 20)),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: translate('notes.input_hint'),
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _save(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _save(context),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final tags =
        RegExp(r'#(\w+)').allMatches(text).map((m) => m.group(1)!).toList();
    await repo.saveNote(Note(
      id: const Uuid().v4(),
      content: text,
      createdAt: DateTime.now(),
      tags: tags,
    ));
    controller.clear();
    focusNode.requestFocus();
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.repo});

  final Note note;
  final StudyRepository repo;

  @override
  Widget build(BuildContext context) {
    final time = '${note.createdAt.hour.toString().padLeft(2, '0')}:'
        '${note.createdAt.minute.toString().padLeft(2, '0')}';
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => repo.deleteNote(note.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Text('•', style: TextStyle(fontSize: 24)),
          title: Text(note.content),
          subtitle: note.tags.isNotEmpty
              ? Wrap(
                  spacing: 4,
                  children: note.tags
                      .map((t) => Chip(
                            label: Text('#$t',
                                style: const TextStyle(fontSize: 11)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                )
              : null,
          trailing: Text(time,
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ),
      ),
    );
  }
}
