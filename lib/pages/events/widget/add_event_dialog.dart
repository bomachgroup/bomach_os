import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Create New Event',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyTextFormField(
                        hintText: 'Enter event title',
                        spaceBetweenText: 10,
                        title: 'Event Title*',
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: MyDropdown(
                              spaceBetweenText: 10,
                              hintText: "Select event type",
                              items: [],
                              title: 'Event Type*',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              spaceBetweenText: 10,
                              hintText: "Select priority",
                              items: [],
                              title: 'Priority',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'DD/MM/YYYY',
                              spaceBetweenText: 10,
                              title: 'Date*',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'HH:MM',
                              spaceBetweenText: 10,
                              title: 'Start Time*',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'HH:MM',
                              spaceBetweenText: 10,
                              title: 'End Time*',
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'e.g., 2 hours',
                              spaceBetweenText: 10,
                              title: 'Duration',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const MyTextFormField(
                        hintText: 'Enter event location',
                        spaceBetweenText: 10,
                        title: 'Location*',
                      ),
                      const SizedBox(height: 16),
                      const MyTextFormField(
                        hintText: 'Add event description',
                        spaceBetweenText: 10,
                        title: 'Description',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      const MyTextFormField(
                        hintText: 'Add attendees (comma separated)',
                        spaceBetweenText: 10,
                        title: 'Attendees',
                      ),
                      const SizedBox(height: 16),
                      const MyDropdown(
                        spaceBetweenText: 10,
                        hintText: "Select organizer",
                        items: [],
                        title: 'Organizer*',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (value) {},
                          ),
                          const Expanded(
                            child: MyText(
                              'Send email notifications to attendees',
                              size: 14,
                              weight: 400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (value) {},
                          ),
                          const Expanded(
                            child: MyText(
                              'Set reminder (1 day before)',
                              size: 14,
                              weight: 400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/check.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.white, BlendMode.srcIn),
                    ),
                    child: 'Create Event',
                    onTap: () {
                      // Handle event creation
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
