import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Read-only view of the roles and permissions assigned to the signed-in user.
class RolePage extends StatefulWidget {
  const RolePage({
    super.key,
    this.controller,
    this.autoRefresh = true,
  });

  /// Optional injection point for widget tests and embedded consumers.
  final AuthController? controller;
  final bool autoRefresh;

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? Get.find<AuthController>();
    if (widget.autoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.refreshCurrentRoles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final roles = _controller.currentRoles.toList(growable: false);
      final isLoading = _controller.isCurrentRolesLoading.value;
      final error = _controller.currentRolesError.value;

      return PageScaffold(
        header: const PageHeader(
          title: 'Role',
          subtitle: 'Your assigned role and access permissions',
        ),
        children: [
          if (error.isNotEmpty && roles.isNotEmpty)
            _RefreshError(
                message: error, onRetry: _controller.refreshCurrentRoles),
          if (isLoading && roles.isEmpty)
            const _RoleLoadingState()
          else if (roles.isEmpty)
            _emptyState(error)
          else
            ...roles.map(_RoleCard.new),
        ],
      );
    });
  }

  Widget _emptyState(String error) {
    final status = _controller.currentRolesErrorStatus.value;
    if (status == 403) {
      return EmptyState(
        title: 'You do not have permission to view your role details',
        subtitle: 'Ask an administrator to grant roles:view_own access.',
        action: _retryButton,
      );
    }
    if (status == 404) {
      return EmptyState.empty(
        title: 'No role assigned yet',
        subtitle: 'Your administrator has not assigned a role to your account.',
        action: _retryButton,
      );
    }
    if (status == 401) {
      return EmptyState(
        title: 'Your session has expired',
        subtitle: 'Please sign in again to load your role details.',
        action: FilledButton(
          onPressed: () async {
            await _controller.logout();
            if (mounted) context.go(RouteConstants.login);
          },
          child: const Text('Sign in again'),
        ),
      );
    }
    if (error.isNotEmpty) {
      return EmptyState(
        title: 'Could not load your role details',
        subtitle: error,
        action: _retryButton,
      );
    }
    return EmptyState.empty(
      title: 'No role assigned yet',
      subtitle: 'Your administrator has not assigned a role to your account.',
      action: _retryButton,
    );
  }

  Widget get _retryButton => FilledButton(
        onPressed: _controller.isCurrentRolesLoading.value
            ? null
            : _controller.refreshCurrentRoles,
        child: const Text('Retry'),
      );
}

class _RoleLoadingState extends StatelessWidget {
  const _RoleLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: .25)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard(this.role);

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.name, style: AppTextStyles.h2),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth < 600 ? 1 : 2;
                    final itemWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 2;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _Metadata(
                            label: 'Role ID',
                            value: '${role.id}',
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _Metadata(
                            label: 'Branches',
                            value: role.branches.isEmpty
                                ? 'No branch scope'
                                : role.branches
                                    .map((branch) =>
                                        '${branch.branchName} (${branch.id})')
                                    .join(', '),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _Metadata(
                            label: 'Created',
                            value: DateFormat.yMMMd().format(role.createdAt),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _Metadata(
                            label: 'Last updated',
                            value: DateFormat.yMMMd().format(role.updatedAt),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Permissions', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                if (role.permissions.isEmpty)
                  Text(
                    'No permissions returned for this role.',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textSecondary),
                  )
                else
                  ..._sortedPermissions(role.permissions).map(
                    (entry) => _PermissionGroup(entry.key, entry.value),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, List<String>>> _sortedPermissions(
    Map<String, List<String>> permissions,
  ) {
    final entries = permissions.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyMd),
      ],
    );
  }
}

class _PermissionGroup extends StatelessWidget {
  const _PermissionGroup(this.resource, this.actions);

  final String resource;
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    final sortedActions = [...actions]..sort();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_readableResource(resource), style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedActions
                .map((action) => Chip(label: Text(action)))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _readableResource(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
