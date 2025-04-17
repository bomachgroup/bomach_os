import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectMembers extends StatelessWidget {
  const ProjectMembers({super.key, required this.members});

  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor, width: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DataTable(
        columns: _columns,
        rows: members.map((m) => _buildRow(context, m)).toList(),
        headingRowHeight: 40,
        dataRowHeight: 56,
        horizontalMargin: 12,
        columnSpacing: 16,
      ),
    );
  }

  static const _columns = [
    DataColumn(
        label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(
        label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(
        label:
            Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(
        label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(
        label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(
        label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
  ];

  DataRow _buildRow(BuildContext context, Member m) {
    return DataRow(
      cells: [
        DataCell(Text(m.id, overflow: TextOverflow.ellipsis)),
        DataCell(_NameCell(member: m)),
        DataCell(Text(m.department, overflow: TextOverflow.ellipsis)),
        DataCell(Text(m.designation, overflow: TextOverflow.ellipsis)),
        DataCell(_Badge(text: m.employmentType)),
        DataCell(IconButton(
          icon: const Icon(Icons.more_vert_outlined),
          onPressed: () => _onActionTap(context, m),
        )),
      ],
    );
  }

  void _onActionTap(BuildContext context, Member m) {
    // handle action menu
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.member});
  final Member member;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(RouteConstants.employeeProfile),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.secondaryColor,
          backgroundImage:
              member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
          child: member.avatarUrl == null ? Text(member.initials) : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            member.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(width: 0.6, color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(6),
        color: AppColors.whiteColor,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class Member {
  final String id;
  final String name;
  final String department;
  final String designation;
  final String employmentType;
  final String? avatarUrl;

  Member({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.employmentType,
    this.avatarUrl,
  });

  String get initials => name.isNotEmpty
      ? name.trim().split(' ').map((e) => e[0]).take(2).join()
      : '';
}
