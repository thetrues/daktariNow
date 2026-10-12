import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/brand_logo.dart';
import '../theme/app_colors.dart';
import 'breakpoints.dart';

class ShellDestination {
  const ShellDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class ShellAction {
  const ShellAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final void Function(BuildContext context) onPressed;
}

/// One shell for both roles: a bottom bar (with optional centre action
/// button, as in the mockup) on phones, and a sidebar on tablet/web.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.centerAction,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;
  final ShellAction? centerAction;

  void _go(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Breakpoints.isMobile(context)) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomBar(
          destinations: destinations,
          currentIndex: navigationShell.currentIndex,
          onTap: _go,
          centerAction: centerAction,
        ),
      );
    }

    final extended = Breakpoints.isDesktop(context);
    return Scaffold(
      body: Row(
        children: [
          _SideBar(
            extended: extended,
            destinations: destinations,
            currentIndex: navigationShell.currentIndex,
            onTap: _go,
            centerAction: centerAction,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
    this.centerAction,
  });

  final List<ShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ShellAction? centerAction;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < destinations.length; i++)
        Expanded(
          child: _BottomItem(
            destination: destinations[i],
            selected: i == currentIndex,
            onTap: () => onTap(i),
          ),
        ),
    ];
    if (centerAction != null) {
      final action = centerAction!;
      items.insert(
        items.length ~/ 2,
        Expanded(
          child: Center(
            child: Tooltip(
              message: action.label,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => action.onPressed(context),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(action.icon, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(height: 72, child: Row(children: items)),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? destination.selectedIcon : destination.icon,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _SideBar extends ConsumerWidget {
  const _SideBar({
    required this.extended,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
    this.centerAction,
  });

  final bool extended;
  final List<ShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final ShellAction? centerAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final action = centerAction;

    return NavigationRail(
      extended: extended,
      minExtendedWidth: 240,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment:
              extended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            BrandLogo(showName: extended),
            if (action != null) ...[
              const SizedBox(height: 24),
              extended
                  ? FilledButton.icon(
                      onPressed: () => action.onPressed(context),
                      icon: Icon(action.icon),
                      label: Text(action.label),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    )
                  : FloatingActionButton.small(
                      elevation: 0,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      tooltip: action.label,
                      onPressed: () => action.onPressed(context),
                      child: Icon(action.icon),
                    ),
            ],
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: user == null
                ? const SizedBox.shrink()
                : extended
                    ? SizedBox(
                        width: 216,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Avatar(initials: user.initials, size: 40),
                          title: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            user.isDoctor ? 'Doctor' : 'Patient',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            tooltip: 'Sign out',
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            onPressed: () => ref
                                .read(authControllerProvider.notifier)
                                .signOut(),
                          ),
                        ),
                      )
                    : Avatar(initials: user.initials, size: 40),
          ),
        ),
      ),
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon, color: AppColors.primary),
            label: Text(d.label),
          ),
      ],
    );
  }
}
