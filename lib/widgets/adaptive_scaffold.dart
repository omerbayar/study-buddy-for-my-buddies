import 'package:flutter/material.dart';

import 'global_app_bar_actions.dart';

class NavDestinationConfig {
  const NavDestinationConfig({
    required this.label,
    required this.icon,
    required this.body,
  });

  final String label;
  final Widget icon;
  final Widget body;
}

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    this.initialIndex = 0,
  });

  final List<NavDestinationConfig> destinations;
  final int initialIndex;

  @override
  State<AdaptiveScaffold> createState() => AdaptiveScaffoldState();
}

class AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void navigateTo(int index) {
    if (index >= 0 && index < widget.destinations.length) {
      setState(() => _index = index);
    }
  }

  int get currentIndex => _index;

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.destinations[_index].label),
      actions: const [
        GlobalAppBarActions(),
        SizedBox(width: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final useRail = MediaQuery.sizeOf(context).width >= 600;

    if (useRail) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              destinations: widget.destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.destinations[_index].body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.destinations[_index].body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: widget.destinations
            .map((d) => NavigationDestination(icon: d.icon, label: d.label))
            .toList(),
      ),
    );
  }
}
