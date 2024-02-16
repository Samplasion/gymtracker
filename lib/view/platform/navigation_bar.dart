import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformNavigationBar extends PlatformStatelessWidget {
  final NavigationDestinationLabelBehavior labelBehavior;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(dynamic i) onDestinationSelected;

  const PlatformNavigationBar({
    super.key,
    required this.labelBehavior,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return NavigationBar(
      labelBehavior: labelBehavior,
      destinations: destinations,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoTabBar(
      items: destinations
          .map(
            (e) => BottomNavigationBarItem(
              icon: e.icon,
              label: e.label,
            ),
          )
          .toList(),
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
    );
  }
}
