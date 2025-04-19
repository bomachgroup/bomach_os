// import 'package:flutter/material.dart';

// class FormTextField extends StatelessWidget {
//   final String? title, hintText;
//   const FormTextField({
//     super.key,
//     this.title,
//     required this.hintText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 400,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (title != null) ...[
//             Text(
//               title!,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//           ],
//           TextFormField(
//             decoration: InputDecoration(
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 34, vertical: 15),
//               hintText: hintText,
//               hintStyle: const TextStyle(
//                   color: Color(0XFFB0B0C0),
//                   fontWeight: FontWeight.w400,
//                   fontSize: 14),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(73)),
//               fillColor: Colors.white,
//               filled: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
