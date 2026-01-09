# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bomach OS is a comprehensive enterprise management system built with Flutter. It's a multi-module web/desktop application that manages various business operations including HR, CRM, Operations, Finance, Marketing, Legal, Security, and Client Portal.

**Tech Stack:**

- Flutter 3.32.5 / Dart 3.8.1
- go_router for navigation with StatefulShellRoute
- SharedPreferences for local state persistence
- flutter_quill for rich text editing
- fl_chart for data visualization

## Development Commands

```bash
# Run the application
flutter run -d chrome  # For web
flutter run -d macos   # For macOS

# Run tests
flutter test

# Analyze code
flutter analyze

# Get dependencies
flutter pub get

# Clean build artifacts
flutter clean

# Build for production
flutter build web
flutter build macos
flutter build windows
flutter build linux
```

## Architecture

### Navigation Structure

The app uses a **StatefulShellRoute with indexed stack navigation** pattern. All major modules are loaded as branches in the shell route, allowing for persistent navigation state:

- Router config: `lib/src/app_routes/app_router.dart`
- Route constants: `lib/src/app_routes/app_route_constants.dart`
- Navigation is handled through go_router's `context.go()` method

The app layout splits into:

- __LargeScreenDashboard__ (`lib/pages/large_screen.dart`): Desktop layout with persistent sidebar
- __SmallScreenDashboard__ (`lib/pages/small_screen.dart`): Mobile/tablet responsive layout

### Project Structure

```ini
lib/
├── main.dart                    # App entry point, initializes SharedPreferences
├── components/                  # Reusable UI components
│   ├── button/                  # Button variants
│   ├── cards/                   # Card components
│   ├── chart/                   # Chart widgets
│   ├── dialog/                  # Dialog components
│   ├── input/                   # Input field components
│   ├── nav/                     # Navigation components
│   │   ├── side_menu.dart      # Main sidebar with expandable menu items
│   │   └── header.dart         # Top navigation bar
│   └── text/                    # Text components
├── pages/                       # Module-specific pages
│   ├── analytics/               # Analytics & Insights module
│   ├── auth/                    # Authentication screens
│   ├── clients_portal/          # Client portal interface
│   ├── company/                 # Company profile & branch management
│   ├── crm/                     # Customer Relationship Management
│   ├── dashboad/                # Main dashboard (note: typo in original)
│   ├── employees_database/      # Employee management
│   ├── finance/                 # Finance & Accounting
│   ├── hr/                      # Human Resources
│   ├── legal/                   # Legal & Compliance
│   ├── marketing/               # Marketing campaigns & leads
│   ├── operations/              # Operations management (projects, tasks, contracts)
│   ├── security/                # Security & Authorization
│   ├── services/                # Services (real estate, land survey)
│   └── workspace/               # Workspace management
└── src/                         # Core application code
    ├── app_routes/              # Routing configuration
    ├── constants/               # App constants (colors, text styles, spacing)
    ├── controller/              # State controllers
    ├── helper/                  # Helper utilities (screen size, color, text)
    └── model/                   # Data models
```

### Sidebar Navigation System

The sidebar (`lib/components/nav/side_menu.dart`) implements a sophisticated two-level menu system:

1. **Main Menu Items** (`MainMenuItem` enum): Top-level navigation items
2. **Sub Menu Items** (`SubMenuItem` enum): Nested navigation under expandable menus

**Key Features:**

- Route-to-menu mapping for automatic selection based on current route
- State persistence using SharedPreferences
- Expandable menu items using `flutter_expanded_tile`
- Automatic menu state synchronization on route changes

When adding new routes:

1. Add route constant to `RouteConstants` in `app_route_constants.dart`
2. Add the page widget to `_dashboardRoutes` map in `app_router.dart`
3. Update `menuItems` in `side_menu.dart` with appropriate menu structure
4. Ensure route mapping is correct for menu auto-selection

### Responsive Design

The app uses `ResponsiveWidget` (from `lib/components/section/responsive_widget.dart`) to adapt layouts:

- **Large screens**: Persistent sidebar + content area
- **Medium/Small screens**: Hamburger menu + full-width content

Screen size helpers are in `lib/src/helper/screen_size.dart`.

### Styling System

Centralized styling in `lib/src/constants/`:

- **colors.dart**: App color palette (`AppColors` class)
- **textstyle.dart**: Predefined text styles (`AppText` class)
- **spaces.dart**: Standard spacing constants

### State Management

Currently uses:

- **SharedPreferences**: Menu state, user preferences
- **StatefulWidget**: Local component state
- **StatefulShellRoute**: Navigation state persistence

Global `prefs` instance initialized in `main.dart` before app launch.

## Module Organization

Each major module follows a consistent pattern:

- Main dashboard/overview page
- List views for entities
- Detail pages for individual items
- Models defined in local `models.dart` or `model.dart`

Examples:

- **CRM**: `crm/crm.dart` (dashboard) → `crm/clients.dart`, `crm/leads.dart`, `crm/interactions.dart`
- __Operations__: `operations/operations.dart` → `operations/project_detail.dart`, `operations/task_detail.dart`
- **HR**: `hr/hr.dart` → `hr/employees.dart`, `hr/payroll.dart`, `hr/attendance.dart`

## Key Implementation Notes

1. **Adding a new module:**

   - Create page directory under `lib/pages/`
   - Define routes in `app_route_constants.dart`
   - Add pages to `_dashboardRoutes` map in `app_router.dart`
   - Create menu item in `side_menu.dart` with proper enum entries
   - Use existing component patterns from `lib/components/`

2. **Navigation best practices:**

   - Always use `context.go(RouteConstants.routeName)` for navigation
   - Never hardcode route strings
   - Ensure new routes are added to `_dashboardRoutes` map

3. **Firebase integration:**

   - Firebase is currently commented out in the codebase
   - To re-enable, uncomment imports in `main.dart` and firebase initialization

4. **Assets:**

   - Icons: `assets/svg/sidebar/` for menu icons
   - Images: `assets/image/`
   - Fonts: Poppins (default app font)

## Common Patterns

**Reusable components** are organized by type in `lib/components/`:

- Prefer using existing components over creating new ones eg my textformfield, dropdowns etc
- Components are designed to be composable and customizable
- Check `button/`, `cards/`, `input/` directories for available variants
- Keep new designs inline with existing designs

**Page structure** typically includes:

- Top-level Scaffold (provided by layout wrapper)
- Content wrapped in responsive containers
- Use `AppColors`, `AppText`, and spacing constants for consistency
