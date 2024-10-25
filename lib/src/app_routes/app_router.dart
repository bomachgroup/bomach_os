import 'package:bms_front_end/components/responsive_widget.dart';
import 'package:bms_front_end/views/app_routes/app_route_constants.dart';
import 'package:bms_front_end/views/pages/branches/branch_page.dart';
import 'package:bms_front_end/views/pages/clients/clients_database.dart';
import 'package:bms_front_end/views/pages/dashboad/dashboard_ui.dart';
import 'package:bms_front_end/views/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/views/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/views/pages/employees_database/employee_profile.dart';
import 'package:bms_front_end/views/pages/large_screen.dart';
import 'package:bms_front_end/views/pages/projects/each_projects.dart';
import 'package:bms_front_end/views/pages/projects/projects_page.dart';
import 'package:bms_front_end/views/pages/projects/task_page.dart';
import 'package:bms_front_end/views/pages/small_screen.dart';
import 'package:go_router/go_router.dart';

final goRoute= GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell)=>
      ResponsiveWidget(
        // navigationShell: navigationShell,
        smallScreen: SmallScreenDashboard(navigationShell: navigationShell),
        largeScreen:  LargeScreenDashboard(navigationShell: navigationShell),),
      branches:  [
        StatefulShellBranch(
          routes:  [
            GoRoute(
              path: RouteConstants.home,
              builder: (context, state) =>  const DashboardScreen(),),
          ]),
             StatefulShellBranch(
          routes:  [
            GoRoute(
              path: RouteConstants.enugu,
              builder: (context, state) =>  const BranchPage(),),
              // GoRoute(path: RouteConstants.homeDetails)
          ]),
        StatefulShellBranch(
          routes:  [
            GoRoute(
              path: RouteConstants.employees,
              builder: (context, state) =>  EmployeeDatabase(),
              ),
              GoRoute(
                path: RouteConstants.addEmployees,
                builder: (context, state) => const AddEmployesScreen(),
                ),
                 GoRoute(
                path: RouteConstants.employeeProfile,
                builder: (context, state) => const EmployeeProfile(),
                ),
          ]),
                  StatefulShellBranch(
          routes:  [
            GoRoute(
              path: RouteConstants.clients,
              builder: (context, state) =>  const ClientsDatabasePage(),
              ),
          
          ]),
                StatefulShellBranch(
          routes:  [
              GoRoute(
                path: RouteConstants.projects,
                builder: (context, state) =>  ProjectsPage(),
                ),
                 GoRoute(
                path: RouteConstants.eachprojects,
                builder: (context, state) => const EachProjects(),
                ),
                 GoRoute(
                path: RouteConstants.worksite,
                builder: (context, state) => const EmployeeProfile(),
                ),
                  GoRoute(
                path: RouteConstants.tasks,
                builder: (context, state) => const TaskPage(),
                ),
          ]),
      ])
  ]
  
  );
