import 'dart:typed_data';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/country_state_city_picker.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../src/model/employees_model.dart';
import '../controller/employees_controller.dart';

class AddEmployeeDialog extends StatefulWidget {
  final Employee? employee; // If provided, we are in Edit Mode

  const AddEmployeeDialog({super.key, this.employee});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final EmployeeController controller = Get.isRegistered<EmployeeController>()
      ? Get.find<EmployeeController>()
      : Get.put(EmployeeController());

  final _formKey = GlobalKey<FormState>();

  // --- Step State ---
  int _currentStep = 0;
  final List<String> _steps = [
    "Personal Info",
    "Contact Address",
    "Employment",
    "Compensation",
  ];

  // --- Controllers ---
  // Step 1: Personal
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  DateTime? _dob;
  String _selectedGender = 'male';
  String _selectedMaritalStatus = 'single';
  String _nationality = 'Nigerian';

  // Step 2: Contact
  final _workEmailCtrl = TextEditingController();
  final _personalEmailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otherPhoneCtrl = TextEditingController();

  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  final _emergNameCtrl = TextEditingController();
  final _emergRelCtrl = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();

  // Step 3: Employment
  final _designationCtrl = TextEditingController();
  String _selectedEmpType = 'full-time';
  String _selectedStatus = 'active';
  DateTime? _joinDate;
  final _probationCtrl = TextEditingController();
  final _workScheduleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String? _selectedDeptId;
  String? _selectedBranchId;
  String? _selectedUnitId;
  String? _selectedLevelId;
  String? _selectedReportingToId;
  String? _selectedRoleId;

  // Step 4: Compensation
  final _basicSalaryCtrl = TextEditingController();
  String _selectedSalaryFrequency = 'monthly';
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _pensionNumberCtrl = TextEditingController();
  final _pfaProviderCtrl = TextEditingController();
  final _rsaNumberCtrl = TextEditingController();
  final _employerContribCtrl = TextEditingController();
  final _hmoPlanCtrl = TextEditingController();
  final _hmoIdCtrl = TextEditingController();
  final _hmoDependentsCtrl = TextEditingController();

  final _passwordCtrl = TextEditingController(text: 'Password@123');

  // Profile Picture
  Uint8List? _imageBytes;
  String? _imageName;
  String? _existingImageUrl; // For edit mode

  bool get isEditMode => widget.employee != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final e = widget.employee!;

    // Profile picture
    if (e.profilePicture != null &&
        e.profilePicture != 'string' &&
        e.profilePicture!.isNotEmpty) {
      _existingImageUrl = e.profilePicture;
    }

    // 1. Personal
    _firstNameCtrl.text = e.firstName;
    _lastNameCtrl.text = e.lastName;
    _middleNameCtrl.text = e.middleName ?? '';
    _dob = e.dateOfBirth;
    if (e.gender != null) _selectedGender = e.gender!;
    if (e.maritalStatus != null) _selectedMaritalStatus = e.maritalStatus!;
    if (e.nationality != null) _nationality = e.nationality!;

    // 2. Contact
    _workEmailCtrl.text = e.email;
    _phoneCtrl.text = e.phoneNumber ?? '';
    _personalEmailCtrl.text = e.personalEmail ?? '';
    _otherPhoneCtrl.text = e.otherPhoneNumber ?? '';

    _streetCtrl.text = e.streetAddress ?? e.address ?? '';
    _cityCtrl.text = e.city ?? '';
    _stateCtrl.text = e.state ?? '';
    _zipCtrl.text = e.zipCode ?? '';
    _countryCtrl.text = e.country ?? '';

    _emergNameCtrl.text = e.emergencyContactName ?? '';
    _emergRelCtrl.text = e.emergencyContactRelationship ?? '';
    _emergPhoneCtrl.text = e.emergencyContactPhone ?? '';

    // 3. Employment
    _designationCtrl.text = e.designation ?? '';
    if (e.employmentType != null) _selectedEmpType = e.employmentType!;
    _selectedStatus = e.isActive ? 'active' : 'inactive';
    _joinDate = e.startDate;
    _probationCtrl.text = e.probationPeriod ?? '';
    _workScheduleCtrl.text = e.workSchedule ?? '';
    _locationCtrl.text = e.location ?? '';

    if (e.departmentId != null) _selectedDeptId = e.departmentId.toString();
    if (e.branchId != null) _selectedBranchId = e.branchId.toString();
    if (e.departmentUnitId != null) {
      _selectedUnitId = e.departmentUnitId.toString();
    }
    if (e.levelId != null) _selectedLevelId = e.levelId.toString();
    if (e.roleId != null) _selectedRoleId = e.roleId.toString();
    if (e.reportingToId != null) {
      _selectedReportingToId = e.reportingToId.toString();
    }

    // Load units for selected department
    if (_selectedDeptId != null) {
      controller.fetchDepartmentUnits(departmentId: _selectedDeptId);
    }

    // 4. Compensation
    _basicSalaryCtrl.text = e.grossSalary?.toString() ?? '';
    if (e.salaryFrequency != null) {
      _selectedSalaryFrequency = e.salaryFrequency!;
    }
    _bankNameCtrl.text = e.bankName ?? '';
    _accountNumberCtrl.text = e.accountNumber ?? '';
    _taxIdCtrl.text = e.taxId ?? '';
    _pensionNumberCtrl.text = e.pensionNumber ?? '';
    _pfaProviderCtrl.text = e.pfaProvider ?? '';
    _rsaNumberCtrl.text = e.rsaNumber ?? '';
    _employerContribCtrl.text = e.employerContribution?.toString() ?? '';
    _hmoPlanCtrl.text = e.hmoPlan ?? '';
    _hmoIdCtrl.text = e.hmoIdNumber ?? '';
    _hmoDependentsCtrl.text = e.hmoDependentsCovered?.toString() ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _workEmailCtrl.dispose();
    _personalEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _otherPhoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    _countryCtrl.dispose();
    _emergNameCtrl.dispose();
    _emergRelCtrl.dispose();
    _emergPhoneCtrl.dispose();
    _designationCtrl.dispose();
    _probationCtrl.dispose();
    _workScheduleCtrl.dispose();
    _locationCtrl.dispose();
    _basicSalaryCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _taxIdCtrl.dispose();
    _pensionNumberCtrl.dispose();
    _pfaProviderCtrl.dispose();
    _rsaNumberCtrl.dispose();
    _employerContribCtrl.dispose();
    _hmoPlanCtrl.dispose();
    _hmoIdCtrl.dispose();
    _hmoDependentsCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
    }
  }

  Future<void> _selectDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isDob ? (_dob ?? DateTime(1990)) : (_joinDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _dob = picked;
        } else {
          _joinDate = picked;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _onSave();
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_workEmailCtrl.text.trim().isEmpty) {
      _showSnackBar(context, "Email address is required", isError: true);
      if (_currentStep != 1) setState(() => _currentStep = 1);
      return;
    }

    if (_dob == null || _joinDate == null) {
      _showSnackBar(
        context,
        "Please select valid Date of Birth and Join Date",
        isError: true,
      );
      return;
    }

    final String fullAddress =
        "${_streetCtrl.text}, ${_cityCtrl.text}, ${_stateCtrl.text}, ${_countryCtrl.text}";

    // Profile picture: keep existing URL on edit if no new image picked
    String? profilePic;
    if (_imageBytes == null && isEditMode && _existingImageUrl != null) {
      profilePic = _existingImageUrl;
    }

    final branchId = int.tryParse(_selectedBranchId ?? '');
    final deptId = int.tryParse(_selectedDeptId ?? '');
    final unitId = int.tryParse(_selectedUnitId ?? '');
    final levelId = int.tryParse(_selectedLevelId ?? '');
    final roleId = int.tryParse(_selectedRoleId ?? '');
    final reportingToId = int.tryParse(_selectedReportingToId ?? '');

    final Map<String, dynamic> data = {
      'email': _workEmailCtrl.text.trim(),
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'middle_name': _middleNameCtrl.text.trim(),
      'gender': _selectedGender,
      'marital_status': _selectedMaritalStatus,
      'nationality': _nationality,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(_dob!),
      'profile_picture': profilePic,
      'phone_number': _phoneCtrl.text,
      'other_phone': _otherPhoneCtrl.text,
      'personal_email': _personalEmailCtrl.text,
      'address': fullAddress,
      'city': _cityCtrl.text,
      'state': _stateCtrl.text,
      'zip_code': _zipCtrl.text,
      'country': _countryCtrl.text,
      'emergency_contact_name': _emergNameCtrl.text,
      'emergency_contact_relationship': _emergRelCtrl.text,
      'emergency_contact_phone': _emergPhoneCtrl.text,
      'designation': _designationCtrl.text,
      'employment_type': _selectedEmpType,
      'employment_status': _selectedStatus,
      if (branchId != null) 'branch_id': branchId,
      if (deptId != null) 'department_id': deptId,
      if (unitId != null) 'department_unit_ids': [unitId],
      if (levelId != null) 'level_id': levelId,
      if (roleId != null) 'role_id': roleId,
      'location': _locationCtrl.text,
      if (reportingToId != null) 'reporting_to_id': reportingToId,
      'start_date': DateFormat('yyyy-MM-dd').format(_joinDate!),
      'probation_period': int.tryParse(_probationCtrl.text),
      'work_schedule': _workScheduleCtrl.text,
      'is_active': _selectedStatus == 'active',
      'gross_salary': double.tryParse(_basicSalaryCtrl.text),
      'salary_frequency': _selectedSalaryFrequency,
      'allowances': {},
      'bank_name': _bankNameCtrl.text,
      'account_number': _accountNumberCtrl.text,
      'tax_id': _taxIdCtrl.text,
      'pension_number': _pensionNumberCtrl.text,
      'pfa_provider': _pfaProviderCtrl.text,
      'rsa_number': _rsaNumberCtrl.text,
      'employer_contribution': double.tryParse(_employerContribCtrl.text),
      'hmo_current_plan': _hmoPlanCtrl.text,
      'hmo_id_number': _hmoIdCtrl.text,
      'hmo_dependents_covered': int.tryParse(_hmoDependentsCtrl.text) ?? 0,
    };

    // Add password only for creation
    if (!isEditMode && _passwordCtrl.text.isNotEmpty) {
      data['password'] = _passwordCtrl.text;
    }

    if (isEditMode) {
      controller.updateEmployee(context, widget.employee!.id, data,
          imageBytes: _imageBytes, imageName: _imageName);
    } else {
      controller.createEmployee(context, data,
          imageBytes: _imageBytes, imageName: _imageName);
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (!context.mounted) return;
    AppToast.info(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        isEditMode ? 'Edit Employee' : 'Add New Employee',
                        style: AppText.displayLg,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        isEditMode
                            ? 'Update profile details for this team member.'
                            : 'Create a comprehensive profile for a new team member.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Stepper Header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  final isActive = index == _currentStep;
                  return GestureDetector(
                    onTap: () => setState(() => _currentStep = index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Column(
                        children: [
                          Text(
                            _steps[index],
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isActive)
                            Container(
                              height: 2,
                              width: 20,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Form Body
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            // Footer
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: MyOutlinedButton(
                        child: 'Previous',
                        textColor: Colors.black87,
                        onTap: () => setState(() => _currentStep--),
                      ),
                    ),
                  MyOutlinedButton(
                    child: 'Cancel',
                    textColor: Colors.red,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => MyElevatedButton(
                      child: _currentStep == 3
                          ? (controller.isSaving.value
                              ? (isEditMode ? 'Updating...' : 'Creating...')
                              : (isEditMode
                                  ? 'Update Profile'
                                  : 'Create Profile'))
                          : 'Next Step',
                      onTap: controller.isSaving.value ? null : _nextStep,
                      bgColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  // --- Step 1: Personal ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture Upload
        const MyText('Profile Picture *', size: 13, weight: 600),
        const SizedBox(height: 8),
        _buildProfilePictureZone(),
        kSizedBox,
        _buildRow([
          _buildField("First Name", _firstNameCtrl),
          _buildField("Middle Name", _middleNameCtrl),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Last Name", _lastNameCtrl),
          _buildDatePicker("Date of Birth", _dob, true),
        ]),
        kSizedBox,
        _buildRow([
          _buildDropdown(
              "Gender",
              _selectedGender,
              [
                'male',
                'female',
              ],
              (v) => setState(() => _selectedGender = v!)),
          _buildDropdown(
            "Marital Status",
            _selectedMaritalStatus,
            ['single', 'married', 'divorced'],
            (v) => setState(() => _selectedMaritalStatus = v!),
          ),
        ]),
        kSizedBox,
        _buildDropdown(
            "Nationality",
            _nationality,
            [
              'Nigerian',
              'Ghanaian',
              'Other',
            ],
            (v) => setState(() => _nationality = v!)),
        if (!isEditMode) ...[
          kSizedBox,
          _buildField("Default Password", _passwordCtrl),
        ],
      ],
    );
  }

  // --- Step 2: Contact ---
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Contact Info', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildField("Work Email", _workEmailCtrl),
          _buildField("Personal Email", _personalEmailCtrl),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Phone", _phoneCtrl),
          _buildField("Other Phone", _otherPhoneCtrl),
        ]),
        kSizedBox,
        const MyText('Current Address', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildField("Street Address", _streetCtrl),
        kSizedBox,
        CountryStateCityPicker(
          initialCountry: _countryCtrl.text.isEmpty ? null : _countryCtrl.text,
          initialState: _stateCtrl.text.isEmpty ? null : _stateCtrl.text,
          initialCity: _cityCtrl.text.isEmpty ? null : _cityCtrl.text,
          cityRequired: false,
          onCountryChanged: (name, _) => _countryCtrl.text = name,
          onStateChanged: (v) => _stateCtrl.text = v,
          onCityChanged: (v) => _cityCtrl.text = v,
        ),
        kSizedBox,
        _buildField("Zip Code", _zipCtrl),
        kSizedBox,
        const MyText('Emergency Contact (Optional)', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildField("Full Name", _emergNameCtrl),
        kSizedBox,
        _buildRow([
          _buildField("Relationship", _emergRelCtrl),
          _buildField("Phone", _emergPhoneCtrl),
        ]),
      ],
    );
  }

  // --- Step 3: Employment ---
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Role Information', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildField("Designation", _designationCtrl),
          // Department dropdown from API
          Obx(
            () => _buildApiDropdown(
              "Department",
              _selectedDeptId,
              controller.departments
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.id,
                      child: Text(d.name, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              (v) {
                setState(() {
                  _selectedDeptId = v;
                  _selectedUnitId = null; // Reset unit
                });
                if (v != null) {
                  controller.fetchDepartmentUnits(departmentId: v);
                }
              },
            ),
          ),
        ]),
        kSizedBox,
        _buildRow([
          // Unit dropdown — cascading from department
          Obx(
            () => _buildApiDropdown(
              "Unit",
              _selectedUnitId,
              controller.departmentUnits
                  .map(
                    (u) => DropdownMenuItem(
                      value: u.id,
                      child: Text(u.name, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              (v) => setState(() => _selectedUnitId = v),
            ),
          ),
          // Branch dropdown from API
          Obx(
            () => _buildApiDropdown(
              "Branch",
              _selectedBranchId,
              controller.branches
                  .map(
                    (b) => DropdownMenuItem(
                      value: b.id.toString(),
                      child: Text(
                        b.branchName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              (v) => setState(() => _selectedBranchId = v),
            ),
          ),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Location", _locationCtrl),
        ]),
        kSizedBox,
        _buildRow([
          // Reporting To dropdown from allEmployees
          Obx(
            () => _buildApiDropdown(
              "Reporting To",
              _selectedReportingToId,
              controller.allEmployees
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(
                        e.fullName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              (v) => setState(() => _selectedReportingToId = v),
            ),
          ),
          // Role dropdown from API
          Obx(
            () => _buildApiDropdown(
              "Role",
              _selectedRoleId,
              controller.roles
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id.toString(),
                      child: Text(
                        r.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              (v) => setState(() => _selectedRoleId = v),
            ),
          ),
        ]),
        kSizedBox,
        const MyText('Employment', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildDropdown(
            "Employment Type",
            _selectedEmpType,
            ['full-time', 'part-time', 'contract'],
            (v) => setState(() => _selectedEmpType = v!),
          ),
          _buildDropdown(
              "Status",
              _selectedStatus,
              [
                'active',
                'inactive',
              ],
              (v) => setState(() => _selectedStatus = v!)),
        ]),
        kSizedBox,
        _buildRow([
          _buildDatePicker("Join Date", _joinDate, false),
          _buildField("Probation Period (months)", _probationCtrl),
        ]),
        kSizedBox,
        _buildField("Work Schedule", _workScheduleCtrl),
      ],
    );
  }

  // --- Step 4: Compensation ---
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Salary Information', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildField("Gross Salary", _basicSalaryCtrl),
          _buildDropdown(
            "Salary Frequency",
            _selectedSalaryFrequency,
            ['monthly', 'weekly', 'bi-weekly', 'annually'],
            (v) => setState(() => _selectedSalaryFrequency = v!),
          ),
        ]),
        kSizedBox,
        const MyText('Bank Details', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildField("Bank Name", _bankNameCtrl),
          _buildField("Account Number", _accountNumberCtrl),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Tax ID", _taxIdCtrl),
          _buildField("Pension Number", _pensionNumberCtrl),
        ]),
        kSizedBox,
        const MyText('Pension & HMO', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildField("PFA Provider", _pfaProviderCtrl),
          _buildField("RSA Number", _rsaNumberCtrl),
        ]),
        kSizedBox,
        _buildField("Employer Contribution (%)", _employerContribCtrl),
        kSizedBox,
        _buildRow([
          _buildField("HMO Current Plan", _hmoPlanCtrl),
          _buildField("HMO ID Number", _hmoIdCtrl),
        ]),
        kSizedBox,
        _buildField("HMO Dependents Covered", _hmoDependentsCtrl),
      ],
    );
  }

  // ─── SHARED FORM WIDGETS ────────────────────────────────────────────

  Widget _buildProfilePictureZone() {
    final bool hasNewImage = _imageBytes != null;
    final bool hasExistingImage =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;

    return InkWell(
      onTap: _pickProfileImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (hasNewImage || hasExistingImage)
                ? Colors.green.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasNewImage) ...[
              // Show picked image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.memory(
                  _imageBytes!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _imageName ?? 'Image selected',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Tap to change image",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ] else if (hasExistingImage) ...[
              // Show existing image from URL
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  _existingImageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.profile_circle,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Current profile picture",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap to replace",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ] else ...[
              // Empty state — drag & drop / click
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Iconsax.document_upload,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: "Drag & Drop or ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: "choose file",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " to upload",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Supported formats: JPG, PNG, GIF (max 5MB)",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map(
            (c) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: children.indexOf(c) != children.length - 1 ? 16.0 : 0,
                ),
                child: c,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildField(String title, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        MyTextFormField(controller: ctrl, hintText: "Type"),
      ],
    );
  }

  Widget _buildDropdown(
    String title,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final safeValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// API-driven dropdown (for departments, branches, units, levels, employees)
  Widget _buildApiDropdown(
    String title,
    String? selectedValue,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    // Ensure selected value is in items, otherwise null
    final validValues = items.map((i) => i.value).toSet();
    final safeValue =
        validValues.contains(selectedValue) ? selectedValue : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          hint: Text(
            "Select $title",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String title, DateTime? date, bool isDob) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(isDob),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('yyyy-MM-dd').format(date)
                      : 'Select Date',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const Icon(Iconsax.calendar_1, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
