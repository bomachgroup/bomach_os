import 'dart:developer';

import 'package:bomach_os/components/dialog/user_profile_dialog.dart';
import 'package:bomach_os/main.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/pages/company/controllers/broadcast_controller.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/app_routes/menu_structure.dart';
import 'package:bomach_os/src/app_routes/sidebar_prefs.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class SideMenu extends StatefulWidget {
  /// When true, the sidebar renders as a narrow icon-only rail with tooltips;
  /// labels, search, and section headers are hidden.
  final bool isCollapsed;

  /// Toggles between expanded and collapsed modes. Invoked from the in-sidebar
  /// toggle button (and from the \u2318K handler when the user triggers search
  /// on a collapsed rail — the rail expands first so the search field exists).
  final VoidCallback? onToggleCollapse;

  /// Uses the parent's bounded height (the Drawer on small/medium layouts)
  /// instead of the browser window height. This keeps the menu's ListView
  /// inside the drawer so pointer/touch scrolling cannot fall through to the
  /// page behind it.
  final bool useAvailableHeight;

  const SideMenu({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.useAvailableHeight = false,
  });

  static SideMenu of(BuildContext context) {
    final SideMenu? result = context.findAncestorWidgetOfExactType<SideMenu>();
    assert(result != null, 'No SideMenu found in context');
    return result!;
  }

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  MainMenuItem? selectedMainMenu;
  SubMenuItem? selectedSubMenu;

  /// Accordion state: the single expandable group that is currently open,
  /// or `null` when every group is collapsed. Search mode overrides this
  /// (all groups with matches open) via the build-time `isOpen` calc.
  MainMenuItem? _openMenu;
  List<MenuItem> get menuItems =>
      sidebarStructure.expand((s) => s.items).toList();
  late final Map<String, MenuSelection> routeToMenuMapping;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'sidebar-search');
  final ScrollController _scrollController = ScrollController();
  final Map<MainMenuItem, GlobalKey> _menuKeys = {};
  String _searchQuery = '';

  /// Pinned sub-items (e.g. "Employees", "Leave Requests"). Rendered as a
  /// "Pinned" section at the top of the expanded sidebar in addition to
  /// their natural position under the parent group.
  final Set<SubMenuItem> _pinnedSubs = <SubMenuItem>{};

  /// Pinned top-level items (e.g. "Events") — same idea, for non-expandable
  /// entries.
  final Set<MainMenuItem> _pinnedMains = <MainMenuItem>{};

  @override
  void initState() {
    super.initState();
    _initializeRouteMapping();
    _loadPinned();
    // Register a global shortcut so \u2318K / Ctrl+K focuses the sidebar
    // search from anywhere in the app (no matter which page or field is
    // focused). HardwareKeyboard fires before any widget-level handlers.
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionBasedOnCurrentRoute();
    });
  }

  void _loadPinned() {
    final subs = prefs.getStringList('sidebarPinnedSubs') ?? const <String>[];
    for (final s in subs) {
      final i = int.tryParse(s);
      if (i != null && i >= 0 && i < SubMenuItem.values.length) {
        _pinnedSubs.add(SubMenuItem.values[i]);
      }
    }
    final mains = prefs.getStringList('sidebarPinnedMains') ?? const <String>[];
    for (final s in mains) {
      final i = int.tryParse(s);
      if (i != null && i >= 0 && i < MainMenuItem.values.length) {
        _pinnedMains.add(MainMenuItem.values[i]);
      }
    }
  }

  Future<void> _savePinned() async {
    await prefs.setStringList(
      'sidebarPinnedSubs',
      _pinnedSubs.map((e) => e.index.toString()).toList(),
    );
    await prefs.setStringList(
      'sidebarPinnedMains',
      _pinnedMains.map((e) => e.index.toString()).toList(),
    );
  }

  void _togglePinSub(SubMenuItem id) {
    setState(() {
      if (_pinnedSubs.contains(id)) {
        _pinnedSubs.remove(id);
      } else {
        _pinnedSubs.add(id);
      }
    });
    _savePinned();
  }

  void _togglePinMain(MainMenuItem id) {
    setState(() {
      if (_pinnedMains.contains(id)) {
        _pinnedMains.remove(id);
      } else {
        _pinnedMains.add(id);
      }
    });
    _savePinned();
  }

  /// Show the pin/unpin context menu at [globalPos] for a row.
  Future<void> _showRowContextMenu({
    required Offset globalPos,
    required bool isPinned,
    required VoidCallback onToggle,
  }) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final position = RelativeRect.fromLTRB(
      globalPos.dx,
      globalPos.dy,
      overlay.size.width - globalPos.dx,
      overlay.size.height - globalPos.dy,
    );
    final result = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'toggle',
          height: 36,
          child: Row(
            children: [
              Icon(
                isPinned ? Iconsax.bookmark_2 : Iconsax.bookmark,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(isPinned ? 'Unpin from top' : 'Pin to top'),
            ],
          ),
        ),
      ],
    );
    if (result == 'toggle') onToggle();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Global key filter. Catches \u2318K on macOS, Ctrl+K on Windows/Linux/web
  /// and focuses the sidebar search. Returns `true` to consume the event so
  /// the browser's default "open location" binding doesn't fire.
  bool _handleGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isK = event.logicalKey == LogicalKeyboardKey.keyK;
    final hasMod = HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    if (isK && hasMod) {
      // If the rail is collapsed, expand it first so the search field has
      // somewhere to render. Defer focus until the expansion animation has
      // laid out the new widget.
      if (widget.isCollapsed && widget.onToggleCollapse != null) {
        widget.onToggleCollapse!();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
          _searchCtrl.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _searchCtrl.text.length,
          );
        });
      } else {
        _searchFocusNode.requestFocus();
        _searchCtrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchCtrl.text.length,
        );
      }
      return true;
    }
    return false;
  }

  /// Applies [_searchQuery] to the given menu item. Returns null when the
  /// item (and none of its children) match; otherwise returns a menu item
  /// whose children are filtered down to the matches.
  MenuItem? _filterForSearch(MenuItem item) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return item;

    final labelHit = item.label.toLowerCase().contains(q);
    if (!item.isExpandable) {
      return labelHit ? item : null;
    }

    // If the parent label matches, show all children.
    if (labelHit) return item;

    final matchingChildren =
        item.children.where((c) => c.label.toLowerCase().contains(q)).toList();
    if (matchingChildren.isEmpty) return null;

    return MenuItem(
      id: item.id,
      label: item.label,
      icon: item.icon,
      route: item.route,
      resources: item.resources,
      isExpandable: item.isExpandable,
      children: matchingChildren,
    );
  }

  void _initializeRouteMapping() {
    routeToMenuMapping = {};

    // Process top-level routes
    for (var menuItem in menuItems) {
      if (!menuItem.isExpandable && menuItem.route != null) {
        routeToMenuMapping[menuItem.route!] = MenuSelection(
          mainMenuItem: menuItem.id,
          subMenuItem: null,
        );
      }

      // Process sub-menu routes
      if (menuItem.isExpandable) {
        for (var subMenuItem in menuItem.children) {
          if (subMenuItem.route != null) {
            routeToMenuMapping[subMenuItem.route!] = MenuSelection(
              mainMenuItem: menuItem.id,
              subMenuItem: subMenuItem.id,
            );
          }
        }
      }
    }

    // log('Route Mapping Initialized: $routeToMenuMapping');
  }

  void _updateSelectionBasedOnCurrentRoute() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    log('Current Route: $currentRoute');

    // Find menu item for current route
    if (routeToMenuMapping.containsKey(currentRoute)) {
      final selection = routeToMenuMapping[currentRoute]!;
      setState(() {
        selectedMainMenu = selection.mainMenuItem;
        selectedSubMenu = selection.subMenuItem;
        // Auto-open the group whose child owns the active route, so a deep
        // link or back/forward navigation lands with the right tab expanded.
        if (selection.subMenuItem != null) {
          _openMenu = selection.mainMenuItem;
        }
      });
      _saveMenuState(selection.mainMenuItem, selection.subMenuItem);
      _saveOpenMenu(_openMenu);
      log('Menu selection updated based on route: main=$selectedMainMenu, sub=$selectedSubMenu');
    } else {
      // If route is not found in mapping, load from preferences as fallback
      _loadMenuState();
    }
  }

  void _loadMenuState() {
    final mainMenuIndex = prefs.getInt('selectedMenu');
    final subMenuIndex = prefs.getInt('selectedSubMenu');
    final openMenuIndex = prefs.getInt('sidebarOpenMenu');

    setState(() {
      // Audit B13 fix: bound-check every restored ordinal via the shared
      // helpers — a stale index after an enum reorder used to throw.
      selectedMainMenu =
          safeMainIndex(mainMenuIndex) ?? MainMenuItem.dashboard;
      selectedSubMenu = safeSubIndex(subMenuIndex);
      // Restore accordion state: prefer the saved open group; fall back to
      // the parent of the selected sub-item so a first-time user with no
      // saved pref still lands with the right group expanded.
      final restoredOpen = safeMainIndex(openMenuIndex);
      if (restoredOpen != null) {
        _openMenu = restoredOpen;
      } else if (selectedSubMenu != null) {
        _openMenu = selectedMainMenu;
      }
    });
    log('Menu state loaded from preferences: main=$selectedMainMenu, sub=$selectedSubMenu, open=$_openMenu');
  }

  Future<void> _saveMenuState(
      MainMenuItem mainMenu, SubMenuItem? subMenu) async {
    await prefs.setInt('selectedMenu', mainMenu.index);
    await prefs.setInt('selectedSubMenu', subMenu?.index ?? -1);
    log('Menu state saved to preferences: main=$mainMenu, sub=$subMenu');
  }

  /// Persist the currently-open accordion group (or `null` if everything is
  /// collapsed) so the sidebar reopens with the same group after a restart.
  Future<void> _saveOpenMenu(MainMenuItem? openMenu) async {
    await prefs.setInt('sidebarOpenMenu', openMenu?.index ?? -1);
  }

  void _navigate(
      String? route, MainMenuItem mainMenuItem, SubMenuItem? subMenuItem) {
    if (route != null) {
      context.go(route);
    }

    setState(() {
      selectedMainMenu = mainMenuItem;
      selectedSubMenu = subMenuItem;
      // Tapping a child implies its parent group should stay open (matters
      // when the tap originated from search mode, where _openMenu may still
      // be pointing at a different group).
      if (subMenuItem != null) {
        _openMenu = mainMenuItem;
        _saveOpenMenu(_openMenu);
      }
    });

    _saveMenuState(mainMenuItem, subMenuItem);

    if (!isLargeScreen(context)) {
      Navigator.of(context).pop();
    }
  }

  void _scrollToItem(MainMenuItem id) {
    // Use a slight delay to allow the layout to settle after the previous
    // module starts collapsing, ensuring we calculate the correct scroll target.
    Future.delayed(const Duration(milliseconds: 150), () {
      final key = _menuKeys[id];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
          alignment: 0.0, // Aim for the top of the sidebar
        );
      }
    });
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    final permissionService = Get.find<PermissionService>();

    // Super admin / CEO sees the company dashboard instead of the employee
    // dashboard. Hide the employee Dashboard menu for them.
    if (menuItem.id == MainMenuItem.dashboard &&
        (permissionService.isSuperAdmin ||
            permissionService.hasAnyPermissionForResource(
                PermissionConstants.resCompanySettings))) {
      return const SizedBox.shrink();
    }

    // Filter sub-items via typed route permissions.
    final authorizedSubItems = menuItem.children
        .where((subItem) =>
            permissionService.canAccessRoute(subItem.route, subItem.resources))
        .toList();

    if (menuItem.isExpandable && authorizedSubItems.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!menuItem.isExpandable &&
        !permissionService.canAccessResources(menuItem.resources)) {
      return const SizedBox.shrink();
    }

    final bool isSelected = selectedMainMenu == menuItem.id;

    if (!menuItem.isExpandable) {
      final bool isPinned = _pinnedMains.contains(menuItem.id);
      return _MenuRow(
        icon: menuItem.icon,
        label: menuItem.label,
        isSelected: isSelected,
        isPinned: isPinned,
        onTap: () => _navigate(menuItem.route, menuItem.id, null),
        onContextMenu: (pos) => _showRowContextMenu(
          globalPos: pos,
          isPinned: isPinned,
          onToggle: () => _togglePinMain(menuItem.id),
        ),
      );
    }

    // Search mode overrides accordion: every group with matches stays open
    // so the user can see all hits at once. When search is cleared, the
    // normal single-open accordion rule resumes.
    final bool isOpen =
        _searchQuery.trim().isNotEmpty ? true : _openMenu == menuItem.id;

    return _ExpandableMenuRow(
      key: ValueKey('exp-${menuItem.id.name}'),
      icon: menuItem.icon,
      label: menuItem.label,
      isSelected: isSelected,
      isOpen: isOpen,
      searchQuery: _searchQuery,
      onHeaderTap: () {
        setState(() {
          if (_openMenu == menuItem.id) {
            _openMenu = null;
          } else {
            selectedMainMenu = menuItem.id;
            _openMenu = menuItem.id;

            // Automatically navigate to the first authorized child
            if (authorizedSubItems.isNotEmpty) {
              final firstChild = authorizedSubItems.first;
              _navigate(firstChild.route, menuItem.id, firstChild.id);
            }

            // Scroll to the newly opened module so it's fully in view
            _scrollToItem(menuItem.id);
          }
        });

        _saveMenuState(menuItem.id, selectedSubMenu);
        _saveOpenMenu(_openMenu);
      },
      onExpand: () {
        if (!isOpen) {
          setState(() => _openMenu = menuItem.id);
          _saveOpenMenu(_openMenu);
        } else {
          // If already open, Right arrow moves focus to the first child.
          FocusScope.of(context).nextFocus();
        }
      },
      onCollapse: () {
        if (isOpen) {
          setState(() => _openMenu = null);
          _saveOpenMenu(_openMenu);
        }
      },
      headerKey: _menuKeys.putIfAbsent(menuItem.id, () => GlobalKey()),
      children: authorizedSubItems
          .map<Widget>((subItem) => _buildSubItem(subItem, menuItem.id))
          .toList(),
    );
  }

  /// Render a pinned non-expandable top-level item in the Pinned section.
  /// Always full-size (not the sub-item treatment) and marks itself selected
  /// when its route is active.
  Widget _buildPinnedMainRow(MenuItem menuItem) {
    final isSelected = selectedMainMenu == menuItem.id;
    return _MenuRow(
      key: ValueKey('pinned-main-${menuItem.id.name}'),
      icon: menuItem.icon,
      label: menuItem.label,
      isSelected: isSelected,
      isPinned: true,
      onTap: () => _navigate(menuItem.route, menuItem.id, null),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: true,
        onToggle: () => _togglePinMain(menuItem.id),
      ),
    );
  }

  /// Render a pinned sub-item in the Pinned section. Uses the top-level
  /// visual weight (not `isSub: true`) because the pin appears in its own
  /// section, not nested under a parent group.
  Widget _buildPinnedSubRow(SubMenuItemData sub, MainMenuItem parentId) {
    final isSelected = selectedSubMenu == sub.id;
    return _MenuRow(
      key: ValueKey('pinned-sub-${sub.id.name}'),
      icon: sub.icon,
      label: sub.label,
      isSelected: isSelected,
      isPinned: true,
      onTap: () => _navigate(sub.route, parentId, sub.id),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: true,
        onToggle: () => _togglePinSub(sub.id),
      ),
    );
  }

  Widget _buildSubItem(
      SubMenuItemData subMenuItem, MainMenuItem parentMenuItem) {
    final isSelected = selectedSubMenu == subMenuItem.id;
    final bool isPinned = _pinnedSubs.contains(subMenuItem.id);
    return _MenuRow(
      icon: subMenuItem.icon,
      label: subMenuItem.label,
      isSelected: isSelected,
      isSub: true,
      isPinned: isPinned,
      searchQuery: _searchQuery,
      onTap: () => _navigate(subMenuItem.route, parentMenuItem, subMenuItem.id),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: isPinned,
        onToggle: () => _togglePinSub(subMenuItem.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      // Expanded mode: right padding only, so selected-row accent bars sit
      // flush with the left edge. Collapsed mode: horizontal padding hugs the
      // centered rail buttons.
      padding: widget.isCollapsed
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.only(right: 8),
      height: widget.useAvailableHeight
          ? double.infinity
          : MediaQuery.sizeOf(context).height,
      child: Obx(() {
        // Subscribe to permission changes so the menu rebuilds on role changes.
        // ignore: unused_local_variable
        final _ = Get.find<PermissionService>().version;

        final filtered =
            menuItems.map(_filterForSearch).whereType<MenuItem>().toList();

        return Column(
          children: [
            // FIXED HEADER: Brand + Search (responsive)
            _buildFixedHeader(),

            // SCROLLABLE CONTENT with polished scrollbar
            Expanded(
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: 4,
                  radius: const Radius.circular(8),
                  child: ListView(
                    controller: _scrollController,
                    primary: false,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    children: widget.isCollapsed
                        ? _buildRailItems(filtered)
                        : _buildExpandedItems(filtered),
                  ),
                ),
              ),
            ),

            // FIXED FOOTER: Account Card (responsive)
            _AccountCard(isCollapsed: widget.isCollapsed),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  List<Widget> _buildRailItems(List<MenuItem> filtered) {
    final permissionService = Get.find<PermissionService>();
    final items = <Widget>[];

    for (final menuItem in filtered) {
      if (menuItem.id == MainMenuItem.dashboard &&
          (permissionService.isSuperAdmin ||
              permissionService.hasAnyPermissionForResource(
                  PermissionConstants.resCompanySettings))) {
        continue;
      }

      if (menuItem.isExpandable) {
        final authorizedSubItems = menuItem.children
            .where(
                (s) => permissionService.canAccessRoute(s.route, s.resources))
            .toList();
        if (authorizedSubItems.isEmpty) continue;
      } else if (!permissionService.canAccessResources(menuItem.resources)) {
        continue;
      }

      final isSelected = selectedMainMenu == menuItem.id;
      items.add(_CollapsedMenuButton(
        icon: menuItem.icon,
        label: menuItem.label,
        isSelected: isSelected,
        onTap: () {
          if (menuItem.isExpandable) {
            final authorizedSubItems = menuItem.children
                .where((s) =>
                    permissionService.canAccessRoute(s.route, s.resources))
                .toList();

            setState(() {
              selectedMainMenu = menuItem.id;
              _openMenu = menuItem.id;
            });

            if (authorizedSubItems.isNotEmpty) {
              final firstChild = authorizedSubItems.first;
              _navigate(firstChild.route, menuItem.id, firstChild.id);
            }

            _saveMenuState(menuItem.id, selectedSubMenu);
            _saveOpenMenu(_openMenu);
            widget.onToggleCollapse?.call();
          } else {
            _navigate(menuItem.route, menuItem.id, null);
          }
        },
      ));
    }
    return items;
  }

  List<Widget> _buildExpandedItems(List<MenuItem> filtered) {
    final rows = <Widget>[];
    final permissionService = Get.find<PermissionService>();

    // ── Pinned section ──
    final bool pinnedSectionVisible = _searchQuery.trim().isEmpty &&
        (_pinnedSubs.isNotEmpty || _pinnedMains.isNotEmpty);
    if (pinnedSectionVisible) {
      rows.add(const _SectionHeader(label: 'Pinned', showDivider: false));
      for (final menuItem in menuItems) {
        // Audit B9 fix: pinned rows go through the SAME visibility
        // predicate as regular rows — pins used to bypass permissions.
        final visible = shouldShowMenuItem(
          menuItem,
          isSuperAdmin: permissionService.isSuperAdmin,
          hasCompanySettings: permissionService.hasAnyPermissionForResource(
              PermissionConstants.resCompanySettings),
          canAccess: permissionService.canAccessRoute,
        );
        if (!visible) continue;

        if (_pinnedMains.contains(menuItem.id) && !menuItem.isExpandable) {
          rows.add(_buildPinnedMainRow(menuItem));
        }
        if (menuItem.isExpandable) {
          for (final sub in menuItem.children) {
            if (_pinnedSubs.contains(sub.id) &&
                permissionService.canAccessRoute(sub.route, sub.resources)) {
              rows.add(_buildPinnedSubRow(sub, menuItem.id));
            }
          }
        }
      }
    }

    // ── Regular sections ──
    bool firstSectionSeen = pinnedSectionVisible;
    for (final section in sidebarStructure) {
      final sectionItems =
          section.items.map(_filterForSearch).whereType<MenuItem>().where((m) {
        if (m.isExpandable) {
          return m.children.any(
              (s) => permissionService.canAccessRoute(s.route, s.resources));
        }
        return permissionService.canAccessRoute(m.route, m.resources);
      }).toList();

      if (sectionItems.isNotEmpty) {
        final firstItem = sectionItems.first;
        rows.add(_SectionHeader(
          label: section.label,
          showDivider: firstSectionSeen,
          onTap: () {
            if (firstItem.isExpandable) {
              final subItems = firstItem.children
                  .where((s) =>
                      permissionService.canAccessRoute(s.route, s.resources))
                  .toList();
              if (subItems.isNotEmpty) {
                final firstSub = subItems.first;
                _navigate(firstSub.route, firstItem.id, firstSub.id);
                setState(() => _openMenu = firstItem.id);
              }
            } else {
              _navigate(firstItem.route, firstItem.id, null);
            }
          },
        ));
        firstSectionSeen = true;
        for (final item in sectionItems) {
          rows.add(_buildMenuItem(item));
        }
      }
    }

    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No menu items match "$_searchQuery"',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildFixedHeader() {
    if (widget.isCollapsed) {
      return Column(
        children: [
          kSizedBoxBG,
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'B',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.onToggleCollapse != null) ...[
            IconButton(
              icon: const Icon(Iconsax.notification,
                  size: 18, color: AppColors.textSecondary),
              onPressed: () {
                Get.find<BroadcastController>().currentTab.value =
                    'Notifications';
                context.go(RouteConstants.broadcast);
              },
              splashRadius: 18,
            ),
            const SizedBox(height: 4),
            IconButton(
              icon: const Icon(Iconsax.sidebar_right,
                  size: 18, color: AppColors.textSecondary),
              onPressed: widget.onToggleCollapse,
              splashRadius: 18,
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.neutral200),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        kSizedBoxBG,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              // Unified Brand wordmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'BOMACH',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'OS',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.notification,
                    size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  Get.find<BroadcastController>().currentTab.value =
                      'Notifications';
                  context.go(RouteConstants.broadcast);
                },
                splashRadius: 18,
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              if (widget.onToggleCollapse != null)
                Tooltip(
                  message: 'Collapse sidebar',
                  child: IconButton(
                    icon: const Icon(Iconsax.sidebar_left,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: widget.onToggleCollapse,
                    splashRadius: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SidebarSearchField(
            controller: _searchCtrl,
            focusNode: _searchFocusNode,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SidebarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SidebarSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Show the platform-appropriate shortcut hint so users discover \u2318K / Ctrl+K.
    final bool isMac = Theme.of(context).platform == TargetPlatform.macOS;
    final String shortcutHint = isMac ? '\u2318K' : 'Ctrl K';

    return CallbackShortcuts(
      // Handle Escape *only* while the search field owns focus. If there's
      // text, clear it; otherwise unfocus so Escape does the expected thing
      // for an empty search field too.
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (controller.text.isNotEmpty) {
            controller.clear();
            onChanged('');
          } else {
            focusNode.unfocus();
          }
        },
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.neutral500,
          ),
          prefixIcon: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.neutral500),
          suffixIcon: controller.text.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        shortcutHint,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Iconsax.close_circle, size: 16),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

// Helper class for menu selection
class MenuSelection {
  final MainMenuItem mainMenuItem;
  final SubMenuItem? subMenuItem;

  const MenuSelection({
    required this.mainMenuItem,
    this.subMenuItem,
  });

  @override
  String toString() {
    return 'MenuSelection(main: $mainMenuItem, sub: $subMenuItem)';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar row widgets — Pass 1 visual redesign
//
// One canonical row (`_MenuRow`) drives both top-level and sub-level items.
// Selected state = [primarySubtle] fill + [primary] accent bar flush-left +
// [primary]-colored icon/label. Hover state = [neutral200] fill. Transparent
// when neither — so the row sits quietly against the [surfaceMuted] sidebar
// background.
// ─────────────────────────────────────────────────────────────────────────────

/// A single interactive row in the sidebar. Handles hover + selected states
/// with a flush-left accent bar and rounded-right fill.
class _MenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isSub;
  final VoidCallback onTap;
  final Widget? trailing;

  /// Whether this row represents a currently-pinned item. Pinned rows get a
  /// small bookmark indicator in the trailing area (when no custom trailing
  /// is supplied).
  final bool isPinned;

  /// Right-click / long-press callback. Receives the global tap position so
  /// the caller can open a context menu anchored to the cursor.
  final ValueChanged<Offset>? onContextMenu;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final String searchQuery;

  const _MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSub = false,
    this.trailing,
    this.isPinned = false,
    this.onContextMenu,
    this.onExpand,
    this.onCollapse,
    this.searchQuery = '',
  });

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected;

    final Color bg = selected
        ? AppColors.primarySoft
        : (_hover || _focused ? AppColors.neutral200 : Colors.transparent);

    final Color accent = selected ? AppColors.primary : Colors.transparent;

    // Focus ring color. Always 1 px wide (even when transparent) so the row
    // height never jitters as focus moves between rows.
    // If selected, we use a slightly different color or just keep the ring.
    final Color ringColor = _focused ? AppColors.primary : Colors.transparent;

    final Color iconColor = selected
        ? AppColors.primary
        : (widget.isSub ? AppColors.textSecondary : AppColors.textPrimary);

    final Color labelColor = selected
        ? AppColors.primary
        : (widget.isSub ? AppColors.textSecondary : AppColors.textPrimary);

    final double iconSize = widget.isSub ? 16 : 20;
    final double height = widget.isSub ? 36 : 40;
    final double accentWidth = widget.isSub ? 2 : 3;
    // Sub-rows indent further so the hierarchy reads at a glance.
    final double leadingPad = widget.isSub ? 28 : 12;

    // Trailing widget: caller-supplied trailing takes precedence (used by
    // expandable rows for the chevron). Otherwise, pinned rows get a quiet
    // bookmark glyph so pinned state is visible at a glance.
    final Widget? trailing = widget.trailing ??
        (widget.isPinned
            ? const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Iconsax.bookmark_2,
                  size: 12,
                  color: AppColors.neutral400,
                ),
              )
            : null);

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // Enter / Space → activate the row, matching tap behaviour.
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          widget.onTap();
          return KeyEventResult.handled;
        }

        // Right Arrow → Expand if a callback is provided.
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (widget.onExpand != null) {
            widget.onExpand!();
            return KeyEventResult.handled;
          }
        }

        // Left Arrow → Collapse if a callback is provided.
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (widget.onCollapse != null) {
            widget.onCollapse!();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          // Right-click (desktop / web) and long-press (touch) both surface
          // the same context menu — the caller receives the global position
          // so the menu can anchor to the cursor.
          onSecondaryTapDown: widget.onContextMenu == null
              ? null
              : (d) => widget.onContextMenu!(d.globalPosition),
          onLongPressStart: widget.onContextMenu == null
              ? null
              : (d) => widget.onContextMenu!(d.globalPosition),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(8),
              ),
            ),
            child: Stack(
              children: [
                // Left accent bar for selected state
                if (selected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: accentWidth,
                      color: accent,
                    ),
                  ),
                // Focus ring on all sides. Border.all is uniform, so it
                // won't conflict with the borderRadius.
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ringColor,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Content row
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: leadingPad, right: 12),
                    child: Row(
                      children: [
                        Icon(widget.icon, size: iconSize, color: iconColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLabel(labelColor),
                        ),
                        if (trailing != null) trailing,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(Color color) {
    final style = TextStyle(
      fontSize: widget.isSub ? 13 : 14,
      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
      color: color,
    );

    if (widget.searchQuery.trim().isEmpty) {
      return Text(
        widget.label,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final String label = widget.label;
    final String query = widget.searchQuery.toLowerCase();
    final int matchIdx = label.toLowerCase().indexOf(query);

    if (matchIdx == -1) {
      return Text(
        label,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: label.substring(0, matchIdx)),
          TextSpan(
            text: label.substring(matchIdx, matchIdx + query.length),
            style: style.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          TextSpan(text: label.substring(matchIdx + query.length)),
        ],
      ),
    );
  }
}

/// A two-level menu group: a [_MenuRow] header with a rotating chevron, plus
/// an [AnimatedCrossFade]-toggled column of child rows.
///
/// Fully controlled — [isOpen] comes from the parent so the sidebar can
/// enforce a single-open accordion across all groups.
class _ExpandableMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isOpen;
  final VoidCallback onHeaderTap;
  final List<Widget> children;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final String searchQuery;
  final GlobalKey? headerKey;

  const _ExpandableMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isOpen,
    required this.onHeaderTap,
    required this.children,
    this.onExpand,
    this.onCollapse,
    this.searchQuery = '',
    this.headerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuRow(
          key: headerKey,
          icon: icon,
          label: label,
          isSelected: isSelected,
          onTap: onHeaderTap,
          onExpand: onExpand,
          onCollapse: onCollapse,
          trailing: AnimatedRotation(
            turns: isOpen ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState:
              isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          secondChild: const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

/// Quiet section label between sidebar groups. Renders an optional top
/// divider, then an uppercase caption in [neutral500].
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.label,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hide section headers in collapsed mode for a clean rail
    if (SideMenu.of(context).isCollapsed) {
      return showDivider
          ? const SizedBox(height: 24)
          : const SizedBox(height: 4);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDivider)
            const SizedBox(height: 24),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-only button rendered in the collapsed rail. Shows a tooltip with the
/// row's label on hover and handles selection / hover fills consistent with
/// the expanded [_MenuRow] treatment.
class _CollapsedMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CollapsedMenuButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CollapsedMenuButton> createState() => _CollapsedMenuButtonState();
}

class _CollapsedMenuButtonState extends State<_CollapsedMenuButton> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected;

    // Focus ring colour. Always 1 px wide (even when transparent) so the button
    // doesn't jitter during focus changes.

    final Color bg = selected
        ? AppColors.primarySoft
        : (_hover || _focused ? AppColors.neutral200 : Colors.transparent);

    final Color iconColor =
        selected ? AppColors.primary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Tooltip(
          message: widget.label,
          waitDuration: const Duration(milliseconds: 400),
          preferBelow: false,
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                widget.onTap();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: selected || _focused
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, size: 20, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final bool isCollapsed;
  const _AccountCard({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final user = auth.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final name = user.firstName.isEmpty && user.lastName.isEmpty
          ? user.username
          : '${user.firstName} ${user.lastName}';
      // Audit B7 fix: neutral fallback instead of the misleading
      // 'Super Admin' label for users without an employment type.
      final role = resolveRoleLabel(user.employmentType);

      if (isCollapsed) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (c) => UserProfileDialog(user: user),
              );
            },
            hoverColor: AppColors.neutral100,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Tooltip(
                  message: name,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: user.profilePicture != null &&
                            user.profilePicture!.isNotEmpty
                        ? NetworkImage(user.profilePicture!)
                        : null,
                    child: user.profilePicture == null ||
                            user.profilePicture!.isEmpty
                        ? Text(
                            (user.firstName.isNotEmpty
                                    ? user.firstName[0]
                                    : user.username.isNotEmpty
                                        ? user.username[0]
                                        : '?')
                                .toUpperCase(),
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          const Divider(height: 1, color: AppColors.neutral200),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (c) => UserProfileDialog(user: user),
                );
              },
              hoverColor: AppColors.neutral100,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: user.profilePicture != null &&
                              user.profilePicture!.isNotEmpty
                          ? NetworkImage(user.profilePicture!)
                          : null,
                      child: user.profilePicture == null ||
                              user.profilePicture!.isEmpty
                          ? Text(
                              (user.firstName.isNotEmpty
                                      ? user.firstName[0]
                                      : user.username.isNotEmpty
                                          ? user.username[0]
                                          : '?')
                                  .toUpperCase(),
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            role,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Removed _showAccountMenu and _buildPopupItem as they are no longer needed.
}
