import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_menu/assets/app_colors.dart';

import '../cart/cart_page.dart';
import '../cart/cart_provider.dart';

class FoodDetailsPage extends StatefulWidget {
  final String menuId;
  final String imageUrl;

  const FoodDetailsPage({
    super.key,
    required this.menuId,
    required this.imageUrl,
  });

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  int orderQuantity = 1;
  final TextEditingController allergyController = TextEditingController();

  Map<String, dynamic>? menuData;
  bool isLoading = true;

  Map<String, List<Map<String, dynamic>>> itemVariants = {};
  Map<String, String?> selectedVariants = {};

  // For addons
  Map<String, bool> selectedAddons = {};
  Map<String, String?> selectedAddonsVariants = {}; // FIXED

  @override
  void initState() {
    super.initState();
    fetchMenuDetails();
  }

  Future<void> fetchMenuDetails() async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('menu').doc(widget.menuId).get();

      if (doc.exists) {
        menuData = doc.data() as Map<String, dynamic>;
        await fetchVariantsForItems(menuData!['items'] ?? []);
        await fetchVariantsForAddons(menuData!['addons'] ?? []);

        // Initialize selectedAddons toggle
        final List<dynamic> addons = menuData!['addons'] ?? [];
        for (var addon in addons) {
          if (addon['inventoryId'] != null) {
            selectedAddons[addon['inventoryId']] = false;
          }
        }
      } else {
        menuData = null;
      }
    } catch (e) {
      print("Error fetching menu details: $e");
      menuData = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchVariantsForItems(List<dynamic> items) async {
    for (var item in items) {
      if (item['inventoryId'] != null) {
        String inventoryId = item['inventoryId'];
        DocumentSnapshot inventoryDoc =
        await FirebaseFirestore.instance.collection('inventory').doc(inventoryId).get();

        if (inventoryDoc.exists) {
          Map<String, dynamic> inventoryData =
          inventoryDoc.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> variants = [];
          if (inventoryData.containsKey('variants') &&
              inventoryData['variants'] is List) {
            variants = List<Map<String, dynamic>>.from(inventoryData['variants']);
          }

          int itemQty = (item['quantity'] as int?) ?? 1;

          // Only add "Both" if the item already has variants AND qty > 1
          if (itemQty > 1 && variants.isNotEmpty) {
            variants.add({'name': 'Both'});
          }

          if (variants.isNotEmpty) {
            itemVariants[inventoryId] = variants;
            selectedVariants[inventoryId] = variants.first['name'];
          }
        }
      }
    }
  }

  Future<void> fetchVariantsForAddons(List<dynamic> addons) async {
    for (var addon in addons) {
      if (addon['inventoryId'] != null) {
        String inventoryId = addon['inventoryId'];
        DocumentSnapshot inventoryDoc =
        await FirebaseFirestore.instance.collection('inventory').doc(inventoryId).get();

        if (inventoryDoc.exists) {
          Map<String, dynamic> inventoryData =
          inventoryDoc.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> variants = [];
          if (inventoryData.containsKey('variants') &&
              inventoryData['variants'] is List) {
            variants = List<Map<String, dynamic>>.from(inventoryData['variants']);
          }

          int addonQty = (addon['quantity'] as int?) ?? 1;
          if (addonQty > 1 && variants.isNotEmpty) {
            variants.add({'name': 'Both'});
          }

          if (variants.isNotEmpty) {
            itemVariants[inventoryId] = variants;
            selectedAddonsVariants[inventoryId] = variants.first['name']; // DEFAULT FIXED
          }
        }
      }
    }
  }

  double calculateOrderPrice(double basePrice) {
    double total = basePrice * orderQuantity;
    final List<dynamic> addons = menuData!['addons'] ?? [];

    for (var addon in addons) {
      if (selectedAddons[addon['inventoryId']] == true) {
        total += (addon['price'] as num).toDouble() * orderQuantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (menuData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Menu not found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final String name = menuData!['name'] ?? 'No Name';
    final double price = (menuData!['price'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> items = menuData!['items'] ?? [];
    final List<dynamic> addons = menuData!['addons'] ?? [];

    final double orderPrice = calculateOrderPrice(price);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: screenWidth, height: screenWidth, child: Image.network(widget.imageUrl, fit: BoxFit.cover)),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('₱${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white70)),
            ),
            const SizedBox(height: 12),

            /// Included Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Included Items", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                for (var item in items) ...[
                  Text("- ${item['name'] ?? ''}", style: const TextStyle(color: Colors.white70)),
                  if (item['inventoryId'] != null &&
                      itemVariants.containsKey(item['inventoryId']) &&
                      itemVariants[item['inventoryId']]!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: DropdownButton<String>(
                          value: selectedVariants[item['inventoryId']],
                          dropdownColor: AppColors.surfaceA10,
                          isExpanded: true,
                          iconEnabledColor: Colors.white,
                          underline: const SizedBox(),
                          style: const TextStyle(color: Colors.white),
                          items: itemVariants[item['inventoryId']]!.map((variant) {
                            return DropdownMenuItem<String>(
                              value: variant['name'],
                              child: Text(variant['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedVariants[item['inventoryId']] = value;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ]),
            ),

            /// Add-ons Section
            if (addons.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add-ons",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                        child: Column(
                          children: [
                            for (var addon in addons) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: selectedAddons[addon['inventoryId']] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectedAddons[addon['inventoryId']] = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primaryA0,
                                    checkColor: Colors.black,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          addon['name'],
                                          style: const TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '₱${addon['price']}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Show dropdown if addon has variants and is selected
                              if (addon['inventoryId'] != null &&
                                  itemVariants.containsKey(addon['inventoryId']) &&
                                  itemVariants[addon['inventoryId']]!.isNotEmpty &&
                                  (selectedAddons[addon['inventoryId']] ?? false))
                                Padding(
                                  padding: const EdgeInsets.only(left: 40, bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white54),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedAddonsVariants[addon['inventoryId']],
                                      dropdownColor: AppColors.surfaceA10,
                                      isExpanded: true,
                                      iconEnabledColor: Colors.white,
                                      underline: const SizedBox(),
                                      style: const TextStyle(color: Colors.white),
                                      items: itemVariants[addon['inventoryId']]!.map((variant) {
                                        return DropdownMenuItem<String>(
                                          value: variant['name'],
                                          child: Text(variant['name']),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAddonsVariants[addon['inventoryId']] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            /// Special instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Special instructions", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Please let us know if you are allergic to anything or if we need to avoid anything", style: TextStyle(fontSize: 14, color: AppColors.surfaceA50, height: 1)),
                const SizedBox(height: 8),
                TextField(
                  controller: allergyController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "e.g no mayo",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white, width: 1.5)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          /// Quantity Selector
          SizedBox(
            height: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (orderQuantity > 1) orderQuantity--;
                    });
                  },
                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.remove, color: Colors.white)),
                ),
                SizedBox(
                  width: 30,
                  child: Text('$orderQuantity', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (orderQuantity < 99) orderQuantity++;
                    });
                  },
                  child: const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.add, color: Colors.white)),
                ),
              ]),
            ),
          ),

          /// Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 50,
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(color: AppColors.primaryA0, borderRadius: BorderRadius.circular(30)),
                child: TextButton(
                  onPressed: () async {
                    String allergyNote = allergyController.text.trim();

                    await Provider.of<CartProvider>(context, listen: false).addToCart(
                      widget.menuId,
                      orderQuantity,
                      allergyNote,
                      selectedVariants,
                      selectedAddons,
                      selectedAddonsVariants,
                    );

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartPage()));
                  },
                  child: Text('Add to Cart ₱${orderPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
