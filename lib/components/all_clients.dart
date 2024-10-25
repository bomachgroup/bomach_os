import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class AllClientInvoice extends StatelessWidget {
  final int count;
  const AllClientInvoice( {
    super.key, required this.count,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 16),
      decoration:  BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
           const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Client Invoice',style: AppText.black_600_16,),
                Text('View all'),
              ],
            ),
          ),
          ListView.builder(
            // scrollDirection: Axis.horizontal,
            itemCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                        color: const Color(0XFFF2F2F2),
                        image: const DecorationImage(image: AssetImage('assets/icons/file-earmark-pdf.png')),
                        borderRadius: BorderRadius.circular(6)),
                ),
                title: const Text('Invoice#1273636',style: AppText.black_600_16,),
                subtitle: const Text('Chijiokeugo@nggs',style: TextStyle(color: Color(0xFF707070),fontSize: 14,fontWeight: FontWeight.w400),),
                trailing: SizedBox(
                  width: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/icons/document-download.png'),
                      Image.asset('assets/icons/share-android.png'),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}