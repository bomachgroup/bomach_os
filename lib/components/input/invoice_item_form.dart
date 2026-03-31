import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class InvoiceItem {
  String description;
  int quantity;
  double unitPrice;

  InvoiceItem({this.description = '', this.quantity = 0, this.unitPrice = 0.0});

  double get subTotal => quantity * unitPrice;
}

class InvoiceTable extends StatefulWidget {
  const InvoiceTable({super.key});

  @override
  State<InvoiceTable> createState() => _InvoiceTableState();
}

class _InvoiceTableState extends State<InvoiceTable> {
  final List<InvoiceItem> items = [
    InvoiceItem(),
    InvoiceItem(),
    InvoiceItem(),
  ];

  void _addItem() {
    setState(() {
      items.add(InvoiceItem());
    });
  }

  double get totalSubTotal {
    return items.fold(0.0, (sum, item) => sum + item.subTotal);
  }

  Widget _buildRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // S/N - Circular container
          SizedBox(
            width: 60,
            height: 60,
            child: MyTextFormField(
              readOnly: true,
              textAlign: TextAlign.center,
              onTap: null,
              spaceBetweenText: 10,
              hintText: '${index + 1}',
            ),
          ),
          const SizedBox(width: 12),

          // Description - Large rounded container
          const Expanded(
            flex: 4,
            child: SizedBox(
              height: 60,
              child: MyTextFormField(
                spaceBetweenText: 10,
                hintText: '- - - -',
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Quantity - Rounded container
          const SizedBox(
            width: 120,
            height: 60,
            child: MyTextFormField(
              spaceBetweenText: 10,
              hintText: '- - - -',
            ),
          ),
          const SizedBox(width: 12),

          // Unit Price - Rounded container
          const SizedBox(
            width: 120,
            height: 60,
            child: MyTextFormField(
              spaceBetweenText: 10,
              hintText: '- - - -',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'S/N',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Unite Price',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Rows
          ...List.generate(items.length, (index) => _buildRow(index)),

          const SizedBox(height: 20),

          // Bottom section with Add button and Sub Total
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Add Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),
              Text(
                'Sub Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                height: 60,
                width: 120,
                child: MyTextFormField(
                  spaceBetweenText: 10,
                  hintText: '- - - -',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
