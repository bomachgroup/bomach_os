import 'package:bms_front_end/main.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
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

  void _loadMenuState() {
    selectedMenu = prefs.getInt('selectedMenu') ?? 0;
    selectedSubMenu = prefs.getInt('selectedSubMenu') ?? -1;
  }

  Future<void> _saveMenuState(int menu, int subMenu) async {
    await prefs.setInt('selectedMenu', menu);
    await prefs.setInt('selectedSubMenu', subMenu);
  }

  @override
  void initState() {
    super.initState();
    _loadMenuState();
  }

  Widget _buildMenuItem({
    required int index,
    required String label,
    required String iconPath,
    VoidCallback? onTap,
    List<Widget>? children,
    bool isExpandable = false,
  }) {
    final isSelected = selectedMenu == index;

    final icon = SvgPicture.asset(
      iconPath,
      // color: isSelected ? Colors.white : AppColors.blackColor,
      colorFilter: ColorFilter.mode(
          isSelected ? Colors.white : AppColors.blackColor, BlendMode.srcIn),
    );

    final title = Text(
      label,
      style: isSelected ? AppText.sideMWhite_400_14 : AppText.black_400_14,
    );

    if (!isExpandable) {
      return NonExpandableSideBarItem(
        titleColor: isSelected ? AppColors.blueColor : Colors.transparent,
        icon: icon,
        title: title,
        onTap: () {
          setState(() {
            selectedMenu = index;
            selectedSubMenu = -1;
          });
          _saveMenuState(index, -1);
          onTap?.call();
        },
      );
    }

    return ExpandableSideBarItem(
      expandedTileController: ExpandedTileController(isExpanded: isSelected),
      titleColor: isSelected ? AppColors.blueColor : Colors.transparent,
      icon: icon,
      title: title,
      onTap: () {
        setState(() {
          selectedMenu = index;
        });
        _saveMenuState(index, selectedSubMenu);
        onTap?.call();
      },
      children: children ?? [],
    );
  }

  Widget _buildSubItem({
    required int index,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedSubMenu == index;

    return SubSideBarItems(
      title: Text(
        label,
        style: isSelected
            ? AppText.sideMBlueText_400_14
            : AppText.sideMText_300_14,
      ),
      isSelected: isSelected,
      onTap: () {
        setState(() {
          selectedSubMenu = index;
        });
        _saveMenuState(selectedMenu, index);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sideMenuColor,
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
          _buildMenuItem(
            index: 0,
            label: 'Dashboard',
            iconPath: 'assets/svg/sidebar/home.svg',
            onTap: () => context.go(RouteConstants.home),
          ),
          _buildMenuItem(
            index: 1,
            label: 'Company',
            iconPath: 'assets/svg/sidebar/person-plus.svg',
            isExpandable: true,
            children: [
              _buildSubItem(
                index: 1,
                label: 'Enugu',
                onTap: () => context.go(RouteConstants.enugu),
              ),
              _buildSubItem(index: 2, label: 'Port Harcourt', onTap: () {}),
              _buildSubItem(index: 3, label: 'Abuja', onTap: () {}),
            ],
          ),
          _buildMenuItem(
            index: 2,
            label: 'HR',
            iconPath: 'assets/svg/sidebar/people.svg',
            isExpandable: true,
            children: [
              _buildSubItem(
                  index: 4,
                  label: 'Employees',
                  onTap: () => context.go(RouteConstants.employees)),
              _buildSubItem(
                  index: 5,
                  label: 'Leaves',
                  onTap: () => context.go(RouteConstants.leaves)),
              _buildSubItem(
                  index: 6,
                  label: 'Clients',
                  onTap: () => context.go(RouteConstants.clients)),
              _buildSubItem(
                  index: 7,
                  label: 'Leads',
                  onTap: () => context.go(RouteConstants.leads)),
              _buildSubItem(
                  index: 8,
                  label: 'Department',
                  onTap: () => context.go(RouteConstants.department)),
            ],
          ),
          _buildMenuItem(
            index: 3,
            label: 'Work',
            iconPath: 'assets/svg/sidebar/joined-square.svg',
            isExpandable: true,
            children: [
              _buildSubItem(
                  index: 9,
                  label: 'Project',
                  onTap: () => context.go(RouteConstants.projects)),
              _buildSubItem(index: 10, label: 'Worksite', onTap: () {}),
              _buildSubItem(
                  index: 11,
                  label: 'Tasks',
                  onTap: () => context.go(RouteConstants.tasks)),
              _buildSubItem(index: 12, label: 'Contracts', onTap: () {}),
            ],
          ),
          _buildMenuItem(
            index: 4,
            label: 'Finance',
            iconPath: 'assets/svg/sidebar/naira.svg',
            isExpandable: true,
          ),
          _buildMenuItem(
            index: 5,
            label: 'Calendar',
            iconPath: 'assets/svg/sidebar/calendar.svg',
            isExpandable: true,
          ),
          _buildMenuItem(
            index: 6,
            label: 'Services',
            iconPath: 'assets/svg/sidebar/calendar.svg',
            isExpandable: true,
          ),
          _buildMenuItem(
              index: 7,
              label: 'Notification',
              iconPath: 'assets/svg/sidebar/papar.svg',
              onTap: () {}),
          _buildMenuItem(
            index: 8,
            label: 'Settings',
            iconPath: 'assets/svg/sidebar/settings.svg',
            onTap: () {},
          ),
          // const Spacer(),
          kSizedBoxBG,
          kSizedBoxBG,
          _buildMenuItem(
            index: 9,
            label: 'Help',
            iconPath: 'assets/svg/sidebar/help.svg',
            onTap: () {},
          ),
          _buildMenuItem(
            index: 10,
            label: 'Logout',
            iconPath: 'assets/svg/sidebar/logout.svg',
            onTap: () {},
          ),
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
            backgroundColor: AppColors.blueColor,
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
    return ExpandedTile(
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
