import 'package:flutter/material.dart';
import '../../firebase/menu.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  final MenuAPI _menuAPI = MenuAPI();

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalOrderPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += item['orderPrice'];
    }
    return total;
  }

  Future<void> addToCart(
      String menuId,
      int orderQuantity,
      String allergyNote,
      Map<String, String?> selectedVariants,
      Map<String, bool> selectedAddons,
      Map<String, String?> selectedAddonsVariants,
      ) async {
    try {
      final menuData = await _menuAPI.fetchMenuItemById(menuId);
      if (menuData != null) {
        double basePrice = (menuData['price'] as num?)?.toDouble() ?? 0.0;
        double addonsPrice = 0;

        // Get selected addons details
        final List<dynamic> menuAddons = menuData['addons'] ?? [];
        List<Map<String, dynamic>> chosenAddons = [];

        for (var addon in menuAddons) {
          if (selectedAddons[addon['inventoryId']] == true) {
            double price = (addon['price'] as num?)?.toDouble() ?? 0.0;
            addonsPrice += price;

            chosenAddons.add({
              'inventoryId': addon['inventoryId'],
              'name': addon['name'],
              'price': price,
              'quantity': addon['quantity'] ?? 0, // Include quantity
              'unlimited': addon['unlimited'] ?? false, // Include unlimited
              'selectedVariant': selectedAddonsVariants[addon['inventoryId']] ?? '', // NEW
            });
          }
        }

        double totalPrice = (basePrice + addonsPrice) * orderQuantity;

        final cartItem = {
          'menuId': menuId,
          'name': menuData['name'] ?? '',
          'imageUrl': menuData['imageUrl'] ?? '',
          'category': menuData['category'] ?? '',
          'available': menuData['available'] ?? true,
          'items': menuData['items'] ?? [],
          'basePrice': basePrice,
          'orderQuantity': orderQuantity,
          'orderPrice': totalPrice,
          'allergyNote': allergyNote,
          'selectedVariants': selectedVariants.values
              .where((v) => v != null && v.isNotEmpty)
              .join(", "),
          'addons': chosenAddons,
        };

        _cartItems.add(cartItem);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error adding to cart: $e");
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      final basePrice = _cartItems[index]['basePrice'] ?? 0.0;

      // Recalculate addon total
      double addonsPrice = 0;
      if (_cartItems[index]['addons'] != null) {
        for (var addon in _cartItems[index]['addons']) {
          addonsPrice += (addon['price'] as num?)?.toDouble() ?? 0.0;
        }
      }

      _cartItems[index]['orderQuantity'] = newQuantity;
      _cartItems[index]['orderPrice'] = (basePrice + addonsPrice) * newQuantity;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}