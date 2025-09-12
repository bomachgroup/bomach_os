import 'dart:developer';

import 'package:bms_front_end/main.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int selectedMenu = 0;
  int selectedSubMenu = -1;
  late final List<Map<String, dynamic>> menuItems;
  late final Map<String, Map<String, dynamic>> routeToMenuMapping;

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeRouteMapping();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionBasedOnCurrentRoute();
    });
  }

  void _initializeMenuItems() {
    menuItems = [
      {
        'index': 0,
        'label': 'Dashboard',
        'iconPath': 'assets/svg/sidebar/home.svg',
        'route': RouteConstants.home,
        'isExpandable': false,
        'children': [],
      },
      {
        'index': 1,
        'label': 'Company',
        'iconPath': 'assets/svg/sidebar/person-plus.svg',
        'isExpandable': true,
        'children': [
          {
            'index': 1,
            'label': 'Enugu',
            'route': RouteConstants.enugu,
          },
          {
            'index': 2,
            'label': 'Port Harcourt',
            'route': null,
          },
          {
            'index': 3,
            'label': 'Abuja',
            'route': null,
          },
        ],
      },
      {
        'index': 2,
        'label': 'HR',
        'iconPath': 'assets/svg/sidebar/people.svg',
        'isExpandable': true,
        'children': [
          {
            'index': 4,
            'label': 'Employees',
            'route': RouteConstants.employees,
          },
          {
            'index': 5,
            'label': 'Leaves',
            'route': RouteConstants.leaves,
          },
          {
            'index': 6,
            'label': 'Clients',
            'route': RouteConstants.clients,
          },
          {
            'index': 7,
            'label': 'Leads',
            'route': RouteConstants.leads,
          },
          {
            'index': 8,
            'label': 'Department',
            'route': RouteConstants.department,
          },
        ],
      },
      {
        'index': 3,
        'label': 'Work',
        'iconPath': 'assets/svg/sidebar/joined-square.svg',
        'isExpandable': true,
        'children': [
          {
            'index': 9,
            'label': 'Project',
            'route': RouteConstants.projects,
          },
          {
            'index': 10,
            'label': 'Worksite',
            'route': null,
          },
          {
            'index': 11,
            'label': 'Tasks',
            'route': RouteConstants.tasks,
          },
          {
            'index': 12,
            'label': 'Contracts',
            'route': RouteConstants.contracts,
          },
        ],
      },
      {
        'index': 4,
        'label': 'Finance',
        'iconPath': 'assets/svg/sidebar/naira.svg',
        'isExpandable': true,
        'children': [],
      },
      {
        'index': 5,
        'label': 'Calendar',
        'iconPath': 'assets/svg/sidebar/calendar.svg',
        'isExpandable': true,
        'children': [],
      },
      {
        'index': 6,
        'label': 'Services',
        'iconPath': 'assets/svg/sidebar/calendar.svg',
        'isExpandable': true,
        'children': [
          {
            'index': 13,
            'label': 'Service Order',
            'route': RouteConstants.serviceOrder,
          },
          {
            'index': 14,
            'label': 'Real Estate',
            'route': RouteConstants.realEstate,
          },
          {
            'index': 15,
            'label': 'Land Survey',
            'route': RouteConstants.landSurvey,
          },
          {
            'index': 16,
            'label': 'Services',
            'route': RouteConstants.services,
          },
        ],
      },
      {
        'index': 7,
        'label': 'Notification',
        'iconPath': 'assets/svg/sidebar/papar.svg',
        'route': null,
        'isExpandable': false,
        'children': [],
      },
      {
        'index': 8,
        'label': 'Settings',
        'iconPath': 'assets/svg/sidebar/settings.svg',
        'route': null,
        'isExpandable': false,
        'children': [],
      },
      {
        'index': 9,
        'label': 'Help',
        'iconPath': 'assets/svg/sidebar/help.svg',
        'route': null,
        'isExpandable': false,
        'children': [],
      },
      {
        'index': 10,
        'label': 'Logout',
        'iconPath': 'assets/svg/sidebar/logout.svg',
        'route': null,
        'isExpandable': false,
        'children': [],
      },
      {
        'index': 11,
        'label': 'Finance & Accounting',
        'iconPath': 'assets/svg/sidebar/joined-square.svg',
        'isExpandable': true,
        'children': [
          {
            'index': 17,
            'label': 'Dashboard',
            'route': RouteConstants.finance,
          },
          {
            'index': 18,
            'label': 'Invoice',
            'route': RouteConstants.invoice,
          },
          {
            'index': 19,
            'label': 'Payments',
            'route': RouteConstants.payment,
          },
          {
            'index': 20,
            'label': 'Expenses',
            'route': RouteConstants.expense,
          },
          {
            'index': 21,
            'label': 'Vendor/Contributor',
            'route': RouteConstants.contractPayment,
          },
        ],
      },
    ];
  }

  void _initializeRouteMapping() {
    routeToMenuMapping = {};

    // Process top-level routes
    for (var menuItem in menuItems) {
      if (!menuItem['isExpandable'] && menuItem['route'] != null) {
        routeToMenuMapping[menuItem['route']] = {
          'menuIndex': menuItem['index'],
          'subMenuIndex': -1,
        };
      }

      // Process sub-menu routes
      if (menuItem['isExpandable']) {
        for (var subMenuItem in menuItem['children']) {
          if (subMenuItem['route'] != null) {
            routeToMenuMapping[subMenuItem['route']] = {
              'menuIndex': menuItem['index'],
              'subMenuIndex': subMenuItem['index'],
            };
          }
        }
      }
    }

    log('Route Mapping Initialized: $routeToMenuMapping');
  }

  void _updateSelectionBasedOnCurrentRoute() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    log('Current Route: $currentRoute');

    // Find menu item for current route
    if (routeToMenuMapping.containsKey(currentRoute)) {
      final mapping = routeToMenuMapping[currentRoute]!;
      setState(() {
        selectedMenu = mapping['menuIndex'];
        selectedSubMenu = mapping['subMenuIndex'];
      });
      _saveMenuState(mapping['menuIndex'], mapping['subMenuIndex']);
      log('Menu selection updated based on route: menu=$selectedMenu, subMenu=$selectedSubMenu');
    } else {
      // If route is not found in mapping, load from preferences as fallback
      _loadMenuState();
    }
  }

  void _loadMenuState() {
    setState(() {
      selectedMenu = prefs.getInt('selectedMenu') ?? 0;
      selectedSubMenu = prefs.getInt('selectedSubMenu') ?? -1;
    });
    log('Menu state loaded from preferences: menu=$selectedMenu, subMenu=$selectedSubMenu');
  }

  Future<void> _saveMenuState(int menu, int subMenu) async {
    await prefs.setInt('selectedMenu', menu);
    await prefs.setInt('selectedSubMenu', subMenu);
    log('Menu state saved to preferences: menu=$menu, subMenu=$subMenu');
  }

  void _navigate(String? route, int menuIndex, int subMenuIndex) {
    if (route != null) {
      context.go(route);
    }

    setState(() {
      selectedMenu = menuIndex;
      selectedSubMenu = subMenuIndex;
    });

    _saveMenuState(menuIndex, subMenuIndex);

    if (!isLargeScreen(context)) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildMenuItem(Map<String, dynamic> menuItem) {
    final int index = menuItem['index'];
    final bool isExpandable = menuItem['isExpandable'];
    final String label = menuItem['label'];
    final String iconPath = menuItem['iconPath'];
    final String? route = menuItem['route'];
    final List<dynamic> children = menuItem['children'];

    final isSelected = selectedMenu == index;

    final icon = SvgPicture.asset(
      iconPath,
      colorFilter: ColorFilter.mode(
          isSelected ? AppColors.white : AppColors.black, BlendMode.srcIn),
    );

    final title = Text(
      label,
      style: isSelected ? AppText.sideMWhite_400_14 : AppText.black_400_14,
    );

    if (!isExpandable) {
      return NonExpandableSideBarItem(
        titleColor: isSelected ? AppColors.blue : Colors.transparent,
        icon: icon,
        title: title,
        onTap: () => _navigate(route, index, -1),
      );
    }

    return ExpandableSideBarItem(
      expandedTileController: ExpandedTileController(isExpanded: isSelected),
      titleColor: isSelected ? AppColors.blue : Colors.transparent,
      icon: icon,
      title: title,
      onTap: () {
        setState(() {
          selectedMenu = index;
        });
        _saveMenuState(index, selectedSubMenu);
      },
      children: children.map<Widget>((subMenuItem) {
        return _buildSubItem(subMenuItem);
      }).toList(),
    );
  }

  Widget _buildSubItem(Map<String, dynamic> subMenuItem) {
    final int index = subMenuItem['index'];
    final String label = subMenuItem['label'];
    final String? route = subMenuItem['route'];

    final isSelected = selectedSubMenu == index;

    return SubSideBarItems(
      title: Text(
        label,
        style: isSelected
            ? AppText.sideMBlueText_400_14
            : AppText.sideMText_300_14,
      ),
      isSelected: isSelected,
      onTap: () => _navigate(route, selectedMenu, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sideMenu,
      padding: const EdgeInsets.only(right: 16, left: 16),
      height: MediaQuery.sizeOf(context).height,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          kSizedBoxBG,
          const Row(
            children: [
              Text('BOMACH', style: AppText.black_500_20),
              Text('OS', style: AppText.black_500_32),
            ],
          ),
          const SizedBox(height: 24),
          ...menuItems.map((menuItem) => _buildMenuItem(menuItem)),
          kSizedBox,
        ],
      ),
    );
  }
}

class SubSideBarItems extends StatelessWidget {
  final Text title;
  final VoidCallback onTap;
  final bool isSelected;
  const SubSideBarItems({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: onTap,
      leading: Visibility(
          visible: isSelected,
          child: const CircleAvatar(
            backgroundColor: AppColors.blue,
            radius: 5,
          )),
      title: title,
    );
  }
}

class ExpandableSideBarItem extends StatelessWidget {
  final ExpandedTileController expandedTileController;
  final Widget title;
  final Color titleColor;
  final VoidCallback onTap;
  final Widget icon;
  final List<Widget> children;
  const ExpandableSideBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onTap,
    required this.titleColor,
    required this.expandedTileController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpandedTile(
        onTap: onTap,
        theme: ExpandedTileThemeData(
          footerBackgroundColor: Colors.transparent,
          headerPadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.only(top: 0),
          contentBackgroundColor: Colors.transparent,
          headerBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          headerColor: titleColor,
          headerSplashColor: Colors.transparent,
          contentSeparatorColor: Colors.transparent,
        ),
        title: title,
        leading: icon,
        content: Column(children: children),
        controller: expandedTileController,
        trailing: SvgPicture.asset(
          "assets/svg/arrow-ios-down.svg",
          colorFilter: ColorFilter.mode(
              expandedTileController.isExpanded
                  ? AppColors.white
                  : AppColors.black,
              BlendMode.srcIn),
        ),
        trailingRotation: 180,
      ),
    );
  }
}

class NonExpandableSideBarItem extends StatelessWidget {
  final Widget title;
  final VoidCallback onTap;
  final Color titleColor;
  final Widget icon;
  const NonExpandableSideBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: titleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        tileColor: titleColor,
        leading: icon,
        onTap: onTap,
        title: title,
      ),
    );
  }
}
