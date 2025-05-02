import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class MyPaginator extends StatefulWidget {
  const MyPaginator({super.key});

  @override
  MyPaginatorState createState() => MyPaginatorState();
}

class MyPaginatorState extends State<MyPaginator> {
  int currentPage = 1;
  int totalPages = 6;
  int totalRecords = 60;
  int rowsPerPage = 10;

  List<int> rowsOptions = [10, 20, 50];

  @override
  Widget build(BuildContext context) {
    int start = ((currentPage - 1) * rowsPerPage) + 1;
    int end = (start + rowsPerPage - 1).clamp(1, totalRecords);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (!isSmallScreen(context))
              ? Row(
                  children: [
                    const MyText("Showing",
                        style: TextStyle(color: AppColors.grey2)),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int>(
                        focusColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        value: rowsPerPage,
                        underline: const SizedBox(),
                        items: rowsOptions.map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: MyText("$value"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              rowsPerPage = value;
                              currentPage = 1;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          if (isLargeScreen(context))
            MyText(
              "Showing $start to $end out of $totalRecords records",
              style: TextStyle(color: Colors.grey[600]),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
              ),
              for (int i = 1; i <= 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPage = i;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentPage == i
                              ? AppColors.blue
                              : AppColors.white,
                        ),
                        borderRadius:
                            BorderRadius.circular(currentPage == i ? 10 : 35),
                        color: currentPage == i ? null : AppColors.white,
                      ),
                      child: MyText('$i',
                          size: 14, weight: currentPage == i ? 700 : 400),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
