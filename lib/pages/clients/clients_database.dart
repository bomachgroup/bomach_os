import 'package:bms_front_end/components/button/icon_button.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientsDatabasePage extends StatelessWidget {
  const ClientsDatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clients',
                    style: AppText.black_600_32,
                  ),
                  Text(
                    'Clients',
                    style: AppText.black_600_14,
                  ),
                ],
              ),
            ],
          ),
          kSizedBoxBG,
          Wrap(
            spacing: 8, // Horizontal space between items
            runSpacing: 8, // Vertical space when wrapping
            children: [
              MyElevatedButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.whiteColor,
                ),
                child: 'New Client',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const NewClientDialog();
                    },
                  );
                },
              ),
              kSizedBoxWidth,
              SizedBox(
                width: 220,
                height: 48,
                child: MyTextFormField(
                  hintText: 'Search...',
                  leading: Icon(
                    Icons.search,
                    color: AppColors.grey1.withOpacity(0.5),
                  ),
                ),
              ),
              const SortBar(
                text: 'Sort',
              ),
            ],
          ),
          kSizedBox,
          kSizedBoxSM,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: bodySpace(context),
                      ),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context),
                      ),
                    ),
                  ),
                ),
                const MyPaginator(),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Client ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Client Name",
        ),
      ),
      const DataColumn(
          label: Text(
        "Email",
      )),
      const DataColumn(
        label: Text(
          "Phone Number",
        ),
      ),
      const DataColumn(
        label: Text(
          "PJ Number",
        ),
      ),
      const DataColumn(
        label: Text(
          "Start",
        ),
      ),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
      const DataColumn(
        label: Text(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("#23456"),
        ),
        DataCell(
          onTap: () {},
          GestureDetector(
            onTap: () {
              // context.go(RouteConstants.employeeProfile);
            },
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  width: 36,
                  height: 36,
                  child: Image.asset('assets/icons/profile-icon.png'),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText("Darlene Robertson", size: 16, weight: 400),
                    MyText("Jenny group of company", size: 14, weight: 300)
                  ],
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          Text("Jennygroup45@gmail.com"),
        ),
        const DataCell(
          Text("+234 808 986 2487"),
        ),
        const DataCell(
          Text("002"),
        ),
        const DataCell(
          Text("27/09/2024"),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const ShapeDecoration(
                  color: AppColors.green2,
                  shape: OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              const Text("Active"),
            ],
          ),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}

class NewClientDialog extends StatefulWidget {
  const NewClientDialog({super.key});

  @override
  NewClientDialogState createState() => NewClientDialogState();
}

class NewClientDialogState extends State<NewClientDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1050),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.greyBg,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                color: AppColors.whiteColor,
              ),
              padding: const EdgeInsets.all(kDefaultSpaceBG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText("Jane Okoro", size: 24, weight: 600),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyIconButton(
                            icon: SvgPicture.asset("assets/svg/plus.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {},
                          ),
                          kSizedBoxWidthSM,
                          MyIconButton(
                            icon: SvgPicture.asset("assets/svg/note.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {},
                          ),
                          kSizedBoxWidthSM,
                          MyIconButton(
                            icon:
                                SvgPicture.asset("assets/svg/notification.svg"),
                            colorBackground: const Color(0xFF0055FF),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            kSizedBox,
            kSizedBoxSM,
            SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultSpaceBG),
                  child: Column(
                    children: [
                      Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ClientInfoCard(),
                          Expanded(
                            child: StatsCard(
                              title: 'Total Projects',
                              value: '1',
                              icon: SvgPicture.asset("assets/svg/database.svg"),
                            ),
                          ),
                          Expanded(
                            child: StatsCard(
                              title: 'Total Earnings',
                              value: '0',
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const SizedBox(),
                                  Positioned(
                                    left: -10,
                                    child: SvgPicture.asset(
                                        "assets/svg/naira-coin.svg"),
                                  ),
                                  Positioned(
                                    child: SvgPicture.asset(
                                        "assets/svg/naira-coin.svg"),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: StatsCard(
                              title: 'Due Invoice',
                              value: '3',
                              icon: SvgPicture.asset("assets/svg/server.svg"),
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,
                      kSizedBoxSM,
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ProfileInfoCard(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: ProjectsCard(),
                          ),
                        ],
                      ),
                      kSizedBoxBG,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientInfoCard extends StatelessWidget {
  const ClientInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          kSizedBoxSM,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  "assets/image/man-demo.png",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Miss Jane',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'Jenny group of company',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last login: 23:01, 1/10/2024',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor;

    switch (title) {
      case 'Total Projects':
        valueColor = Colors.blue;
        break;
      case 'Total Earnings':
        valueColor = Colors.blue;
        break;
      case 'Due Invoice':
        valueColor = Colors.blue;
        break;
      default:
        valueColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              icon,
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final infoItems = [
      {'label': 'Full Name', 'value': 'Jane Okoro'},
      {'label': 'Email', 'value': 'Janeokoro45@gmail.com'},
      {'label': 'Gender', 'value': 'Male'},
      {'label': 'Phone', 'value': '+234'},
      {'label': 'Company Name', 'value': 'Janeokoro45@gmail.com'},
      {'label': 'Company Phone', 'value': '+234'},
      {'label': 'Company website', 'value': 'https://'},
      {'label': 'City', 'value': 'Enugu'},
      {'label': 'Address', 'value': 'Enugu, Nigeria'},
      {'label': 'Language', 'value': 'English'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: infoItems.length,
            separatorBuilder: (context, index) => kSizedBoxSM,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      infoItems[index]['label']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      infoItems[index]['value']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProjectsCard extends StatelessWidget {
  const ProjectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.whiteColor,
        border: Border.all(
          color: AppColors.grey4,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
