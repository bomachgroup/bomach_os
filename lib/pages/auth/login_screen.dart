import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor:const Color(0XFF494CA6) ,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height*0.9,
          width: MediaQuery.of(context).size.width*0.5,
          padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 40),
          decoration:  BoxDecoration(
            borderRadius: BorderRadius.circular(39),
            border: Border.all(color: AppColors.whiteColor)
          ),
          //  color: const Color(0XFF494CA6),
          child:  Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 155,
              ),
              const Text('Hellow Welcome',style: AppText.white_400_18,),
              const SizedBox(height: 18,),
              const Text('Sign In',style: AppText.white_600_32,),
              const SizedBox(height: 41,),
             
             const T_TextField(),
             const SizedBox(height: 8,),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  T_TextField(),
                        SizedBox(height: 12,),
              Text('Show Password',style: TextStyle(color: Color(0XFFE5E5E8),fontSize: 14,fontWeight: FontWeight.w400),),
                ],
              ),
              const SizedBox(height: 41,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 14),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(73),
                  color: AppColors.whiteColor
                ),
                child: const Center(child: Text('Sign In',style: TextStyle(color: Color(0XFF3E4095),fontWeight: FontWeight.w600,fontSize: 20),)),
              ),
                            const SizedBox(height: 8,),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Forget Password',style: TextStyle(color: Color(0XFFE5E5E8),fontSize: 14,fontWeight: FontWeight.w400),)),
            ],
          ),
          // width: 626,
        ),
      ),
    );
  }
}

class T_TextField extends StatelessWidget {
  const T_TextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
     width: 400,
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const Text('User ID',style: AppText.white_600_20,),
          const SizedBox(height: 8,),
          TextFormField(
           
           decoration:  InputDecoration(
             
             contentPadding: const EdgeInsets.symmetric(horizontal: 34,vertical: 15),
             hintText: 'Enter User ID',
             hintStyle: const TextStyle(color: Color(0XFFB0B0C0),fontWeight: FontWeight.w400,fontSize: 16),
             border: OutlineInputBorder(
               borderSide: BorderSide.none,
               borderRadius: BorderRadius.circular(73)
             ),
             fillColor: Colors.white,
             filled: true
           ),
          ),
        ],
      ),
    );
  }
}