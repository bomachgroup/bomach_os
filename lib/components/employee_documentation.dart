import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';

class EmployeeDocumentation extends StatelessWidget{
  const EmployeeDocumentation({super.key});

  @override
  Widget build(Object context) {
return   Column(
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DocumentUpload(title: 'Upload Appointment Letter', upload: () {  },),
        // const SizedBox(width: 16,),
         DocumentUpload(title: 'Upload Salary Slips', upload: () {  },),
      ],
    ),
    const SizedBox(height: 16,),
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       DocumentUpload(title: 'Upload Reliving Letter', upload: () {  },),
        // const SizedBox(width: 16,),
        DocumentUpload(title: 'Upload Experience Letter', upload: () {  },),
      ],
    ),
  ],
);
  }
  
}

class DocumentUpload extends StatelessWidget {
  final String title;
  final VoidCallback upload;
  const DocumentUpload({
    super.key, required this.title, required this.upload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(title),
        const SizedBox(height: 8,),
        Container(
           padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all()
          ),
          // color: AppColors.secondaryColor,
          width: 496,
          child:   Column(
            children: [
              Container(
               
                decoration:  BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                width: 40,height: 40,),
              const Text('Drag & Drop or choose file to upload'),
              const Text('Supported formats : Jpeg, pdf')
            ],
          ),
        ),
      ],
    );
  }
}