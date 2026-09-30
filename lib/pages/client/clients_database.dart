import 'package:bomach_os/components/button/icon_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/button/sort_bar.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientsDatabasePage extends StatefulWidget {
  const ClientsDatabasePage({super.key});

  @override
  State<ClientsDatabasePage> createState() => _ClientsDatabasePageState();
}

class _ClientsDatabasePageState extends State<ClientsDatabasePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Clients',
                      style: AppTextStyles.displayLg,
                    ),
                    MyText(
                      'Clients',
                      style: AppTextStyles.h4,
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
                    Iconsax.add_circle,
                    color: AppColors.white,
                  ),
                  child: 'New Client',
                  onTap: () {},
                ),
                kSizedBoxWidth,
                SizedBox(
                  width: 220,
                  height: 48,
                  child: MyTextFormField(
                    hintText: 'Search...',
                    leading: Icon(
                      Iconsax.search_normal,
                      color: AppColors.neutral500.withValues(alpha: 0.5),
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
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
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
                          showBottomBorder: true,
                        ),
                      ),
                    ),
                  ),
                  // const PaginatorFooter(),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Client ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Client Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Email",
      )),
      const DataColumn(
        label: MyText(
          "Phone Number",
        ),
      ),
      const DataColumn(
        label: MyText(
          "PJ Number",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Start",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          MyText("#23456"),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return const NewClientDialog();
              },
            );
          },
          Row(
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
                  MyText(
                    "Darlene Robertson",
                    size: 16,
                    weight: 400,
                    isSelectable: false,
                  ),
                  MyText("Jenny group of company", size: 14, weight: 300)
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          MyText("Jennygroup45@gmail.com"),
        ),
        const DataCell(
          MyText("+234 808 986 2487"),
        ),
        const DataCell(
          MyText("002"),
        ),
        const DataCell(
          MyText("27-09-2024"),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const ShapeDecoration(
                  color: AppColors.success,
                  shape: OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              const MyText("Active"),
            ],
          ),
        ),
        const DataCell(
          ThreeDotPop(),
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
          color: AppColors.background,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(kDefaultSpaceBG),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.spaceBetween,
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
                                  colorBackground: AppColors.primary,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const AddInvoiceDialog();
                                      },
                                    );
                                  },
                                ),
                                kSizedBoxWidthSM,
                                MyIconButton(
                                  icon:
                                      SvgPicture.asset("assets/svg/note2.svg"),
                                  colorBackground: AppColors.primary,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const InvoiceContent();
                                      },
                                    );
                                  },
                                ),
                                kSizedBoxWidthSM,
                                MyIconButton(
                                  icon: SvgPicture.asset(
                                      "assets/svg/notification.svg"),
                                  colorBackground: AppColors.primary,
                                  onPressed: () {},
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 600,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kDefaultSpaceBG, vertical: kDefaultSpaceBG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kSizedBox,
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              runSpacing: 15,
                              spacing: 15,
                              children: [
                                const ClientInfoCard(),
                                StatsCard(
                                  title: 'Total Projects',
                                  value: '1',
                                  icon: SvgPicture.asset(
                                      "assets/svg/database.svg"),
                                ),
                                StatsCard(
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
                                StatsCard(
                                  title: 'Due Invoice',
                                  value: '3',
                                  icon:
                                      SvgPicture.asset("assets/svg/server.svg"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,
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
      width: !isLargeScreen(context) ? double.infinity : 400,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neutral300,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(
                      'Miss Jane',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const MyText(
                      'Jenny group of company',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      'Last login: 23:01, 10-01-2024',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
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
    return Container(
      width: !isLargeScreen(context) ? double.infinity : 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.white,
        border: Border.all(
          color: AppColors.neutral300,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
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
              MyText(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryHover,
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
        color: AppColors.white,
        border: Border.all(
          color: AppColors.neutral300,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
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
                    child: MyText(
                      infoItems[index]['label']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: MyText(
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
        color: AppColors.white,
        border: Border.all(
          color: AppColors.neutral300,
          width: 0.6,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
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

class InvoiceContent extends StatelessWidget {
  const InvoiceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(kDefaultSpaceBG),
          constraints: const BoxConstraints(maxWidth: 595),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo
              Image.asset(
                "assets/logo/bomach.png",
                height: 129,
                width: 175,
              ),

              kSizedBox,

              // Invoice Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Invoice Title & Number
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          'INVOICE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          '#794653',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Invoice Dates
                  const Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MyText(
                                'Bill date: 02-08-2024',
                                maxLines: 3,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            kSizedBoxWidthSM,
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: MyText(
                                'Due: 12-08-2024',
                                maxLines: 3,
                                // overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // FROM, TO, INFO Section
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FROM Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          'FROM:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(height: 8),
                        MyText(
                          'Bomach group',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        MyText(
                          'Suite 9 Swiss Guard Plaza,450 Ogui Road,\nEnugu state, Nigeria.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: AppColors.neutral400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TO Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          'TO:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(height: 8),
                        MyText(
                          'Jenny group',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        MyText(
                          'plot 2,\n6 Kelly Rd, Uwani\nEnugu, Nigeria',
                          style: TextStyle(
                            color: AppColors.neutral400,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // INFO Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          'INFO:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        InfoRow(label: 'Account number:', value: '0978984573'),
                        InfoRow(label: 'Account name:', value: 'Jonesy'),
                        InfoRow(label: 'Bank name:', value: 'First Bank'),
                        InfoRow(label: 'Phone:', value: '+234 806 558 7786'),
                        InfoRow(label: 'Email:', value: 'Jonesy@gmail.com'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Services Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    // Table Header
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: MyText(
                              'QUANTITY',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: MyText(
                              'SERVICE',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: MyText(
                              'COST',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1),

                    // Service Item 1
                    ServiceItem(
                      quantity: '1',
                      service: 'LAND SURVEY',
                      description: '2sq meter',
                      cost: '\$ 4000',
                    ),

                    Divider(height: 1),

                    // Service Item 2
                    ServiceItem(
                      quantity: '1',
                      service: 'REAL ESTATE',
                      description: '5 bedroom duplex',
                      cost: '\$ 2000',
                    ),

                    Divider(height: 1),

                    // Service Item 3
                    ServiceItem(
                      quantity: '1',
                      service: 'SURVEY PLANNING',
                      description: '---',
                      cost: '\$ 1000',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Totals
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.background,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Total
                            MyText(
                              'TOTAL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Subtotal
                            MyText(
                              'SUBTOTAL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),

                            SizedBox(height: 8),

                            // Tax
                            MyText(
                              'TAX',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Total
                            MyText(
                              '\$ 7000',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Subtotal
                            MyText(
                              '\$ 7000',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),

                            SizedBox(height: 8),

                            MyText(
                              '\$ 000',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral400,
            ),
          ),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String quantity;
  final String service;
  final String description;
  final String cost;

  const ServiceItem({
    super.key,
    required this.quantity,
    required this.service,
    required this.description,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                kSizedBoxWidth,
                MyText(
                  quantity,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                MyText(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              cost,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({super.key});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Invoice Form',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Form fields
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Start and End dates
                      Row(
                        children: [
                          // Start date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  hintText: '-----',
                                  spaceBetweenText: 10,
                                  title: 'Company/customer Name',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // End date
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.neutral500,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/note.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.white, BlendMode.srcIn),
                    ),
                    child: 'Generate',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
