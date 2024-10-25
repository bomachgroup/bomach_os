import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectOverview extends StatelessWidget {
  const ProjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
               height: 150,
              padding: const EdgeInsets.all(20),
              decoration:  BoxDecoration(
                border: Border.all(width: 1,color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(24)
              ),
              child:  Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Project progress',style: AppText.black_500_16,),
                      const SizedBox(height: 10,),
                       CircularPercentIndicator(
                        startAngle: 180,
                        percent: 0.67,
                        center: const Text('67%'),
                        lineWidth: 15.0,
                        radius: 36,),
                        
                    ],
                  ),
                  const SizedBox(width: 24,),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Start date'),
                          SizedBox(height: 8,),
                            Text('12/10/2023')
                        ],
                      ),
                      SizedBox(width: 21,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            Text('Due date'),
                            SizedBox(height: 8,),
                              Text('02/02/2025')
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 20,),
             Container(
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 18),
              decoration:  BoxDecoration(
                border: Border.all(width: 1,color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(24)
              ),
              child: const Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Client',style: AppText.black_500_16,),
                   SizedBox(height: 16,),
                   Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                      ),
                      SizedBox(width: 24,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Miss Jane'),
                          Text('Jenny group of company'),
                        ],
                      )
                    ],
                   )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32,),
        const Text('Statistics',style: AppText.black_500_20,),
          const SizedBox(height: 16,),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ProjectExpenceTrack(expence: 'Project Buldget', amount: 0.00,),
                SizedBox(width: 20,),
                 ProjectExpenceTrack(expence: 'Expenses', amount: 0.00,),
                SizedBox(width: 20,),
                 ProjectExpenceTrack(expence: 'Earnings', amount: 0.00,),
                SizedBox(width: 20,),
                 ProjectExpenceTrack(expence: 'Profit', amount: 0.00,),
                SizedBox(width: 20,),
              ],
            ),
          )
      ],
    );
  }
}

class ProjectExpenceTrack extends StatelessWidget {
  final String expence;
  final double amount;
    const ProjectExpenceTrack({
    super.key, required this.expence, required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 283,
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(width: 1,color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(21)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expence,style: AppText.black_500_20,),
           const SizedBox(height: 5,),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 44,height: 44,
              decoration: const BoxDecoration(
                color: AppColors.borderColor,
                shape: BoxShape.circle
              ),
            ),
          ),
           const SizedBox(height: 5,),
          const Text('0.00')
        ],
      ),
    );
  }
}
