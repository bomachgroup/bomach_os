// import 'package:bms_front_end/components/button/my_elevated_button.dart';
// import 'package:bms_front_end/components/button/my_outlined_button.dart';
// import 'package:bms_front_end/components/input/my_dropdown.dart';
// import 'package:bms_front_end/components/input/my_textformfield.dart';
// import 'package:bms_front_end/components/text/my_text.dart';
// import 'package:bms_front_end/pages/hr/models/attendance_models.dart';
// import 'package:bms_front_end/src/constants/colors.dart';
// import 'package:bms_front_end/src/constants/spaces.dart';
// import 'package:bms_front_end/src/constants/textstyle.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../controller/biometrics_controller.dart';

// class ClockInDialog extends StatefulWidget {
//   final Function(AttendanceRecord)? onClockIn;
//   final bool isClockedIn;

//   const ClockInDialog({
//     super.key,
//     this.onClockIn,
//     this.isClockedIn = false,
//   });

//   @override
//   State<ClockInDialog> createState() => _ClockInDialogState();
// }

// class _ClockInDialogState extends State<ClockInDialog> {
//   late TextEditingController _employeeIdController;
//   late TextEditingController _employeeNameController;
//   late TextEditingController _notesController;
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _checkInTime = TimeOfDay.now();
//   TimeOfDay? _checkOutTime;
//   String _selectedStatus = 'Present';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _employeeIdController = TextEditingController();
//     _employeeNameController = TextEditingController();
//     _notesController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _employeeIdController.dispose();
//     _employeeNameController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//     if (pickedDate != null && pickedDate != _selectedDate) {
//       setState(() {
//         _selectedDate = pickedDate;
//       });
//     }
//   }

//   Future<void> _selectCheckInTime(BuildContext context) async {
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _checkInTime,
//     );
//     if (pickedTime != null && pickedTime != _checkInTime) {
//       setState(() {
//         _checkInTime = pickedTime;
//       });
//     }
//   }

//   Future<void> _selectCheckOutTime(BuildContext context) async {
//     final pickedTime = await showTimePicker(
//       context: context,
//       initialTime: _checkOutTime ?? TimeOfDay.now(),
//     );
//     if (pickedTime != null && pickedTime != _checkOutTime) {
//       setState(() {
//         _checkOutTime = pickedTime;
//       });
//     }
//   }

//   void _handleClockIn() async {
//     if (_employeeIdController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: MyText('Employee ID is required')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final token = await _getToken(context);
//     if (token == null) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: MyText('Authentication token not found')),
//         );
//       }
//       return;
//     }

//     final checkInDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _checkInTime.hour,
//       _checkInTime.minute,
//     );

//     final checkOutDateTime = _checkOutTime != null
//         ? DateTime(
//             _selectedDate.year,
//             _selectedDate.month,
//             _selectedDate.day,
//             _checkOutTime!.hour,
//             _checkOutTime!.minute,
//           )
//         : null;

//     final attendanceRecord = AttendanceRecord(
//       id: '',
//       employeeId: _employeeIdController.text,
//       date: _selectedDate,
//       checkInTime: checkInDateTime,
//       checkOutTime: checkOutDateTime,
//       status: _selectedStatus,
//       notes: _notesController.text.isEmpty ? null : _notesController.text,
//       location: 'Manual Entry',
//     );

//     final BiometricsController controller = Get.find<BiometricsController>();
//     final success =
//         await controller.createManualAttendance(token, attendanceRecord);

//     if (mounted) {
//       setState(() => _isLoading = false);

//       if (success) {
//         widget.onClockIn?.call(attendanceRecord);
//         Navigator.of(context).pop(attendanceRecord);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: MyText('Attendance recorded successfully'),
//             backgroundColor: Color(0xFF2DAB03),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content:
//                 MyText('Failed to record: ${controller.errorMessage.value}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<String?> _getToken(BuildContext context) async {
//     const storage = FlutterSecureStorage();
//     String? token = await storage.read(key: 'access_token');
//     if (token == null) return null;
//     if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
//     return token.replaceAll('"', '').trim();
//   }

//   String _formatTimeOfDay(TimeOfDay time) {
//     final hours = time.hour.toString().padLeft(2, '0');
//     final minutes = time.minute.toString().padLeft(2, '0');
//     return '$hours:$minutes';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: AppColors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 846),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Colors.grey.shade300,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.blue.withValues(alpha: 0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.access_time,
//                           color: AppColors.blue,
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const MyText(
//                         'Clock In/Out',
//                         style: AppText.black_500_20,
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 16,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     MyTextFormField(
//                                       hintText: 'e.g., EMP001',
//                                       controller: _employeeIdController,
//                                       spaceBetweenText: 10,
//                                       title: 'Employee ID',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     MyTextFormField(
//                                       spaceBetweenText: 10,
//                                       hintText: "Enter employee name",
//                                       controller: _employeeNameController,
//                                       title: 'Employee Name',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           kSizedBox,
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const MyText(
//                                       'Date',
//                                       style: AppText.black_600_14,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     GestureDetector(
//                                       onTap: () => _selectDate(context),
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: const Color(0XFFD5D5D5),
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           color: Colors.grey.shade50,
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             MyText(
//                                               DateFormat('MMM dd, yyyy')
//                                                   .format(_selectedDate),
//                                               style: AppText.black_400_14,
//                                             ),
//                                             const Icon(
//                                               Icons.calendar_today,
//                                               size: 18,
//                                               color: AppColors.blue,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const MyText(
//                                       'Check-in Time',
//                                       style: AppText.black_600_14,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     GestureDetector(
//                                       onTap: () => _selectCheckInTime(context),
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: const Color(0XFFD5D5D5),
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           color: Colors.grey.shade50,
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             MyText(
//                                               _formatTimeOfDay(_checkInTime),
//                                               style: AppText.black_400_14,
//                                             ),
//                                             const Icon(
//                                               Icons.access_time,
//                                               size: 18,
//                                               color: AppColors.blue,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           kSizedBox,
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const MyText(
//                                       'Check-out Time (Optional)',
//                                       style: AppText.black_600_14,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     GestureDetector(
//                                       onTap: () => _selectCheckOutTime(context),
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 12,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: const Color(0XFFD5D5D5),
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           color: Colors.grey.shade50,
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             MyText(
//                                               _checkOutTime != null
//                                                   ? _formatTimeOfDay(
//                                                       _checkOutTime!)
//                                                   : '---',
//                                               style: AppText.black_400_14,
//                                             ),
//                                             const Icon(
//                                               Icons.access_time,
//                                               size: 18,
//                                               color: AppColors.blue,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     MyDropdown(
//                                       items: const [
//                                         'Present',
//                                         'Absent',
//                                         'Late',
//                                         'Early Leave',
//                                         'On Leave',
//                                         'Half Day',
//                                         'Remote'
//                                       ],
//                                       onChanged: (value) {
//                                         setState(() {
//                                           _selectedStatus = value ?? 'Present';
//                                         });
//                                       },
//                                       spaceBetweenText: 10,
//                                       hintText: _selectedStatus,
//                                       title: 'Status',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           kSizedBox,
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               MyTextFormField(
//                                 hintText: "Add any notes or remarks",
//                                 controller: _notesController,
//                                 spaceBetweenText: 10,
//                                 maxLines: 3,
//                                 title: 'Notes (Optional)',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               decoration: BoxDecoration(
//                 border: Border(
//                   top: BorderSide(color: Colors.grey.shade300),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   MyOutlinedButton(
//                     textColor: AppColors.darkGrey1,
//                     borderColor: null,
//                     child: 'Cancel',
//                     onTap: _isLoading
//                         ? null
//                         : () {
//                             Navigator.pop(context);
//                           },
//                   ),
//                   const SizedBox(width: 16),
//                   MyElevatedButton(
//                     icon: _isLoading
//                         ? null
//                         : SvgPicture.asset(
//                             "assets/svg/check.svg",
//                             colorFilter: const ColorFilter.mode(
//                                 AppColors.white, BlendMode.srcIn),
//                           ),
//                     child: _isLoading ? 'Processing...' : 'Clock In',
//                     onTap: _isLoading ? null : _handleClockIn,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
