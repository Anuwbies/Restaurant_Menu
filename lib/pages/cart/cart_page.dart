import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../assets/app_colors.dart';
import 'cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            'Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: cartProvider.cartItems.isEmpty
          ? const Center(
        child: Text(
          'Your cart is empty',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: cartProvider.cartItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              return Card(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Item Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80', // Example placeholder image
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 6),

                      Expanded(
                        child: SizedBox(
                          height: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // ✅ Append selected variant after the item name
                                '${item['name']}${item['selectedVariants'] != null && item['selectedVariants'].isNotEmpty ? " (${item['selectedVariants']})" : ""}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // ✅ Show chosen addons under main item
                              if (item['addons'] != null && item['addons'].isNotEmpty)
                                Text(
                                  '+ ${item['addons'].map((addon) {
                                    final variant = addon['selectedVariant'] != null &&
                                        addon['selectedVariant'].toString().isNotEmpty
                                        ? " (${addon['selectedVariant']})"
                                        : "";
                                    return "${addon['name']}$variant";
                                  }).join(", ")}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                    color: Colors.lightGreenAccent,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              const SizedBox(height: 3),
                              if (item['allergyNote'] != null &&
                                  item['allergyNote'].isNotEmpty)
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  'Note: ${item['allergyNote']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              const SizedBox(height: 3),
                              Text(
                                '₱${(item['orderPrice']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      // Quantity control
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                              color: AppColors.primaryA0, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          spacing: 5,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (item['orderQuantity'] < 99) {
                                  cartProvider.updateQuantity(
                                      index, item['orderQuantity'] + 1);
                                }
                              },
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 22),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${item['orderQuantity']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (item['orderQuantity'] > 1) {
                                  cartProvider.updateQuantity(
                                      index, item['orderQuantity'] - 1);
                                } else {
                                  cartProvider.removeItem(index);
                                }
                              },
                              child: Icon(
                                item['orderQuantity'] == 1
                                    ? Icons.delete
                                    : Icons.remove,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Colors.white, width: 1.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Cart total price
            Text(
              'Total: ₱${cartProvider.totalOrderPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Check out button
            SizedBox(
              height: 50,
              width: 150,
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryA0,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: () async {
                    if (cartProvider.cartItems.isNotEmpty) {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please log in first.')),
                          );
                          return;
                        }

                        // ✅ Fetch user's name
                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                        final userName = userDoc.exists ? (userDoc.data()?['name'] ?? 'Unknown') : 'Unknown';

                        debugPrint('--- CART DATA ---');

                        for (var item in cartProvider.cartItems) {
                          debugPrint('Menu ID: ${item['menuId']}');
                          debugPrint('Name: ${item['name']}');
                          debugPrint('Category: ${item['category']}');
                          debugPrint('Image: ${item['imageUrl']}');
                          debugPrint('Base Price: ₱${item['basePrice']}');
                          debugPrint('Order Quantity: ${item['orderQuantity']}');
                          debugPrint('Order Price: ₱${item['orderPrice']}');
                          debugPrint('Available: ${item['available']}');
                          debugPrint('Variant: ${item['selectedVariants']}');
                          debugPrint('Allergy Note: ${item['allergyNote']}');
                          debugPrint('Items List: ${item['items']}');

                          // ✅ Print Add-ons
                          List<dynamic> addons = item['addons'] ?? [];
                          if (addons.isNotEmpty) {
                            debugPrint('Add-ons:');
                            // ✅ Deduct stock for Add-ons
                            for (var addon in addons) {
                              String addonId = addon['inventoryId'];
                              int addonQuantity = (addon['quantity'] ?? 1);
                              int orderQuantity = (item['orderQuantity'] ?? 1);
                              int toDeduct = addonQuantity * orderQuantity;
                              String? selectedAddonVariant = addon['selectedVariant'];

                              debugPrint('Fetching addon inventory for ID: $addonId');
                              debugPrint('→ Deduct Calculation: ${addonQuantity} × ${orderQuantity} = $toDeduct');

                              try {
                                final addonRef = FirebaseFirestore.instance.collection('inventory').doc(addonId);
                                final addonSnapshot = await addonRef.get();

                                if (addonSnapshot.exists) {
                                  final addonData = addonSnapshot.data();
                                  debugPrint('--- ADDON INVENTORY DATA ---');
                                  debugPrint('Addon Name: ${addonData?['name']}');

                                  // ✅ Handle normal stock
                                  if (addonData?['stock'] != null) {
                                    int currentStock = addonData?['stock'] ?? 0;
                                    int newStock = currentStock - toDeduct;

                                    await addonRef.update({'stock': newStock});
                                    debugPrint('Addon stock updated: $currentStock → $newStock');
                                  }

                                  // ✅ Handle addon variant stock
                                  if (addonData?['variants'] != null && (addonData?['variants'] as List).isNotEmpty) {
                                    List<dynamic> variants = addonData?['variants'];
                                    debugPrint('Addon Variants: $variants');

                                    if (selectedAddonVariant != null && selectedAddonVariant.isNotEmpty) {
                                      for (var v in variants) {
                                        if (v['name'].toLowerCase() == selectedAddonVariant.toLowerCase()) {
                                          int currentStock = v['stock'] ?? 0;
                                          int newStock = currentStock - toDeduct;
                                          v['stock'] = newStock;
                                          debugPrint('Updated addon variant ${v['name']} stock: $newStock');
                                        }
                                      }

                                      await addonRef.update({'variants': variants});
                                    }
                                  }

                                  debugPrint('-----------------------');
                                } else {
                                  debugPrint('No inventory found for Add-on ID: $addonId');
                                }
                              } catch (e) {
                                debugPrint('Error fetching addon inventory for $addonId: $e');
                              }
                            }
                          }
                          debugPrint('--------------------');

                          // ✅ Deduct stock for menu items
                          List<dynamic> subItems = item['items'] ?? [];
                          String? selectedVariant = item['selectedVariants'];

                          for (var subItem in subItems) {
                            String inventoryId = subItem['inventoryId'];
                            int itemQuantity = (subItem['quantity'] ?? 1);
                            int orderQuantity = (item['orderQuantity'] ?? 1);
                            int toDeduct = itemQuantity * orderQuantity;

                            debugPrint('Fetching inventory for ID: $inventoryId');
                            debugPrint('→ Deduct Calculation: ${itemQuantity} × ${orderQuantity} = $toDeduct');

                            try {
                              final inventoryRef = FirebaseFirestore.instance.collection('inventory').doc(inventoryId);
                              final inventorySnapshot = await inventoryRef.get();

                              if (inventorySnapshot.exists) {
                                final inventoryData = inventorySnapshot.data();
                                debugPrint('--- INVENTORY DATA ---');
                                debugPrint('Name: ${inventoryData?['name']}');

                                // ✅ Handle normal stock
                                if (inventoryData?['stock'] != null) {
                                  int currentStock = inventoryData?['stock'] ?? 0;
                                  int newStock = currentStock - toDeduct;

                                  await inventoryRef.update({'stock': newStock});

                                  debugPrint('Current Stock: $currentStock');
                                  debugPrint('To Deduct: $toDeduct');
                                  debugPrint('New Stock: $newStock');
                                }

                                // ✅ Handle variant stock
                                if (inventoryData?['variants'] != null && (inventoryData?['variants'] as List).isNotEmpty) {
                                  List<dynamic> variants = inventoryData?['variants'];
                                  debugPrint('Variants: $variants');

                                  if (selectedVariant != null && selectedVariant.isNotEmpty) {
                                    if (selectedVariant.toLowerCase() == 'both') {
                                      int splitDeduction = (toDeduct / 2).ceil();
                                      for (var v in variants) {
                                        if (v['name'].toLowerCase() == 'spaghetti' || v['name'].toLowerCase() == 'carbonara') {
                                          int currentStock = v['stock'] ?? 0;
                                          int newStock = currentStock - splitDeduction;
                                          v['stock'] = newStock;
                                          debugPrint('Updated ${v['name']} stock: $newStock');
                                        }
                                      }
                                    } else {
                                      for (var v in variants) {
                                        if (v['name'].toLowerCase() == selectedVariant.toLowerCase()) {
                                          int currentStock = v['stock'] ?? 0;
                                          int newStock = currentStock - toDeduct;
                                          v['stock'] = newStock;
                                          debugPrint('Updated ${v['name']} stock: $newStock');
                                        }
                                      }
                                    }

                                    await inventoryRef.update({'variants': variants});
                                  }
                                }

                                debugPrint('-----------------------');
                              } else {
                                debugPrint('No inventory found for ID: $inventoryId');
                              }
                            } catch (e) {
                              debugPrint('Error fetching inventory for $inventoryId: $e');
                            }
                          }

                          // ✅ Deduct stock for Add-ons
                          for (var addon in addons) {
                            String addonId = addon['inventoryId'];
                            int addonQuantity = (addon['quantity'] ?? 1);
                            int orderQuantity = (item['orderQuantity'] ?? 1);
                            int toDeduct = addonQuantity * orderQuantity;

                            debugPrint('Fetching addon inventory for ID: $addonId');
                            debugPrint('→ Deduct Calculation: ${addonQuantity} × ${orderQuantity} = $toDeduct');

                            try {
                              final addonRef = FirebaseFirestore.instance.collection('inventory').doc(addonId);
                              final addonSnapshot = await addonRef.get();

                              if (addonSnapshot.exists) {
                                final addonData = addonSnapshot.data();
                                if (addonData?['stock'] != null) {
                                  int currentStock = addonData?['stock'] ?? 0;
                                  int newStock = currentStock - toDeduct;

                                  await addonRef.update({'stock': newStock});

                                  debugPrint('Addon: ${addonData?['name']} | Current Stock: $currentStock | New Stock: $newStock');
                                }
                              } else {
                                debugPrint('No inventory found for Add-on ID: $addonId');
                              }
                            } catch (e) {
                              debugPrint('Error fetching addon inventory for $addonId: $e');
                            }
                          }
                        }

                        // ✅ Prepare date formats
                        final now = DateTime.now();
                        final formattedDate = DateFormat('MMMM dd, yyyy hh:mm:ss a').format(now);

                        // ✅ Add order to Firestore
                        final orderData = {
                          'userId': user.uid,
                          'userName': userName,
                          'orderTimestamp': FieldValue.serverTimestamp(),
                          'status': 'pending',
                          'totalPrice': cartProvider.totalOrderPrice,
                          'items': cartProvider.cartItems.map((item) {
                            return {
                              'menuId': item['menuId'],
                              'name': item['name'],
                              'category': item['category'],
                              'orderQuantity': item['orderQuantity'],
                              'orderPrice': item['orderPrice'],
                              'selectedVariant': item['selectedVariants'],
                              'allergyNote': item['allergyNote'],
                              'itemsList': (item['items'] ?? []).map((subItem) {
                                return {
                                  'inventoryId': subItem['inventoryId'],
                                  'name': subItem['name'],
                                  'quantity': subItem['quantity'],
                                  'unlimited': subItem['unlimited'],
                                };
                              }).toList(),
                              'addons': (item['addons'] ?? []).map((addon) {
                                return {
                                  'inventoryId': addon['inventoryId'],
                                  'name': addon['name'],
                                  'price': addon['price'],
                                  'quantity': addon['quantity'],
                                  'unlimited': addon['unlimited'],
                                };
                              }).toList(),
                            };
                          }).toList(),
                        };

                        final docRef = await FirebaseFirestore.instance.collection('orders').add(orderData);

                        debugPrint('Order added with ID: ${docRef.id}');
                        debugPrint('TOTAL ORDER PRICE: ₱${cartProvider.totalOrderPrice.toStringAsFixed(2)}');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order placed successfully!')),
                        );

                        cartProvider.clearCart();
                        Navigator.pop(context);
                      } catch (e) {
                        debugPrint('Error placing order: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error placing order: $e')),
                        );
                      }
                    }
                  },

                  child: const Text(
                    'Check out',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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