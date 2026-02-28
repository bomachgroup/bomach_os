import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../src/model/employees_model.dart';
import '../controller/employees_controller.dart';

class AddEmployesScreen extends StatefulWidget {
  final String? token;
  final Employee? employee; // Optional: If provided, we are in Edit Mode

  const AddEmployesScreen({super.key, this.token, this.employee});

  @override
  State<AddEmployesScreen> createState() => _AddEmployesScreenState();
}

class _AddEmployesScreenState extends State<AddEmployesScreen> {
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
    "Compensation"
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

  String? _selectedDeptId;
  String? _selectedBranchId;
  String? _selectedUnitId;
  String? _selectedReportingTo;
  String? _selectedLocation;

  // Step 4: Compensation
  final _basicSalaryCtrl = TextEditingController();
  final _paymentFreqCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _pensionNumberCtrl = TextEditingController();

  final _passwordCtrl = TextEditingController(text: 'Password@123');

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

    // Split Address if possible, else put full in street
    if (e.address != null && e.address!.contains(',')) {
      final parts = e.address!.split(',');
      if (parts.isNotEmpty) _streetCtrl.text = parts[0].trim();
      if (parts.length > 1) _cityCtrl.text = parts[1].trim();
      if (parts.length > 2) _stateCtrl.text = parts[2].trim();
      if (parts.length > 3) _countryCtrl.text = parts[3].trim();
    } else {
      _streetCtrl.text = e.address ?? '';
    }
    
    _zipCtrl.text = e.zipCode ?? '';
    _countryCtrl.text = e.country ?? ''; // Or fallback from split

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
    
    if (e.departmentId != null) _selectedDeptId = e.departmentId.toString();
    if (e.branchId != null) _selectedBranchId = e.branchId.toString();
    
    // 4. Compensation
    _basicSalaryCtrl.text = e.grossSalary?.toString() ?? '';
    _paymentFreqCtrl.text = e.paymentFrequency ?? '';
    _bankNameCtrl.text = e.bankName ?? '';
    _accountNumberCtrl.text = e.accountNumber ?? '';
    _taxIdCtrl.text = e.taxId ?? '';
    _pensionNumberCtrl.text = e.pensionNumber ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _middleNameCtrl.dispose(); _lastNameCtrl.dispose();
    _workEmailCtrl.dispose(); _personalEmailCtrl.dispose(); _phoneCtrl.dispose(); _otherPhoneCtrl.dispose();
    _streetCtrl.dispose(); _cityCtrl.dispose(); _stateCtrl.dispose(); _zipCtrl.dispose(); _countryCtrl.dispose();
    _emergNameCtrl.dispose(); _emergRelCtrl.dispose(); _emergPhoneCtrl.dispose();
    _designationCtrl.dispose(); _probationCtrl.dispose(); _workScheduleCtrl.dispose();
    _basicSalaryCtrl.dispose(); _paymentFreqCtrl.dispose(); _bankNameCtrl.dispose(); _accountNumberCtrl.dispose(); _taxIdCtrl.dispose(); _pensionNumberCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _selectDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob 
          ? (_dob ?? DateTime(1990)) 
          : (_joinDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDob) _dob = picked; else _joinDate = picked;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null || _joinDate == null) {
      _showSnackBar(context, "Error: Please select valid Date of Birth and Join Date", isError: true);
      return;
    }

    final String fullAddress = "${_streetCtrl.text}, ${_cityCtrl.text}, ${_stateCtrl.text}, ${_countryCtrl.text}";

    final employeeData = Employee(
      // Keep ID if editing, otherwise empty string
      id: isEditMode ? widget.employee!.id : '', 
      
      email: _workEmailCtrl.text,
      password: isEditMode ? null : _passwordCtrl.text, // Don't send password on edit unless changed
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      
      // Mapped fields
      middleName: _middleNameCtrl.text,
      gender: _selectedGender,
      maritalStatus: _selectedMaritalStatus,
      nationality: _nationality,
      phoneNumber: _phoneCtrl.text,
      dateOfBirth: _dob,
      address: fullAddress,
      profilePicture: isEditMode ? widget.employee!.profilePicture : "string", // Keep existing or default
      
      // IDs
      branchId: int.tryParse(_selectedBranchId ?? '0'),
      departmentId: int.tryParse(_selectedDeptId ?? '0'),
      levelId: 0,
      
      employmentType: _selectedEmpType,
      startDate: _joinDate,
      grossSalary: double.tryParse(_basicSalaryCtrl.text) ?? 0,
      isActive: _selectedStatus == 'active',
      allowances: {},

      // Extra UI fields
      designation: _designationCtrl.text,
      probationPeriod: _probationCtrl.text,
      bankName: _bankNameCtrl.text,
      accountNumber: _accountNumberCtrl.text,
      emergencyContactName: _emergNameCtrl.text,
    );

    bool success;
    if (isEditMode) {
      // UPDATE
      success = await controller.updateEmployee(widget.token!, widget.employee!.id, employeeData);
    } else {
      // CREATE
      success = await controller.createEmployee(widget.token!, employeeData);
    }

    if (success && mounted) {
      Navigator.pop(context);
      _showSnackBar(context, isEditMode ? "Success: Profile updated" : "Success: Employee added");
    } else {
      _showSnackBar(context, "Error: Operation failed", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token == null) {
      return const Scaffold(body: Center(child: Text("No access token")));
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
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
                        style: AppText.black_600_32
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        isEditMode 
                            ? 'Update profile details for this team member.' 
                            : 'Create a comprehensive profile for a new team member.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey))
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
                              color: isActive ? const Color(0xFF0055FF) : Colors.grey.shade600,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isActive)
                            Container(height: 2, width: 20, color: const Color(0xFF0055FF))
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Form Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
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
                  Obx(() => MyElevatedButton(
                        child: _currentStep == 3
                            ? (controller.isSaving.value
                                ? (isEditMode ? 'Updating...' : 'Creating...')
                                : (isEditMode ? 'Update Profile' : 'Create Profile'))
                            : 'Next Step',
                        onTap: controller.isSaving.value ? null : _nextStep,
                        bgColor: const Color(0xFF0055FF),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ... (buildCurrentStep, buildStep1, buildStep2, buildStep3, buildStep4 remain mostly same)
  // ... (Helpers: buildRow, buildField, buildDropdown, buildDatePicker remain same)
  
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      default: return _buildStep1();
    }
  }

  // --- Step 1: Personal ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          _buildDropdown("Gender", _selectedGender, ['male', 'female'],
              (v) => setState(() => _selectedGender = v!)),
          _buildDropdown("Marital Status", _selectedMaritalStatus,
              ['single', 'married', 'divorced'],
              (v) => setState(() => _selectedMaritalStatus = v!)),
        ]),
        kSizedBox,
        _buildDropdown("Nationality", _nationality,
            ['Nigerian', 'Ghanaian', 'Other'],
            (v) => setState(() => _nationality = v!)),
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
        _buildRow([
          _buildField("City", _cityCtrl),
          _buildField("State", _stateCtrl),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Zip Code", _zipCtrl),
          _buildField("Country", _countryCtrl),
        ]),
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
          // Mock IDs for UI: In real app, load from API
          _buildDropdown("Department", _selectedDeptId ?? "Select", 
              ["Select", "1", "2"],
              (v) => setState(() => _selectedDeptId = v == "Select" ? null : v)),
        ]),
        kSizedBox,
        _buildRow([
          _buildDropdown("Unit", "Select", ["Select", "A", "B"],
              (v) => setState(() => _selectedUnitId = v)),
          _buildDropdown("Branch", _selectedBranchId ?? "Select",
              ["Select", "1", "2"],
              (v) => setState(() => _selectedBranchId = v == "Select" ? null : v)),
        ]),
        kSizedBox,
        _buildRow([
          _buildDropdown("Location", "Select", ["Select", "Remote", "On-site"],
              (v) => setState(() => _selectedLocation = v)),
          _buildDropdown("Reporting To", "Select", ["Select", "Manager A"],
              (v) => setState(() => _selectedReportingTo = v)),
        ]),
        kSizedBox,
        const MyText('Employment', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildDropdown("Employment Type", _selectedEmpType,
              ['full-time', 'part-time', 'contract'],
              (v) => setState(() => _selectedEmpType = v!)),
          _buildDropdown("Status", _selectedStatus, ['active', 'inactive'],
              (v) => setState(() => _selectedStatus = v!)),
        ]),
        kSizedBox,
        _buildRow([
          _buildDatePicker("Join Date", _joinDate, false),
          _buildField("Probation Period(months)", _probationCtrl),
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
          _buildField("Basic Salary", _basicSalaryCtrl),
          _buildDropdown("Payment Frequency", _paymentFreqCtrl.text.isNotEmpty ? _paymentFreqCtrl.text : "Select", 
              ["Select", "Monthly", "Weekly"],
              (v) => _paymentFreqCtrl.text = v!),
        ]),
        kSizedBox,
        const MyText('Bank Details', weight: 600, size: 14),
        const SizedBox(height: 16),
        _buildRow([
          _buildDropdown("Bank Name", _bankNameCtrl.text.isNotEmpty ? _bankNameCtrl.text : "Select",
              ["Select", "GTBank", "Zenith"],
              (v) => _bankNameCtrl.text = v!),
          _buildField("Account Number", _accountNumberCtrl),
        ]),
        kSizedBox,
        _buildRow([
          _buildField("Tax ID", _taxIdCtrl),
          _buildField("Pension Number", _pensionNumberCtrl),
        ]),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map((c) => Expanded(
                  child: Padding(
                padding: EdgeInsets.only(
                    right: children.indexOf(c) != children.length - 1 ? 16.0 : 0),
                child: c,
              )))
          .toList(),
    );
  }

  Widget _buildField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        MyTextFormField(controller: controller, hintText: "Type"),
      ],
    );
  }

  Widget _buildDropdown(String title, String value, List<String> items, Function(String?) onChanged) {
    // Safety check: ensure value is in items, else default to first
    final safeValue = items.contains(value) ? value : items.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: safeValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
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
                        fontSize: 14)),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}