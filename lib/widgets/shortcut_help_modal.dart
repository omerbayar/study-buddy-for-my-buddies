import 'package:flutter/material.dart';

import '../l10n/translations.dart';

class ShortcutHelpModal extends StatelessWidget {
  const ShortcutHelpModal({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const ShortcutHelpModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⌨️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(translate('shortcuts.title'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              _Section(translate('shortcuts.section_timer'), [
                _Shortcut('Space', translate('shortcuts.start_stop')),
                _Shortcut('S', translate('shortcuts.skip_session')),
                _Shortcut('R', translate('shortcuts.reset_timer')),
              ]),
              _Section(translate('shortcuts.section_nav'), [
                _Shortcut('1–9', translate('shortcuts.select_subject_dash')),
                _Shortcut('Cmd/Ctrl + K', translate('shortcuts.cmd_palette')),
                _Shortcut('?', translate('shortcuts.help_menu')),
              ]),
              _Section(translate('shortcuts.section_subjects'), [
                _Shortcut('N', translate('shortcuts.new_subject')),
              ]),
              _Section(translate('shortcuts.section_questions'), [
                _Shortcut('→ / D', translate('shortcuts.correct')),
                _Shortcut('← / A', translate('shortcuts.wrong')),
                _Shortcut('↓ / X', translate('shortcuts.blank')),
                _Shortcut('Z', translate('shortcuts.undo')),
              ]),
              _Section(translate('shortcuts.section_notes'), [
                _Shortcut('/', translate('shortcuts.focus_search')),
                _Shortcut('Enter', translate('shortcuts.send_note')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.shortcuts);
  final String title;
  final List<_Shortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...shortcuts,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(this.shortcutKey, this.description);
  final String shortcutKey;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(shortcutKey,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Text(description),
        ],
      ),
    );
  }
}
