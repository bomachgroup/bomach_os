// Component imports
import 'package:bms_front_end/components/section/responsive_widget.dart';
// Page imports
import 'package:bms_front_end/pages/auth/login_screen.dart';
import 'package:bms_front_end/pages/branch/branch.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/pages/dashboad/dashboard.dart';
import 'package:bms_front_end/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/pages/employees_database/employee_profile.dart';
import 'package:bms_front_end/pages/hr/department.dart';
import 'package:bms_front_end/pages/hr/leads.dart';
import 'package:bms_front_end/pages/hr/leaves.dart';
import 'package:bms_front_end/pages/hr/meetings.dart';
import 'package:bms_front_end/pages/large_screen.dart';
import 'package:bms_front_end/pages/project/each_project.dart';
import 'package:bms_front_end/pages/project/projects.dart';
import 'package:bms_front_end/pages/project/task.dart';
import 'package:bms_front_end/pages/services/land_survey.dart';
import 'package:bms_front_end/pages/services/land_survey_detail.dart';
import 'package:bms_front_end/pages/services/real_estate.dart';
import 'package:bms_front_end/pages/services/real_estate_detail.dart';
import 'package:bms_front_end/pages/services/service_order.dart';
import 'package:bms_front_end/pages/small_screen.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Map of all dashboard screens to their routes for better maintainability
final Map<String, Widget> _dashboardRoutes = {
  RouteConstants.home: const DashboardScreen(),
  RouteConstants.enugu: const BranchPage(),
  RouteConstants.employees: const EmployeeDatabase(),
  RouteConstants.addEmployees: const AddEmployesScreen(),
  RouteConstants.employeeProfile: const EmployeeProfile(),
  RouteConstants.clients: const ClientsDatabasePage(),
  RouteConstants.projects: const ProjectsPage(),
  RouteConstants.eachProjects: const EachProjects(),
  RouteConstants.worksite: const EmployeeProfile(),
  RouteConstants.tasks: const TaskPage(),
  RouteConstants.realEstate: const RealEstateScreen(),
  RouteConstants.leads: const LeadsPage(),
  RouteConstants.leaves: const LeavesPage(),
  RouteConstants.meetings: const Meetings(),
  RouteConstants.department: const DepartmentPage(),
  RouteConstants.serviceOrder: const ServiceOrder(),
  RouteConstants.landSurvey: const LandSurveyScreen(),
  RouteConstants.realEstateDetail: const RealEstateDetailScreen(),
  RouteConstants.landSurveyDetail: const LandSurveyDetailScreen(),
};

/// Creates a branch for StatefulShellRoute with a single route
StatefulShellBranch _createBranch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => screen,
      ),
    ],
  );
}

/// Main router configuration
final goRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    // Login route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Dashboard with indexed stack navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ResponsiveWidget(
        smallScreen: SmallScreenDashboard(navigationShell: navigationShell),
        mediumScreen: SmallScreenDashboard(navigationShell: navigationShell),
        largeScreen: LargeScreenDashboard(navigationShell: navigationShell),
      ),
      branches: _dashboardRoutes.entries
          .map((entry) => _createBranch(entry.key, entry.value))
          .toList(),
    ),
  ],

  // Handle errors and redirects
  errorBuilder: (context, state) => const Center(
    child: Text('Page not found'),
  ),
);
