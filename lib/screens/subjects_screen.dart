import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/translations.dart';
import '../models/subject.dart';
import '../repositories/study_repository.dart';

const _kDefaultEmojis = ['📚', '🔬', '🧮', '🗺️', '🎨', '🎵', '💻', '⚗️', '📖', '🏛️'];
const _kDefaultColors = [
  Color(0xFF6C63FF),
  Color(0xFF4CAF50),
  Color(0xFFFF5722),
  Color(0xFF2196F3),
  Color(0xFFFF9800),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFE91E63),
];

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late final StudyRepository _repo;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _repo = context.read<StudyRepository>();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is KeyDownEvent &&
            e.logicalKey == LogicalKeyboardKey.keyN &&
            !HardwareKeyboard.instance.isMetaPressed &&
            !HardwareKeyboard.instance.isControlPressed) {
          _showAddDialog(context);
        }
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: translate('subjects.add_tooltip'),
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
        body: ValueListenableBuilder(
          valueListenable: _repo.watchSubjects(),
          builder: (context, box, _) {
            final subjects = box.values.toList();
            if (subjects.isEmpty) {
              return _EmptySubjects(onAdd: () => _showAddDialog(context));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, i) =>
                  _SubjectTile(subject: subjects[i], repo: _repo),
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _SubjectDialog(repo: _repo),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject, required this.repo});

  final Subject subject;
  final StudyRepository repo;

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Text(subject.emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(subject.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(translate('subjects.delete_title')),
                content: Text(translate(
                    'subjects.delete_confirm', {'name': subject.name})),
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
              await repo.deleteSubject(subject.id);
            }
          },
        ),
      ),
    );
  }
}

class _SubjectDialog extends StatefulWidget {
  const _SubjectDialog({required this.repo});
  final StudyRepository repo;

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  int _selectedEmojiIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(translate('subjects.dialog_title')),
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
                labelText: translate('subjects.field_name'),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            Text(translate('subjects.label_emoji'),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_kDefaultEmojis.length, (i) {
                final selected = i == _selectedEmojiIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmojiIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(_kDefaultEmojis[i],
                        style: const TextStyle(fontSize: 22)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Text(translate('subjects.label_color'),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(_kDefaultColors.length, (i) {
                final selected = i == _selectedColorIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kDefaultColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: _kDefaultColors[i].withAlpha(150),
                                blurRadius: 6,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final subject = Subject(
      id: const Uuid().v4(),
      name: name,
      colorValue: _kDefaultColors[_selectedColorIndex].toARGB32(),
      emoji: _kDefaultEmojis[_selectedEmojiIndex],
    );
    await widget.repo.saveSubject(subject);
    if (mounted) Navigator.pop(context);
  }
}

class _EmptySubjects extends StatelessWidget {
  const _EmptySubjects({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📚', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(translate('subjects.empty_title'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(translate('subjects.empty_hint')),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(translate('subjects.add_first')),
          ),
        ],
      ),
    );
  }
}
