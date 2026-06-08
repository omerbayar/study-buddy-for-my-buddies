import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';
import '../repositories/study_repository.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key, required this.onNavigate});
  final void Function(int tabIndex) onNavigate;

  static Future<void> show(
      BuildContext context, void Function(int) onNavigate) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CommandPalette(onNavigate: onNavigate),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  String _query = '';

  late List<_PaletteAction> _allActions;

  @override
  void initState() {
    super.initState();
    final timer = context.read<TimerProvider>();
    final repo = context.read<StudyRepository>();
    final subjects = repo.getSubjects();

    _allActions = [
      _PaletteAction(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard\'a git',
        onTap: () => widget.onNavigate(0),
      ),
      _PaletteAction(
        icon: Icons.book_outlined,
        label: 'Dersler\'e git',
        onTap: () => widget.onNavigate(1),
      ),
      _PaletteAction(
        icon: Icons.quiz_outlined,
        label: 'Soru Sayacı\'na git',
        onTap: () => widget.onNavigate(2),
      ),
      _PaletteAction(
        icon: Icons.bar_chart_outlined,
        label: 'İstatistikler\'e git',
        onTap: () => widget.onNavigate(3),
      ),
      _PaletteAction(
        icon: Icons.notes_outlined,
        label: 'Notlar\'a git',
        onTap: () => widget.onNavigate(4),
      ),
      _PaletteAction(
        icon: Icons.play_arrow,
        label: 'Timer başlat/durdur',
        onTap: () {
          timer.startPause();
          widget.onNavigate(0);
        },
      ),
      _PaletteAction(
        icon: Icons.replay,
        label: 'Timer sıfırla',
        onTap: () {
          timer.reset();
          widget.onNavigate(0);
        },
      ),
      ...subjects.map((s) => _PaletteAction(
            icon: Icons.book,
            label: '${s.emoji} ${s.name} seç',
            onTap: () {
              timer.selectSubject(s.id);
              widget.onNavigate(0);
            },
          )),
    ];
  }

  List<_PaletteAction> get _filtered {
    if (_query.isEmpty) return _allActions;
    return _allActions
        .where(
            (a) => a.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 560, maxHeight: 480),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ne yapmak istiyorsun?',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Sonuç yok'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final action = filtered[i];
                        return ListTile(
                          leading: Icon(action.icon),
                          title: Text(action.label),
                          onTap: () {
                            Navigator.pop(context);
                            action.onTap();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteAction {
  const _PaletteAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
