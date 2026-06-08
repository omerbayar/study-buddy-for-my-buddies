import 'package:flutter/material.dart';

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
                  Text('Klavye Kısayolları',
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
              _Section('Timer', [
                _Shortcut('Space', 'Başlat / Durdur'),
                _Shortcut('S', 'Seansı atla'),
                _Shortcut('R', 'Sıfırla'),
              ]),
              _Section('Navigasyon', [
                _Shortcut('1–9', 'Ders seç (Dashboard)'),
                _Shortcut('Cmd/Ctrl + K', 'Komut paleti'),
                _Shortcut('?', 'Bu yardım menüsü'),
              ]),
              _Section('Dersler', [
                _Shortcut('N', 'Yeni ders ekle'),
              ]),
              _Section('Soru Sayacı', [
                _Shortcut('→ / D', 'Doğru'),
                _Shortcut('← / A', 'Yanlış'),
                _Shortcut('↓ / X', 'Boş'),
                _Shortcut('Z', 'Geri al'),
              ]),
              _Section('Notlar', [
                _Shortcut('/', 'Arama kutusuna odaklan'),
                _Shortcut('Enter', 'Not gönder'),
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
