import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/pages/auth/login_screen.dart';
import 'package:bms_front_end/pages/branches/branch_page.dart';
import 'package:bms_front_end/pages/branches/department.dart';
import 'package:bms_front_end/pages/clients/clients_database.dart';
import 'package:bms_front_end/pages/dashboad/dashboard.dart';
import 'package:bms_front_end/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/pages/employees_database/employee_profile.dart';
import 'package:bms_front_end/pages/hr/leads.dart';
import 'package:bms_front_end/pages/hr/leaves.dart';
import 'package:bms_front_end/pages/hr/meetings.dart';
import 'package:bms_front_end/pages/large_screen.dart';
import 'package:bms_front_end/pages/projects/each_projects.dart';
import 'package:bms_front_end/pages/projects/projects_page.dart';
import 'package:bms_front_end/pages/projects/task_page.dart';
import 'package:bms_front_end/pages/services/real_estate.dart';
import 'package:bms_front_end/pages/small_screen.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

StatefulShellBranch statefulShellBranch(String path, Widget screen) {
  return StatefulShellBranch(routes: [
    GoRoute(
      path: path,
      builder: (context, state) => screen,
    ),
  ]);
}

final goRoute = GoRouter(
  initialLocation: RouteConstants.department,
  routes: [
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const LoginScreen(),
    ),
    // Dashboard
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ResponsiveWidget(
        smallScreen: SmallScreenDashboard(navigationShell: navigationShell),
        mediumScreen: SmallScreenDashboard(navigationShell: navigationShell),
        largeScreen: LargeScreenDashboard(navigationShell: navigationShell),
      ),
      branches: [
        statefulShellBranch(RouteConstants.home, const DashboardScreen()),
        statefulShellBranch(RouteConstants.enugu, const BranchPage()),
        statefulShellBranch(RouteConstants.employees, const EmployeeDatabase()),
        statefulShellBranch(
            RouteConstants.addEmployees, const AddEmployesScreen()),
        statefulShellBranch(
            RouteConstants.employeeProfile, const EmployeeProfile()),
        statefulShellBranch(
            RouteConstants.clients, const ClientsDatabasePage()),
        statefulShellBranch(RouteConstants.projects, const ProjectsPage()),
        statefulShellBranch(RouteConstants.eachprojects, const EachProjects()),
        statefulShellBranch(RouteConstants.worksite, const EmployeeProfile()),
        statefulShellBranch(RouteConstants.tasks, const TaskPage()),
        statefulShellBranch(
            RouteConstants.realEstate, const RealEstateScreen()),
        statefulShellBranch(RouteConstants.leads, const LeadsPage()),
        statefulShellBranch(RouteConstants.leaves, const Leaves()),
        statefulShellBranch(RouteConstants.meetings, const Meetings()),
        statefulShellBranch(RouteConstants.department, const DepartmentPage()),
      ],
    )
  ],
);
