import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/pages/operations/controllers/site_equipment_controller.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SiteEquipmentTable extends StatefulWidget {
  final int worksiteId;
  const SiteEquipmentTable({super.key, required this.worksiteId});

  @override
  State<SiteEquipmentTable> createState() => _SiteEquipmentTableState();
}

class _SiteEquipmentTableState extends State<SiteEquipmentTable> {
  final ScrollController _scrollController = ScrollController();
  late final SiteEquipmentController controller;
  bool _has(Permission permission) =>
      Get.isRegistered<PermissionService>() &&
      Get.find<PermissionService>().has(permission);

  @override
  void initState() {
    super.initState();
    controller = Get.put(SiteEquipmentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEquipment(context, worksiteId: widget.worksiteId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      final items = controller.equipment;

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Site Equipment', style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          loading
                              ? 'Loading equipment...'
                              : '${items.length} item${items.length == 1 ? '' : 's'} registered',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const StatusChip(
                        label: 'Inventory',
                        tone: StatusTone.primary,
                        icon: Iconsax.box,
                      ),
                      if (_has(Perms.siteEquipmentCreate))
                        MyElevatedButton(
                          height: 40,
                          icon: const Icon(Iconsax.add,
                              size: 16, color: AppColors.white),
                          child: 'Add Item',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AddEquipmentDialog(
                              worksiteId: widget.worksiteId,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            if (loading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 4),
              )
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.box,
                  title: 'No equipment recorded',
                  subtitle:
                      'Equipment allocated to this worksite will appear here.',
                ),
              )
            else
              _buildTable(items),
          ],
        ),
      );
    });
  }

  Widget _buildTable(List<SiteEquipment> items) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
            items.length, (index) => _buildMobileCard(items[index], index)),
      ),
    );
  }

  Widget _buildMobileCard(SiteEquipment eq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S/N: ${index + 1}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (_has(Perms.siteEquipmentUpdate))
                    IconButton(
                      tooltip: 'Adjust stock',
                      icon: const Icon(Iconsax.refresh,
                          size: 18, color: AppColors.primary),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AdjustEquipmentDialog(
                          item: eq,
                          onAdjust: (delta, reason) =>
                              controller.adjustEquipment(
                            context,
                            equipmentId: eq.id,
                            worksiteId: widget.worksiteId,
                            quantityDelta: delta,
                            reason: reason,
                          ),
                        ),
                      ),
                    ),
                  if (_has(Perms.siteEquipmentUpdate))
                    IconButton(
                      tooltip: 'Edit item',
                      icon: const Icon(Iconsax.edit_2,
                          size: 18, color: AppColors.textSecondary),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AddEquipmentDialog(
                          worksiteId: widget.worksiteId,
                          item: eq,
                        ),
                      ),
                    ),
                  if (_has(Perms.siteEquipmentDelete))
                    IconButton(
                      tooltip: 'Delete item',
                      icon: const Icon(Iconsax.trash,
                          size: 18, color: AppColors.danger),
                      onPressed: () => _confirmDelete(eq),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brSm,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Iconsax.box,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  eq.name.isEmpty ? '—' : eq.name,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _inventoryValue(
                  'Quantity', eq.quantity.isEmpty ? '—' : eq.quantity),
              _inventoryValue('Unit', eq.unit.isEmpty ? '—' : eq.unit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inventoryValue(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          Text(value,
              style:
                  AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500)),
        ],
      );

  Future<void> _confirmDelete(SiteEquipment item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete inventory item?'),
        content: Text('Delete ${item.name} from this worksite inventory?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await controller.deleteEquipment(context, item.id, widget.worksiteId);
    }
  }
}

class AddEquipmentDialog extends StatefulWidget {
  final int worksiteId;
  final SiteEquipment? item;
  const AddEquipmentDialog({super.key, required this.worksiteId, this.item});

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final SiteEquipmentController controller =
      Get.find<SiteEquipmentController>();

  final nameCtrl = TextEditingController();
  final unitValueCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      nameCtrl.text = item.name;
      unitValueCtrl.text = item.unit;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    unitValueCtrl.dispose();
    quantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: widget.item == null ? 'Add Inventory Item' : 'Edit Inventory Item',
      subtitle: widget.item == null
          ? 'Register an item for this worksite. Initial stock is optional.'
          : 'Update the inventory item details.',
      size: DialogSize.sm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(
            controller: nameCtrl,
            title: 'Equipment Name*',
            hintText: 'e.g. Excavator',
          ),
          const SizedBox(height: 20),
          MyTextFormField(
            controller: unitValueCtrl,
            title: 'Unit*',
            hintText: 'e.g. bags',
          ),
          if (widget.item == null) ...[
            const SizedBox(height: 20),
            MyTextFormField(
              controller: quantityCtrl,
              title: 'Initial Quantity (optional)',
              hintText: 'e.g. 25.000',
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        Obx(
          () => controller.isActionLoading.value
              ? const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : MyElevatedButton(
                  icon: SvgPicture.asset(
                    'assets/svg/check.svg',
                    colorFilter: const ColorFilter.mode(
                        AppColors.white, BlendMode.srcIn),
                  ),
                  child: 'Save',
                  onTap: _save,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
        ),
      ],
    );
  }

  void _save() {
    if (nameCtrl.text.trim().isEmpty || unitValueCtrl.text.trim().isEmpty)
      return;
    final initialQuantity = quantityCtrl.text.trim();
    if (initialQuantity.isNotEmpty &&
        (double.tryParse(initialQuantity) == null ||
            double.parse(initialQuantity) < 0 ||
            !_validInventoryQuantity(initialQuantity))) return;

    final eq = SiteEquipment(
      id: widget.item?.id ?? 0,
      worksiteId: widget.worksiteId,
      name: nameCtrl.text.trim(),
      unit: unitValueCtrl.text.trim(),
      quantity: initialQuantity,
      createdAt: '',
      updatedAt: '',
    );
    if (widget.item == null) {
      controller.createEquipment(context, eq);
    } else {
      controller.updateEquipment(context, eq);
    }
  }
}

class AdjustEquipmentDialog extends StatefulWidget {
  const AdjustEquipmentDialog(
      {super.key, required this.item, required this.onAdjust});
  final SiteEquipment item;
  final Future<void> Function(String delta, String reason) onAdjust;

  @override
  State<AdjustEquipmentDialog> createState() => _AdjustEquipmentDialogState();
}

class _AdjustEquipmentDialogState extends State<AdjustEquipmentDialog> {
  final _delta = TextEditingController();
  final _reason = TextEditingController();
  @override
  void dispose() {
    _delta.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DialogScaffold(
        title: 'Adjust Stock',
        subtitle:
            '${widget.item.name}: ${widget.item.quantity} ${widget.item.unit}',
        size: DialogSize.sm,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MyTextFormField(
              controller: _delta,
              title: 'Quantity Change*',
              hintText: 'Use a negative value to remove stock',
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true)),
          const SizedBox(height: 16),
          MyTextFormField(
              controller: _reason,
              title: 'Reason*',
              hintText: 'Describe the stock adjustment'),
        ]),
        actions: [
          MyOutlinedButton(
              child: 'Cancel', onTap: () => Navigator.pop(context)),
          MyElevatedButton(
              child: 'Adjust Stock',
              onTap: () {
                final value = double.tryParse(_delta.text.trim());
                if (value == null ||
                    value == 0 ||
                    !_validInventoryQuantity(_delta.text.trim()) ||
                    _reason.text.trim().isEmpty) return;
                widget.onAdjust(_delta.text.trim(), _reason.text.trim());
              }),
        ],
      );
}

bool _validInventoryQuantity(String value) =>
    RegExp(r'^-?\d+(\.\d{1,3})?$').hasMatch(value);
