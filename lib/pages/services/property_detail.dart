import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/widget/add_property_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;

  final List<String> _propertyImages = [
    'assets/image/image.png',
    'assets/image/man-demo.png',
    'assets/image/image.png',
    'assets/image/man-demo.png',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              const Expanded(
                child: MyText(
                  'Property Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MyOutlinedButton(
                borderColor: AppColors.grey4,
                textColor: AppColors.grey1,
                child: 'Edit',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddPropertyDialog(),
                  );
                },
              ),
              kSizedBoxWidthSM,
              MyElevatedButton(
                child: 'Share',
                onTap: () {
                  // Share property
                },
              ),
            ],
          ),

          kSizedBox,

          // Main content
          LayoutBuilder(
            builder: (context, constraints) {
              if (isLargeScreen(context)) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildLeftSection(),
                    ),
                    kSizedBoxWidthSM,
                    Expanded(
                      flex: 2,
                      child: _buildRightSection(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildLeftSection(),
                    kSizedBox,
                    _buildRightSection(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Gallery
        _buildImageGallery(),

        kSizedBox,

        // Property Title and Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: MyText(
                'Aso Villa Estate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const MyText(
                'Available',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        kSizedBoxSM,

        // Location
        const Row(
          children: [
            Icon(Icons.location_on, size: 20, color: AppColors.grey1),
            SizedBox(width: 8),
            MyText(
              'Asokoro, Abuja, FCT',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey1,
              ),
            ),
          ],
        ),

        kSizedBox,

        // Price
        const MyText(
          '₦45,000,000',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          ),
        ),

        kSizedBox,

        // Property Features
        _buildPropertyFeatures(),

        kSizedBox,

        // Tabs Section
        _buildTabSection(),
      ],
    );
  }

  Widget _buildRightSection() {
    return Column(
      children: [
        // Contact Card
        _buildContactCard(),

        kSizedBox,

        // Quick Info Card
        _buildQuickInfoCard(),

        kSizedBox,

        // Documents Card
        _buildDocumentsCard(),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                _propertyImages[_currentImageIndex],
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
              // Navigation arrows
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: AppColors.white, size: 32),
                    onPressed: () {
                      setState(() {
                        _currentImageIndex = (_currentImageIndex - 1) %
                            _propertyImages.length;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.white, size: 32),
                    onPressed: () {
                      setState(() {
                        _currentImageIndex = (_currentImageIndex + 1) %
                            _propertyImages.length;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        kSizedBoxSM,

        // Thumbnail Images
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _propertyImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = index == _currentImageIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.blue : AppColors.grey4,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _propertyImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyFeatures() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
      ),
      child: Wrap(
        spacing: 40,
        runSpacing: 20,
        children: [
          _buildFeatureItem(Icons.bed, '5 Bedrooms'),
          _buildFeatureItem(Icons.bathtub, '4 Bathrooms'),
          _buildFeatureItem(Icons.square_foot, '500 sqm'),
          _buildFeatureItem(Icons.local_parking, '3 Parking Spaces'),
          _buildFeatureItem(Icons.calendar_today, 'Built in 2022'),
          _buildFeatureItem(Icons.home_work, 'Residential'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.blue.withValues(alpha: 0.1),
          radius: 20,
          child: Icon(icon, color: AppColors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        MyText(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.blue,
          unselectedLabelColor: AppColors.grey1,
          indicatorColor: AppColors.blue,
          tabs: const [
            Tab(text: 'Description'),
            Tab(text: 'Features'),
            Tab(text: 'Location'),
            Tab(text: 'History'),
          ],
        ),
        kSizedBoxSM,
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(),
              _buildFeaturesTab(),
              _buildLocationTab(),
              _buildHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
      ),
      child: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              'About This Property',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            MyText(
              'Luxury 5-bedroom duplex in prestigious Aso Villa Estate with modern amenities and 24/7 security. This exceptional property offers spacious living areas, contemporary finishes, and a serene environment perfect for family living.\n\n'
              'The property features a modern kitchen with state-of-the-art appliances, spacious bedrooms with en-suite bathrooms, a dedicated study room, and a beautiful garden. Located in one of Abuja\'s most sought-after neighborhoods, residents enjoy access to excellent schools, shopping centers, and recreational facilities.\n\n'
              'Built with high-quality materials and attention to detail, this home represents the perfect blend of luxury and comfort.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.grey1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              'Property Features & Amenities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            kSizedBoxSM,
            _buildFeatureList([
              'Modern fitted kitchen',
              '24/7 security',
              'Swimming pool',
              'Gym facility',
              'Children\'s playground',
              'Backup generator',
              'Water treatment plant',
              'CCTV surveillance',
              'Intercom system',
              'Paved roads',
              'Street lighting',
              'Landscaped gardens',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  size: 16, color: AppColors.blue),
              const SizedBox(width: 8),
              MyText(
                feature,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            'Location & Nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.blue),
              SizedBox(width: 8),
              Expanded(
                child: MyText(
                  'Plot 123, Asokoro District, Abuja FCT',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          MyText(
            'Nearby Landmarks:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          MyText('• Abuja Central Mosque - 2.5km'),
          MyText('• Nnamdi Azikiwe International Airport - 15km'),
          MyText('• Jabi Lake Mall - 5km'),
          MyText('• Transcorp Hilton Hotel - 3km'),
          MyText('• International School - 1.2km'),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              'Property History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            kSizedBoxSM,
            _buildTimelineItem(
              'Listed for Sale',
              'Jan 15, 2024',
              'Property listed on the market at ₦45,000,000',
              true,
            ),
            _buildTimelineItem(
              'Price Adjustment',
              'Dec 10, 2023',
              'Price reduced from ₦50,000,000 to ₦45,000,000',
              false,
            ),
            _buildTimelineItem(
              'Construction Completed',
              'Nov 2023',
              'Property construction completed and certified',
              false,
            ),
            _buildTimelineItem(
              'Construction Started',
              'Jan 2022',
              'Construction work commenced',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String date, String description, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isFirst ? AppColors.blue : AppColors.grey4,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isFirst)
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.grey4,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                MyText(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey1,
                  ),
                ),
                const SizedBox(height: 4),
                MyText(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Contact Agent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          kSizedBoxSM,
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/image/man-demo.png'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'John Okeke',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    MyText(
                      'Senior Property Agent',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          kSizedBox,
          MyElevatedButton(
            child: 'Schedule Viewing',
            onTap: () {},
          ),
          kSizedBoxSM,
          MyOutlinedButton(
            borderColor: AppColors.grey4,
            textColor: AppColors.grey1,
            child: 'Contact Agent',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Quick Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          kSizedBoxSM,
          _buildInfoRow('Property ID', 'BMS-PROP-2024-001'),
          _buildInfoRow('Type', 'Residential'),
          _buildInfoRow('Category', 'For Sale'),
          _buildInfoRow('Owner', 'Bomach Group Ltd'),
          _buildInfoRow('Listed Date', 'Jan 15, 2024'),
          _buildInfoRow('Title Status', 'Certificate of Occupancy'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey1,
            ),
          ),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          kSizedBoxSM,
          _buildDocumentItem(Icons.description, 'Title Document', '2.5 MB'),
          _buildDocumentItem(Icons.map, 'Survey Plan', '1.8 MB'),
          _buildDocumentItem(Icons.receipt, 'Building Approval', '950 KB'),
          _buildDocumentItem(Icons.assignment, 'Property Deed', '1.2 MB'),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(IconData icon, String name, String size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MyText(
                  size,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
