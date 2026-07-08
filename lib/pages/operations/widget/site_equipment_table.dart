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
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
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
                        const Text('Site Equipment',
                            style: AppTextStyles.h3),
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
                  const StatusChip(
                    label: 'Inventory',
                    tone: StatusTone.primary,
                    icon: Iconsax.box,
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
        children: List.generate(items.length, (index) => _buildMobileCard(items[index], index)),
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
              IconButton(
                icon: const Icon(Iconsax.trash, size: 18, color: AppColors.danger),
                onPressed: () => controller.deleteEquipment(
                    context, eq.id, widget.worksiteId),
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
              Text(
                'Unit Value',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              Text(
                eq.unitValue.isEmpty ? '—' : eq.unitValue,
                style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _buildEquipmentRow(SiteEquipment eq, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
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
                Flexible(
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
          ),
          SizedBox(
            width: 160,
            child: Text(
              eq.unitValue.isEmpty ? '—' : eq.unitValue,
              style: AppTextStyles.bodyMd,
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brSm,
                  onTap: () => controller.deleteEquipment(
                      context, eq.id, widget.worksiteId),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Iconsax.trash,
                      size: 16,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEquipmentDialog extends StatefulWidget {
  final int worksiteId;
  const AddEquipmentDialog({super.key, required this.worksiteId});

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final SiteEquipmentController controller =
      Get.find<SiteEquipmentController>();

  final nameCtrl = TextEditingController();
  final unitValueCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    unitValueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Equipment',
      subtitle: 'Register equipment allocated to this worksite.',
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
            title: 'Unit Value*',
            hintText: 'e.g. 2',
          ),
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
    if (nameCtrl.text.isEmpty || unitValueCtrl.text.isEmpty) return;

    final eq = SiteEquipment(
      id: 0,
      worksiteId: widget.worksiteId,
      name: nameCtrl.text,
      unitValue: unitValueCtrl.text,
      createdAt: '',
      updatedAt: '',
    );

    controller.createEquipment(context, eq);
  }
}
