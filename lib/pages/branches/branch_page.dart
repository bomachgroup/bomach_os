import 'package:bms_front_end/components/custom_button.dart';
import 'package:bms_front_end/views/pages/dashboad/components/all_activities.dart';
import 'package:bms_front_end/views/pages/dashboad/components/all_clients.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class BranchPage extends StatelessWidget {
  const BranchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enugu Branch',style: AppText.black_600_32,),
                  SizedBox(height: 52,),
                   AllActivities(),
                     SizedBox(height: 40,),
                      AllClientInvoice(count: 7,),
                ],
              )),
              const SizedBox(width: 52,),
            // const Spacer(),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Company profile'),
                      const SizedBox(width: 16,),
                      CustomButton(
                        icon: const Icon(Icons.add,color: AppColors.whiteColor,),
                        child: 'New Branch', onTap: (){}),
                    ],
                  ),
                      const SizedBox(height: 16,),
                  Container(
                    width: 424,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(28)
                    ),
                    child:  const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Branch',style: AppText.black_600_32,),
                                Text('Enugu',style: AppText.black_400_14,)
                              ],
                            ),
                            Text('8:02:09 AM')
                          ],
                        ),
                        SizedBox(height: 32,),
                          Text('Today:',style: AppText.black_400_16,),
                          Text('18th November 2023',style: AppText.black_400_14,)
                      ],
                    ),
                  ),
                      const SizedBox(height: 25,),
                  Container(
                     width: 424,height: 208,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(28)
                    ),
                    child: const Column(
                      children: [],
                    ),
                  )
                ],
              ))
          ],
        )
      ],
    );
  }
}