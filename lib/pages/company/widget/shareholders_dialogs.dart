import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/company_controller.dart';
import 'edit_company_dialog.dart';

// ==============================================================================
// EDIT SHARE HOLDERS DIALOG (Add/Edit multiple shareholders in a table)
// ==============================================================================
class EditShareHoldersDialog extends StatefulWidget {
  const EditShareHoldersDialog({super.key});

  @override
  State<EditShareHoldersDialog> createState() => _EditShareHoldersDialogState();
}

class _EditShareHoldersDialogState extends State<EditShareHoldersDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  final _formKey = GlobalKey<FormState>();

  // Editable rows
  List<_ShareholderRow> rows = [];

  static const _roleOptions = [
    'Founder',
    'Co-Founder',
    'Investor',
    'Director',
    'Partner',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Populate from existing shareholders
    for (final s in controller.shareholders) {
      rows.add(_ShareholderRow(
        id: s.id,
        nameCtrl: TextEditingController(text: s.fullName),
        role: s.titleDisplay.isNotEmpty ? s.titleDisplay : 'Investor',
        sharesCtrl: TextEditingController(text: '${s.shareCount}'),
        percentage: s.sharePercentage,
      ));
    }
  }

  @override
  void dispose() {
    for (final r in rows) {
      r.nameCtrl.dispose();
      r.sharesCtrl.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      rows.add(_ShareholderRow(
        nameCtrl: TextEditingController(),
        role: 'Investor',
        sharesCtrl: TextEditingController(),
        percentage: '0.00',
      ));
    });
  }

  void _recalcPercentages() {
    final totalAuthorized = controller.authorizedShares.value > 0
        ? controller.authorizedShares.value
        : _totalShares();

    if (totalAuthorized <= 0) return;

    setState(() {
      for (final r in rows) {
        final shares = int.tryParse(r.sharesCtrl.text) ?? 0;
        r.percentage =
            (shares / totalAuthorized * 100).toStringAsFixed(2);
      }
    });
  }

  int _totalShares() {
    int total = 0;
    for (final r in rows) {
      total += int.tryParse(r.sharesCtrl.text) ?? 0;
    }
    return total;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Process each row - determine creates vs updates
    for (final row in rows) {
      final nameParts = row.nameCtrl.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'title': row.role.toLowerCase().replaceAll('-', '_'),
        'share_count': int.tryParse(row.sharesCtrl.text) ?? 0,
        'share_percentage': row.percentage,
        'is_board_member': false,
        'is_active': true,
      };

      if (row.id != null) {
        // Update existing
        if (mounted) {
          await controller.updateShareholder(context, row.id!, data);
        }
      } else {
        // Create new
        if (mounted) {
          await controller.createShareholder(context, data);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseEditDialog(
          title: "Edit Share Holders",
          isSaving: controller.isSaving.value,
          onCancel: () => Navigator.pop(context),
          onSave: _save,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText("Ownership Records",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),

                // Table header
                _buildTableHeader(),
                const SizedBox(height: 8),

                // Table rows
                ...rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  return _buildTableRow(i, row);
                }),

                const SizedBox(height: 16),

                // Add button
                InkWell(
                  onTap: _addRow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text("Add",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text("S/N", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          Expanded(flex: 3, child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          Expanded(flex: 2, child: Text("Role", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          Expanded(flex: 2, child: Text("Shares", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          Expanded(flex: 1, child: Text("Percentage", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index, _ShareholderRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 40,
              child: Text("${index + 1}",
                  style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: row.nameCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Full name",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButtonFormField<String>(
                value: _roleOptions.contains(row.role)
                    ? row.role
                    : 'Investor',
                isDense: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                ),
                items: _roleOptions
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => row.role = v);
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: row.sharesCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: "0",
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.card),
                  ),
                ),
                onChanged: (_) => _recalcPercentages(),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text("${row.percentage}%",
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ShareholderRow {
  final int? id;
  final TextEditingController nameCtrl;
  String role;
  final TextEditingController sharesCtrl;
  String percentage;

  _ShareholderRow({
    this.id,
    required this.nameCtrl,
    required this.role,
    required this.sharesCtrl,
    required this.percentage,
  });
}

// ==============================================================================
// ADD/EDIT SINGLE SHAREHOLDER DIALOG
// ==============================================================================
class AddEditShareholderDialog extends StatefulWidget {
  final Shareholder? shareholder;

  const AddEditShareholderDialog({super.key, this.shareholder});

  @override
  State<AddEditShareholderDialog> createState() =>
      _AddEditShareholderDialogState();
}

class _AddEditShareholderDialogState extends State<AddEditShareholderDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController sharesCtrl;
  late TextEditingController notesCtrl;

  String selectedRole = 'Investor';
  bool isBoardMember = false;

  bool get isEditing => widget.shareholder != null;

  static const _roleOptions = [
    'Founder',
    'Co-Founder',
    'Investor',
    'Director',
    'Partner',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.shareholder;
    firstNameCtrl = TextEditingController(text: s?.firstName ?? '');
    lastNameCtrl = TextEditingController(text: s?.lastName ?? '');
    emailCtrl = TextEditingController(text: s?.email ?? '');
    phoneCtrl = TextEditingController(text: s?.phoneNumber ?? '');
    sharesCtrl = TextEditingController(text: s != null ? '${s.shareCount}' : '');
    notesCtrl = TextEditingController(text: s?.notes ?? '');
    if (s != null) {
      selectedRole = _roleOptions.contains(s.titleDisplay)
          ? s.titleDisplay
          : 'Investor';
      isBoardMember = s.isBoardMember;
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    sharesCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'first_name': firstNameCtrl.text.trim(),
      'last_name': lastNameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone_number': phoneCtrl.text.trim(),
      'title': selectedRole.toLowerCase().replaceAll('-', '_'),
      'share_count': int.tryParse(sharesCtrl.text) ?? 0,
      'is_board_member': isBoardMember,
      'is_active': true,
      if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
    };

    if (isEditing) {
      controller.updateShareholder(context, widget.shareholder!.id, data);
    } else {
      controller.createShareholder(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseEditDialog(
          title: isEditing ? "Edit Shareholder" : "Add Shareholder",
          isSaving: controller.isSaving.value,
          onCancel: () => Navigator.pop(context),
          onSave: _save,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: firstNameCtrl,
                      title: 'First Name*',
                      hintText: 'Enter first name',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      controller: lastNameCtrl,
                      title: 'Last Name*',
                      hintText: 'Enter last name',
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: emailCtrl,
                      title: 'Email',
                      hintText: 'email@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      controller: phoneCtrl,
                      title: 'Phone Number',
                      hintText: '+234...',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: MyDropdown(
                      title: 'Role*',
                      hintText: selectedRole,
                      items: _roleOptions,
                      onChanged: (v) {
                        if (v != null) setState(() => selectedRole = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      controller: sharesCtrl,
                      title: 'Number of Shares*',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: isBoardMember,
                      activeColor: AppColors.blue,
                      onChanged: (v) =>
                          setState(() => isBoardMember = v ?? false),
                    ),
                    const Text("Board Member",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                MyTextFormField(
                  controller: notesCtrl,
                  title: 'Notes',
                  hintText: 'Optional notes...',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ));
  }
}

// ==============================================================================
// EDIT EQUITY VALUE DIALOG
// ==============================================================================
class EditEquityDialog extends StatefulWidget {
  const EditEquityDialog({super.key});

  @override
  State<EditEquityDialog> createState() => _EditEquityDialogState();
}

class _EditEquityDialogState extends State<EditEquityDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  late TextEditingController equityCtrl;

  @override
  void initState() {
    super.initState();
    equityCtrl = TextEditingController(
      text: controller.authorizedShares.value > 0
          ? '${controller.authorizedShares.value}'
          : '',
    );
  }

  @override
  void dispose() {
    equityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseEditDialog(
          title: "Edit Equity Value",
          isSaving: controller.isSaving.value,
          onCancel: () => Navigator.pop(context),
          onSave: () {
            final value = int.tryParse(equityCtrl.text);
            if (value == null || value <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter a valid number"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            controller.updateEquityValue(context, value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                controller: equityCtrl,
                title: 'Equity Value',
                hintText: 'Enter authorized shares',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ));
  }
}

// ==============================================================================
// DELETE CONFIRMATION DIALOG
// ==============================================================================
Future<bool?> showDeleteShareholderDialog(
    BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Delete Shareholder",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          "Are you sure you want to remove $name from the shareholders list? This action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        MyElevatedButton(
          child: 'Delete',
          bgColor: Colors.red,
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    ),
  );
}
