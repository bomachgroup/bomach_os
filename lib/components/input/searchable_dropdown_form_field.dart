import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SearchableDropdownOption<T> {
  const SearchableDropdownOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A form dropdown that adds an in-picker search field when the option list is
/// larger than ten items. Short lists keep Flutter's standard dropdown UI.
class SearchableDropdownFormField<T> extends StatelessWidget {
  const SearchableDropdownFormField({
    super.key,
    required this.options,
    required this.value,
    required this.decoration,
    this.onChanged,
    this.validator,
    this.hint,
    this.enabled = true,
    this.isExpanded = true,
    this.searchThreshold = 10,
  });

  final List<SearchableDropdownOption<T>> options;
  final T? value;
  final InputDecoration decoration;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final Widget? hint;
  final bool enabled;
  final bool isExpanded;
  final int searchThreshold;

  @override
  Widget build(BuildContext context) {
    if (options.length <= searchThreshold) {
      return DropdownButtonFormField<T>(
        value: value,
        isExpanded: isExpanded,
        decoration: decoration,
        items: options
            .map((option) => DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        onChanged: enabled ? onChanged : null,
        validator: validator,
        hint: hint,
      );
    }

    return FormField<T>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        final selected =
            options.where((option) => option.value == state.value).firstOrNull;
        final effectiveDecoration = decoration.copyWith(
          errorText: state.errorText,
          enabled: enabled,
        );
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadii.brMd,
            onTap: enabled
                ? () async {
                    final selectedValue = await _showPicker(context);
                    if (selectedValue == null) return;
                    state.didChange(selectedValue);
                    onChanged?.call(selectedValue);
                  }
                : null,
            child: InputDecorator(
              decoration: effectiveDecoration,
              isEmpty: selected == null,
              child: Row(
                children: [
                  Expanded(
                    child: selected == null
                        ? (hint ?? const SizedBox.shrink())
                        : Text(
                            selected.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const Icon(Iconsax.arrow_down_1,
                      size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<T?> _showPicker(BuildContext context) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final query = controller.text.trim().toLowerCase();
          final filtered = options
              .where((option) => option.label.toLowerCase().contains(query))
              .toList();

          return AlertDialog(
            title: const Text('Select an option'),
            content: SizedBox(
              width: 420,
              height: 420,
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search options...',
                      prefixIcon: Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No matching options.'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final option = filtered[index];
                              final isSelected = option.value == value;
                              return ListTile(
                                dense: true,
                                title: Text(option.label),
                                trailing: isSelected
                                    ? const Icon(Icons.check,
                                        color: AppColors.primary)
                                    : null,
                                onTap: () => Navigator.of(dialogContext)
                                    .pop(option.value),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      controller.dispose();
      focusNode.dispose();
    });
  }
}
