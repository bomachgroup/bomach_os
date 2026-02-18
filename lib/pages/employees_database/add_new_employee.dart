import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../src/model/employees_model.dart';
import 'controller/employees_controller.dart';

class AddEmployesScreen extends StatefulWidget {
  final String? token;
  const AddEmployesScreen({super.key, this.token});

  @override
  State<AddEmployesScreen> createState() => _AddEmployesScreenState();
}

class _AddEmployesScreenState extends State<AddEmployesScreen> {
  final EmployeeController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _grossSalaryCtrl = TextEditingController();

  String _selectedGender = 'male';
  String _selectedMaritalStatus = 'single';
  String _selectedEmploymentType = 'full-time';

  DateTime? _dob;
  DateTime? _startDate;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _grossSalaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _dob = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_dob == null || _startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select valid dates"),
              backgroundColor: Colors.red),
        );
        return;
      }

      final newEmployee = Employee(
        id: '',
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        phoneNumber: _phoneCtrl.text,
        dateOfBirth: _dob,
        address: _addressCtrl.text,
        profilePicture:
            "https://d1yzddjh14f4tu.cloudfront.net/b46ad0ba-3fef-4a0a-9b66-9e040e96c97f.jpeg",
        employmentType: _selectedEmploymentType,
        branchId: null,
        departmentId: null,
        levelId: null,
        startDate: _startDate,
        isActive: true,
        grossSalary: double.tryParse(_grossSalaryCtrl.text) ?? 0,
        allowances: {},
      );

      final success = await controller.createEmployee(
        widget.token!,
        newEmployee,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Employee added successfully"),
              backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed: ${controller.errorMessage.value}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token == null) {
      return const Center(
        child: MyText('No access to this feature', style: AppText.black_500_16),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const MyText('Personal Information',
                    style: AppText.black_600_16),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: MyTextFormField(
                  title: 'First Name',
                  controller: _firstNameCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                )),
                const SizedBox(width: 16),
                Expanded(
                    child: MyTextFormField(
                  title: 'Last Name',
                  controller: _lastNameCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                )),
              ],
            ),
            kSizedBox,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText('Gender', size: 14, weight: 500),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                              value: 'female', child: Text('Female')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedGender = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText('Marital Status', size: 14, weight: 500),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMaritalStatus,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(
                              value: 'single', child: Text('Single')),
                          DropdownMenuItem(
                              value: 'married', child: Text('Married')),
                          DropdownMenuItem(
                              value: 'divorced', child: Text('Divorced')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedMaritalStatus = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kSizedBox,
            MyTextFormField(
                title: 'Email Address',
                controller: _emailCtrl,
                validator: (v) => v!.isEmail ? null : 'Invalid email'),
            kSizedBox,
            MyTextFormField(
                title: 'Password',
                controller: _passwordCtrl,
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
            kSizedBox,
            MyTextFormField(title: 'Phone Number', controller: _phoneCtrl),
            kSizedBox,
            MyTextFormField(title: 'Address', controller: _addressCtrl),
            kSizedBox,
            const MyText('Date of Birth',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_dob != null
                    ? DateFormat('yyyy-MM-dd').format(_dob!)
                    : 'Select Date'),
              ),
            ),
            const SizedBox(height: 32),
            const MyText('Professional Information',
                style: AppText.black_600_16),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText('Employment Type', size: 14, weight: 500),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedEmploymentType,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(
                        value: 'full-time', child: Text('Full-Time')),
                    DropdownMenuItem(
                        value: 'part-time', child: Text('Part-Time')),
                    DropdownMenuItem(
                        value: 'contract', child: Text('Contract')),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedEmploymentType = val!),
                ),
              ],
            ),
            kSizedBox,
            MyTextFormField(
                title: 'Gross Salary',
                controller: _grossSalaryCtrl,
                keyboardType: TextInputType.number),
            kSizedBox,
            const MyText('Start Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_startDate != null
                    ? DateFormat('yyyy-MM-dd').format(_startDate!)
                    : 'Select Date'),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyOutlinedButton(
                  textColor: AppColors.darkGrey1,
                  child: 'Cancel',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Obx(() => MyElevatedButton(
                      child: controller.isSaving.value
                          ? 'Saving...'
                          : 'Add Employee',
                      onTap: controller.isSaving.value ? null : _submit,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:bms_front_end/components/button/my_elevated_button.dart';
// import 'package:bms_front_end/components/button/my_outlined_button.dart';
// import 'package:bms_front_end/components/nav/employee_stepper.dart';
// import 'package:bms_front_end/components/text/my_text.dart';
// import 'package:bms_front_end/pages/employees_database/widget/employee_documentation.dart';
// import 'package:bms_front_end/pages/employees_database/widget/personal_info.dart';
// import 'package:bms_front_end/pages/employees_database/widget/professional_info.dart';
// import 'package:bms_front_end/src/constants/colors.dart';
// import 'package:bms_front_end/src/constants/spaces.dart';
// import 'package:bms_front_end/src/constants/textstyle.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:go_router/go_router.dart';

// class AddEmployesScreen extends StatefulWidget {
//   const AddEmployesScreen({
//     super.key,
//   });

//   @override
//   State<AddEmployesScreen> createState() => _AddEmployesScreenState();
// }

// class _AddEmployesScreenState extends State<AddEmployesScreen> {
//   final List<Widget> _pages = [
//     const PersonalInformation(),
//     const ProfessionalInformation(),
//     const EmployeeDocumentation(),
//   ];
//   int selectionStepperState = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         MyText(
//           'Employee’s Database',
//           style: AppText.black_600_32,
//           onTap: () {
//             context.pop();
//           },
//         ),
//         const Row(
//           children: [
//             MyText(
//               'Employee’s Database',
//               style: AppText.black_400_14,
//             ),
//             kSizedBoxWidthSM,
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 12,
//             ),
//             kSizedBoxWidthSM,
//             MyText(
//               'Add New Employee',
//               style: AppText.black_400_14,
//             ),
//           ],
//         ),
//         kSizedBoxBG,
//         Container(
//           padding: const EdgeInsets.all(26),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(width: 0.6, color: AppColors.border)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       EmployeeInfoStepper(
//                         isActive: selectionStepperState == 0,
//                         icon: SvgPicture.asset(
//                           "assets/svg/person.svg",
//                         ),
//                         activeIcon: SvgPicture.asset(
//                           "assets/svg/person-filled.svg",
//                         ),
//                         title: 'Personal Information',
//                         onTap: () {
//                           setState(() {
//                             selectionStepperState = 0;
//                           });
//                         },
//                       ),
//                       kSizedBoxWidth,
//                       EmployeeInfoStepper(
//                         isActive: selectionStepperState == 1,
//                         icon: SvgPicture.asset(
//                           "assets/svg/briefcase.svg",
//                         ),
//                         activeIcon: SvgPicture.asset(
//                           "assets/svg/briefcase-filled.svg",
//                         ),
//                         title: 'Professional Information',
//                         onTap: () {
//                           setState(() {
//                             selectionStepperState = 1;
//                           });
//                         },
//                       ),
//                       kSizedBoxWidth,
//                       EmployeeInfoStepper(
//                         isActive: selectionStepperState == 2,
//                         icon: SvgPicture.asset(
//                           "assets/svg/document.svg",
//                         ),
//                         activeIcon: SvgPicture.asset(
//                           "assets/svg/document-filled.svg",
//                         ),
//                         title: 'Documents',
//                         onTap: () {
//                           setState(() {
//                             selectionStepperState = 2;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               kSizedBoxBG,
//               _pages[selectionStepperState],
//               kSizedBoxBG,
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   MyOutlinedButton(
//                     textColor: AppColors.black,
//                     bgColor: AppColors.greyBg,
//                     child: 'Cancel',
//                     onTap: () {},
//                   ),
//                   const SizedBox(width: 16),
//                   MyElevatedButton(
//                     child: 'Next',
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
