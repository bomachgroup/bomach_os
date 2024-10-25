// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bms_front_end/views/pages/dashboad/components/all_activities.dart';
import 'package:bms_front_end/views/pages/dashboad/components/all_clients.dart';
import 'package:bms_front_end/views/pages/dashboad/components/all_projects.dart';
import 'package:bms_front_end/views/pages/dashboad/components/project_chart.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return   Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 4,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text(
                    'Welcome to Admin Dashboard,',
                    style: AppText.black_600_32,
                  ),
                  const SizedBox(height: 20,),
                  const AllActivities(),
                  const SizedBox(
                    height: 26,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Project',
                        style: AppText.black_500_24,
                      ),
                      GestureDetector(
                        // onTap:(){
                        //   Navigator.of(context).push(MaterialPageRoute(builder: (context){}))
                        // },
                        child: const Text(
                          'View All',
                          style: AppText.blue_600_16,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const AllProjects(),
               
                ],
              ),
            )),
        const SizedBox(
          width: 27,
        ),
        Expanded(
            flex: 2,
            child: Container(
              child: Column(
                children: [
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                         const Column(
                              children: [
              Text('2:45pm'),
              Text('Wednesday'),
                              ],
                        ),
                         const SizedBox(
                      width: 19,
                    ),
                    Column(
                      children: [
                        const Text('Branch'),
                        Row(
                              children: [const Text('Enugu'), 
                              const SizedBox(width: 6,),
                              Image.asset('assets/icons/arrowDownOutline.png')],
                        ),
                      ],
                    ),
                      ],
                    ),
                    const SizedBox(height: 49,),
                  const ProjectChart(),
                  const SizedBox(
                    height: 20,
                  ),
                  const AllClientInvoice(count: 5,),
                ],
              ),
            ))
      ],
    );
  }
}






