import 'package:flutter/material.dart';
import 'package:restaurant_menu/assets/app_colors.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  final List<Map<String, dynamic>> sampleOrders = const [
    {
      "orderTimestamp": "August 27, 2025",
      "status": "pending",
      "totalPrice": 951,
      "items": [
        {
          "name": "Unli rice w/ 6pcs wings & fries",
          "orderPrice": 496,
          "orderQuantity": 2,
          "itemsList": [
            {"name": "Wings", "quantity": 6, "unlimited": false},
            {"name": "Fries", "quantity": 1, "unlimited": false},
            {"name": "Rice", "quantity": 1, "unlimited": true},
          ],
          "addons": [
            {"name": "Unli Iced Tea", "quantity": 1, "unlimited": true, "price": 50}
          ],
          "allergyNote": "banana",
        },
        {
          "name": "2 Servings of Pasta",
          "orderPrice": 207,
          "orderQuantity": 3,
          "itemsList": [
            {"name": "Spaghetti / Carbonara", "quantity": 2, "unlimited": false}
          ],
          "addons": [],
          "allergyNote": "no mayo",
          "selectedVariant": "Spaghetti",
        },
        {
          "name": "Unli rice w/ 6pcs wings & fries",
          "orderPrice": 248,
          "orderQuantity": 1,
          "itemsList": [
            {"name": "Wings", "quantity": 6, "unlimited": false},
            {"name": "Fries", "quantity": 1, "unlimited": false},
            {"name": "Rice", "quantity": 1, "unlimited": true},
          ],
          "addons": [
            {"name": "Unli Iced Tea", "quantity": 1, "unlimited": true, "price": 50},
            {"name": "Unli Coffee", "quantity": 1, "unlimited": true, "price": 50}
          ],
          "allergyNote": "",
        }
      ],
      "userId": "zNr7299IsUMl8cr9QKsw5vkILcW2",
      "userName": "Ans Parm"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Orders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sampleOrders.length,
        itemBuilder: (context, index) {
          final order = sampleOrders[index];
          final items = (order['items'] ?? []) as List<dynamic>;
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['orderTimestamp'],
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order['status'] == 'pending'
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order['status'].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Order Items
                  ...items.map((item) {
                    final itemsList = (item['itemsList'] ?? []) as List<dynamic>;
                    final addonsList = (item['addons'] ?? []) as List<dynamic>;
                    final orderQuantity = item['orderQuantity'] as int;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Name + Quantity
                          Text(
                            "${item['name']} x$orderQuantity",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),

                          // Display selected variant if it exists
                          if (item['selectedVariant'] != null && item['selectedVariant'] != "")
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                              child: Text(
                                "Variant: ${item['selectedVariant']}",
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ),

                          const SizedBox(height: 4),

                          // Main items
                          ...itemsList.map((i) {
                            final isUnlimited = i['unlimited'] as bool;
                            final totalQty = (i['quantity'] as int) * orderQuantity;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  i['name'],
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  isUnlimited ? "unli" : "Qty: $totalQty",
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            );
                          }).toList(),

                          // Addons Section
                          if (addonsList.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text(
                              "Addons",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            ...addonsList.map((addon) {
                              final isUnlimited = addon['unlimited'] as bool;
                              final totalQty = (addon['quantity'] as int) * orderQuantity;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    addon['name'],
                                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                                  ),
                                  Text(
                                    isUnlimited ? "unli" : "Qty: $totalQty",
                                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],

                          // Allergy Note
                          if (item['allergyNote'] != null && item['allergyNote'] != "")
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Allergy Note: ${item['allergyNote']}",
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 6),
                  Text(
                    "Total: ₱${order['totalPrice']}",
                    style: const TextStyle(
                        color: AppColors.primaryA0, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}