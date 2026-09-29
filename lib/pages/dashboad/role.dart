import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/company/widget/role_detail_tabs/kpi_tab.dart';
import 'package:bomach_os/pages/company/widget/role_detail_tabs/sop_tab.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/services/role_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

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

class _RoleCard extends StatefulWidget {
  const _RoleCard(this.role);

  final Role role;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  static const _storage = FlutterSecureStorage();
  static const _permissionPageSize = 10;
  int _permissionPage = 1;
  late Future<Map<String, dynamic>?> _descriptionFuture;

  @override
  void initState() {
    super.initState();
    _descriptionFuture = _loadRoleDescription(widget.role.id);
  }

  @override
  void didUpdateWidget(covariant _RoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role.id != widget.role.id) {
      _permissionPage = 1;
      _descriptionFuture = _loadRoleDescription(widget.role.id);
    }
  }

  Future<Map<String, dynamic>?> _loadRoleDescription(int roleId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null || token.isEmpty) return null;
      return await RoleService().getRoleDescription(token, roleId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final permissionEntries = _sortedPermissions(role.permissions);
    final totalPages = (permissionEntries.length / _permissionPageSize).ceil();
    final currentPage =
        totalPages == 0 ? 1 : _permissionPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _permissionPageSize;
    final pageEntries =
        permissionEntries.skip(startIndex).take(_permissionPageSize).toList();

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
        _RoleProfileSection(
          title: 'Role Details',
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _descriptionFuture,
            builder: (context, snapshot) {
              final description = snapshot.data ?? const <String, dynamic>{};
              return _RoleDefinition(role: role, description: description);
            },
          ),
        ),
        _RoleProfileSection(
          title: 'KPIs',
          child: KpiTab(roleId: role.id, readOnly: true),
        ),
        _RoleProfileSection(
          title: 'SOPs',
          child: SopTab(
            roleId: role.id,
            departmentId: role.departmentId,
            readOnly: true,
          ),
        ),
        _RoleProfileSection(
          title: 'Permissions',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (role.permissions.isEmpty)
                Text(
                  'No permissions returned for this role.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                )
              else
                ...pageEntries.map(
                  (entry) => _PermissionGroup(entry.key, entry.value),
                ),
              if (totalPages > 1) ...[
                const Divider(height: 24),
                _PermissionPagination(
                  currentPage: currentPage,
                  pageSize: _permissionPageSize,
                  totalItems: permissionEntries.length,
                  onPageChanged: (page) =>
                      setState(() => _permissionPage = page),
                ),
              ],
            ],
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

class _RoleProfileSection extends StatelessWidget {
  const _RoleProfileSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RoleDefinition extends StatelessWidget {
  const _RoleDefinition({required this.role, required this.description});

  final Role role;
  final Map<String, dynamic> description;

  @override
  Widget build(BuildContext context) {
    final mission = _firstText([
      description['purpose'],
      description['mission'],
      role.mission,
    ]);
    final jobDescription = _firstText([
      description['job_description'],
      role.jobDescription,
    ]);
    final responsibilities = _formatResponsibilities(
      description['responsibilities'] ?? role.responsibilities,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RoleDefinitionItem(label: 'Mission / Purpose', value: mission),
        const _RoleDefinitionDivider(),
        _RoleDefinitionItem(label: 'Job Description', value: jobDescription),
        const _RoleDefinitionDivider(),
        _RoleDefinitionItem(
          label: 'Responsibilities',
          value: responsibilities,
          multiline: true,
        ),
        const _RoleDefinitionDivider(),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 600 ? 1 : 2;
            final itemWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _RoleDefinitionItem(
                    label: 'Reports To',
                    value: role.reportsToRoleName ?? '',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _RoleDefinitionItem(
                    label: 'Branches',
                    value: role.branches.isEmpty
                        ? 'All branches'
                        : role.branches
                            .map((branch) => branch.branchName)
                            .join(', '),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _firstText(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _formatResponsibilities(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .join('\n');
    }
    return value?.toString().trim() ?? '';
  }
}

class _RoleDefinitionDivider extends StatelessWidget {
  const _RoleDefinitionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, color: AppColors.borderSubtle),
      );
}

class _RoleDefinitionItem extends StatelessWidget {
  const _RoleDefinitionItem({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        if (multiline && value.trim().isNotEmpty)
          ...value.split('\n').where((line) => line.trim().isNotEmpty).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 10),
                        child: Icon(
                          Iconsax.tick_circle,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          line,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
        else
          Text(
            value.trim().isEmpty ? 'Not defined' : value,
            style: AppTextStyles.bodyMd.copyWith(
              color: value.trim().isEmpty
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

class _PermissionPagination extends StatelessWidget {
  const _PermissionPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
  });

  final int currentPage;
  final int pageSize;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / pageSize).ceil();
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageButtons = <Widget>[
          IconButton(
            tooltip: 'Previous permissions page',
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Iconsax.arrow_left_2),
            iconSize: 20,
          ),
          for (var page = 1; page <= totalPages; page++) _buildPageButton(page),
          IconButton(
            tooltip: 'Next permissions page',
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Iconsax.arrow_right_3),
            iconSize: 20,
          ),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pageButtons,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => onPageChanged(page),
        borderRadius: AppRadii.brSm,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadii.brSm,
          ),
          child: Text(
            '$page',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.brMd,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.layer, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  _readableResource(resource),
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedActions.map(_PermissionActionChip.new).toList(),
            ),
          ],
        ),
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

class _PermissionActionChip extends StatelessWidget {
  const _PermissionActionChip(this.action);

  final String action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.record, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            _readableAction(action),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _readableAction(String value) => value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
