import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
  });

  @override
  State<SideMenu> createState() => _SideMenueState();
}

class _SideMenueState extends State<SideMenu> {
  int sideMenueSelectedState = 0;
  int subMenueSelectedState = -1;
  // final ExpandedTileController _expandedTileController =ExpandedTileController();
  @override
  Widget build(BuildContext context) {
    return Container(
      key: GlobalKey(),
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.only(right: 16, left: 16, top: 48, bottom: 16),
      color: AppColors.sideMenuColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'BOMACH',
                  style: AppText.black_500_20,
                ),
                Text(
                  'OS',
                  style: AppText.black_500_32,
                ),
              ],
            ),
            NonExpandableSideBarItem(
              titleColor: sideMenueSelectedState == 0
                  ? AppColors.buttonColor
                  : Colors.transparent,
              title: Text(
                'Dashboard',
                style: sideMenueSelectedState == 0
                    ? AppText.sideMWhite_400_14
                    : AppText.black_400_14,
              ),
              icon: Image.asset(
                'assets/icons/galaryIcon.png',
                color: sideMenueSelectedState == 0
                    ? Colors.white
                    : AppColors.blackColor,
              ),
              onTap: () {
                context.go(RouteConstants.home);
                setState(() {
                  sideMenueSelectedState = 0;
                });
              },
            ),
            ExpandableSideBarItem(
                titleColor: sideMenueSelectedState == 1
                    ? AppColors.buttonColor
                    : Colors.transparent,
                title: Text(
                  'Company',
                  style: sideMenueSelectedState == 1
                      ? AppText.sideMWhite_400_14
                      : AppText.black_400_14,
                ),
                onTap: () {
                  setState(() {
                    sideMenueSelectedState = 1;
                  });
                },
                icon: Image.asset(
                  'assets/icons/company.png',
                  color: sideMenueSelectedState == 1
                      ? Colors.white
                      : AppColors.blackColor,
                ),
                expandedTileController: ExpandedTileController(
                    isExpanded: sideMenueSelectedState == 1),
                children: [
                  SubSideBarItems(
                    title: Text(
                      'Enugu',
                      style: subMenueSelectedState == 1
                          ? AppText.sideMBlueText_400_14
                          : AppText.sideMText_300_14,
                    ),
                    onTap: () {
                      context.go(RouteConstants.enugu);
                      setState(() {
                        subMenueSelectedState = 1;
                      });
                    },
                    isSelected: subMenueSelectedState == 1,
                  ),
                  SubSideBarItems(
                    title: Text(
                      'Port Harcourt',
                      style: subMenueSelectedState == 2
                          ? AppText.sideMBlueText_400_14
                          : AppText.sideMText_300_14,
                    ),
                    onTap: () {},
                    isSelected: subMenueSelectedState == 2,
                  ),
                  SubSideBarItems(
                    title: Text(
                      'Abuja',
                      style: subMenueSelectedState == 3
                          ? AppText.sideMBlueText_400_14
                          : AppText.sideMText_300_14,
                    ),
                    onTap: () {},
                    isSelected: subMenueSelectedState == 3,
                  ),
                ]),
            ExpandableSideBarItem(
              expandedTileController: ExpandedTileController(
                  isExpanded: sideMenueSelectedState == 2),
              titleColor: sideMenueSelectedState == 2
                  ? AppColors.buttonColor
                  : Colors.transparent,
              title: Text(
                'HR',
                style: sideMenueSelectedState == 2
                    ? AppText.sideMWhite_400_14
                    : AppText.black_400_14,
              ),
              onTap: () {
                setState(() {
                  sideMenueSelectedState = 2;
                });
              },
              icon: Image.asset(
                'assets/icons/Clients.png',
                color: sideMenueSelectedState == 2
                    ? Colors.white
                    : AppColors.blackColor,
              ),
              children: [
                SubSideBarItems(
                  title: Text(
                    'Employees',
                    style: subMenueSelectedState == 4
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    context.go(RouteConstants.employees);
                    setState(() {
                      subMenueSelectedState = 4;
                    });
                  },
                  isSelected: subMenueSelectedState == 4,
                ),
                SubSideBarItems(
                  title: Text(
                    'Leaves',
                    style: subMenueSelectedState == 5
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    context.go(
                      RouteConstants.addEmployees,
                    );
                    setState(() {
                      subMenueSelectedState = 5;
                    });
                  },
                  isSelected: subMenueSelectedState == 5,
                ),
                SubSideBarItems(
                  title: Text(
                    'Clients',
                    style: subMenueSelectedState == 6
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    context.go(
                      RouteConstants.clients,
                    );
                    setState(() {
                      subMenueSelectedState = 6;
                    });
                  },
                  isSelected: subMenueSelectedState == 6,
                ),
                SubSideBarItems(
                  title: Text(
                    'Leads',
                    style: subMenueSelectedState == 7
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    setState(() {
                      subMenueSelectedState = 4;
                    });
                  },
                  isSelected: false,
                ),
                SubSideBarItems(
                  title: Text(
                    'Department',
                    style: subMenueSelectedState == 8
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    setState(() {
                      subMenueSelectedState = 5;
                    });
                  },
                  isSelected: false,
                ),
              ],
            ),
            ExpandableSideBarItem(
              expandedTileController: ExpandedTileController(
                  isExpanded: sideMenueSelectedState == 3),
              titleColor: sideMenueSelectedState == 3
                  ? AppColors.buttonColor
                  : Colors.transparent,
              title: Text(
                'Work',
                style: sideMenueSelectedState == 3
                    ? AppText.sideMWhite_400_14
                    : AppText.black_400_14,
              ),
              onTap: () {
                setState(() {
                  sideMenueSelectedState = 3;
                });
              },
              icon: Image.asset(
                'assets/icons/workflow.png',
                color: sideMenueSelectedState == 3
                    ? Colors.white
                    : AppColors.blackColor,
              ),
              children: [
                SubSideBarItems(
                  title: Text(
                    'Project',
                    style: subMenueSelectedState == 9
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    context.go(RouteConstants.projects);
                    setState(() {
                      subMenueSelectedState = 9;
                    });
                  },
                  isSelected: subMenueSelectedState == 9,
                ),
                SubSideBarItems(
                  title: Text(
                    'Worksite',
                    style: subMenueSelectedState == 10
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {},
                  isSelected: false,
                ),
                SubSideBarItems(
                  title: Text(
                    'Tasks',
                    style: subMenueSelectedState == 11
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {
                    context.go(RouteConstants.tasks);
                    setState(() {
                      subMenueSelectedState = 11;
                    });
                  },
                  isSelected: subMenueSelectedState == 11,
                ),
                SubSideBarItems(
                  title: Text(
                    'Contracts',
                    style: subMenueSelectedState == 12
                        ? AppText.sideMBlueText_400_14
                        : AppText.sideMText_300_14,
                  ),
                  onTap: () {},
                  isSelected: false,
                ),
              ],
            ),
            ExpandableSideBarItem(
                expandedTileController: ExpandedTileController(
                    isExpanded: sideMenueSelectedState == 4),
                title: Text(
                  'Finance',
                  style: sideMenueSelectedState == 4
                      ? AppText.sideMWhite_400_14
                      : AppText.black_400_14,
                ),
                onTap: () {
                  setState(() {
                    sideMenueSelectedState = 4;
                  });
                },
                icon: Image.asset('assets/icons/workflow.png'),
                titleColor: sideMenueSelectedState == 4
                    ? AppColors.buttonColor
                    : Colors.transparent,
                children: const []),
            ExpandableSideBarItem(
                expandedTileController: ExpandedTileController(
                    isExpanded: sideMenueSelectedState == 5),
                title: Text(
                  'Calendar',
                  style: sideMenueSelectedState == 5
                      ? AppText.sideMWhite_400_14
                      : AppText.black_400_14,
                ),
                icon: Image.asset('assets/icons/workflow.png'),
                onTap: () {
                  setState(() {
                    sideMenueSelectedState = 5;
                  });
                },
                titleColor: sideMenueSelectedState == 5
                    ? AppColors.buttonColor
                    : Colors.transparent,
                children: const []),
            ExpandableSideBarItem(
                expandedTileController: ExpandedTileController(
                    isExpanded: sideMenueSelectedState == 6),
                title: Text(
                  'Services',
                  style: sideMenueSelectedState == 6
                      ? AppText.sideMWhite_400_14
                      : AppText.black_400_14,
                ),
                icon: Image.asset('assets/icons/workflow.png'),
                onTap: () {
                  setState(() {
                    sideMenueSelectedState = 6;
                  });
                },
                titleColor: sideMenueSelectedState == 6
                    ? AppColors.buttonColor
                    : Colors.transparent,
                children: const []),
            NonExpandableSideBarItem(
              titleColor: sideMenueSelectedState == 7
                  ? AppColors.buttonColor
                  : Colors.transparent,
              title: const Text('Notification'),
              icon: const Icon(Icons.settings),
              onTap: () {
                setState(() {
                  sideMenueSelectedState = 7;
                });
              },
            ),
            NonExpandableSideBarItem(
              titleColor: sideMenueSelectedState == 8
                  ? AppColors.buttonColor
                  : Colors.transparent,
              title: const Text('Settings'),
              icon: const Icon(Icons.notification_add),
              onTap: () {
                setState(() {
                  sideMenueSelectedState = 8;
                });
              },
            ),
          ],
        ),
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
            backgroundColor: AppColors.buttonColor,
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
          contentBackgroundColor: Colors.transparent,
          headerBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          // headerColor: Colors.transparent,
          headerColor: titleColor,
          headerSplashColor: Colors.transparent,
          contentSeparatorColor: Colors.transparent,
          // headerColor: titleColor,
          // colo
        ),
        title: title,
        leading: icon,
        content: Column(children: children),
        controller: expandedTileController);
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
          color: titleColor, borderRadius: BorderRadius.circular(10)),
      // color: titleColor,
      child: ListTile(
        tileColor: titleColor,
        leading: icon,
        onTap: onTap,
        title: title,
      ),
    );
  }
}
