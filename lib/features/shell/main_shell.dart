import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import 'sakan_drawer.dart';

/// GlobalKey on the shell [Scaffold] so any tab — even ones that wrap
/// themselves in their own Scaffold — can open the app-wide side drawer via
/// [openAppDrawer], regardless of the nearest Scaffold in the tree.
final GlobalKey<ScaffoldState> rootScaffoldKey =
    GlobalKey<ScaffoldState>(debugLabel: 'sakanRootScaffold');

/// Opens the app-wide (right-hand, under RTL) side drawer from anywhere.
void openAppDrawer() => rootScaffoldKey.currentState?.openDrawer();

/// Height of the curved bottom navigation bar.
const double kBottomNavHeight = 64;

/// Bottom space a scrollable should reserve so its last item clears the
/// floating curved nav bar. Long-list screens add this to their bottom padding
/// (the shell uses `extendBody`, so content flows under the bar).
const double kBottomNavSpace = 96;

/// Hosts the five primary tabs in a curved bottom bar. The selected tab is
/// raised into a floating circle by the bar itself — Search behaves exactly
/// like every other item (it is not a permanent floating button). A right-side
/// drawer (RTL) provides the full menu.
///
/// Uses go_router's [StatefulNavigationShell] so each tab keeps its own
/// navigation stack and scroll position across switches.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Router branches: 0 home · 1 search · 2 favorites · 3 requests · 4 account.
  // The bar is laid out left→right and we force LTR (see build) to keep the
  // highlight bump aligned with its icon. Ordering Home LAST places it on the
  // RIGHT — the natural first tab under RTL. Reading right→left, the bar is:
  // Home · Search · Favorites · Requests · Account.
  static const List<int> _barBranches = [4, 3, 2, 1, 0];

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  int _barIndex = 4; // Home (rightmost) selected by default.

  int get _branch => widget.navigationShell.currentIndex;

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect navigation that did NOT originate from a bar tap (drawer links,
    // "see all", deep links) in the curved bar's selection.
    final i = _barBranches.indexOf(_branch);
    if (i != -1 && i != _barIndex) {
      _barIndex = i;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navKey.currentState?.setPage(_barIndex);
      });
    }
  }

  void _onBarTap(int index) {
    if (_barIndex != index) setState(() => _barIndex = index);
    final branch = _barBranches[index];
    widget.navigationShell.goBranch(
      branch,
      initialLocation: branch == _branch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      key: rootScaffoldKey,
      extendBody: true,
      drawer: const SakanDrawer(),
      body: widget.navigationShell,
      bottomNavigationBar: DecoratedBox(
        // A soft shadow lifts the transparent-backed bar off the content.
        decoration: const BoxDecoration(boxShadow: AppShadows.card),
        // curved_navigation_bar isn't directionality-aware: a surrounding RTL
        // Directionality reverses the item Row, while the highlight bump (drawn
        // with absolute Alignment) does not — desyncing them. Force LTR here
        // and order items so Home still lands on the right (see _barBranches).
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: CurvedNavigationBar(
            key: _navKey,
            index: _barIndex,
            height: kBottomNavHeight,
            backgroundColor: Colors.transparent,
            color: c.surface,
            buttonBackgroundColor: c.primary,
            animationCurve: Curves.easeOutCubic,
            animationDuration: const Duration(milliseconds: 400),
            onTap: _onBarTap,
            items: [
              _NavIcon(Icons.person_rounded, selected: _barIndex == 0),
              _NavIcon(Icons.receipt_long_rounded, selected: _barIndex == 1),
              _NavIcon(Icons.favorite_rounded, selected: _barIndex == 2),
              _NavIcon(Icons.search_rounded, selected: _barIndex == 3),
              _NavIcon(Icons.home_rounded, selected: _barIndex == 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bar icon: white when raised into the selected circle, muted otherwise.
class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon, {required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Icon(
      icon,
      size: 26,
      color: selected ? c.primaryForeground : c.mutedForeground,
    );
  }
}

/// A hamburger button for tab AppBars that opens the app-wide side drawer.
/// Named `AppDrawerButton` to avoid clashing with Flutter's own [DrawerButton].
class AppDrawerButton extends StatelessWidget {
  const AppDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu_rounded),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: openAppDrawer,
    );
  }
}
