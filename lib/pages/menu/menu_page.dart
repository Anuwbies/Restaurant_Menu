import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import 'package:restaurant_menu/pages/cart/cart_page.dart';
import '../../assets/transition/fromright.dart';
import '../cart/cart_provider.dart';
import '../food/food_details_page.dart';
import '../login/login_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String placeholderImage =
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80';

  List<Map<String, dynamic>> menuItems = [];
  bool isLoading = true;

  Set<String> selectedCategories = {'All'};
  String searchQuery = '';

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      final snapshot = await _firestore.collection('menu').get();
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((item) => item['available'] == true).toList();

      setState(() {
        menuItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching menu items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> get categories {
    final unique = menuItems.map((e) => e['category'] as String).toSet().toList();
    unique.sort();
    return ['All', ...unique];
  }

  List<Map<String, dynamic>> get filteredMenuItems {
    final lowerQuery = searchQuery.trim().toLowerCase();
    List<Map<String, dynamic>> filtered;

    if (selectedCategories.contains('All')) {
      filtered = menuItems;
    } else {
      filtered =
          menuItems.where((item) => selectedCategories.contains(item['category'])).toList();
    }

    if (lowerQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery);
      }).toList();
    }
    return filtered;
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      final category = item['category'] as String;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Menu',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          actions: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(page: const CartPage()),
                        );
                      },
                    ),
                    if (cartProvider.cartItems.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryA0,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartProvider.cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.primaryA0.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Sign up or log in to save your orders!',
                            style: TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                const LoginPage(),
                                transitionDuration:
                                const Duration(milliseconds: 300),
                                reverseTransitionDuration:
                                const Duration(milliseconds: 300),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(color: AppColors.primaryA0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Material(
                  borderRadius: BorderRadius.circular(24),
                  child: TextField(
                    controller: _searchController,
                    style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search menu...',
                      hintStyle: const TextStyle(
                          color: AppColors.surfaceA50, fontSize: 14),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.search,
                            color: AppColors.surfaceA50),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceA10,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.surfaceA50, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                        const BorderSide(color: Colors.white, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.primaryA0, width: 1),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.surfaceA50),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        ),
                      )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 45 + 2,
                child: ListView.separated(
                  padding:
                  const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategories.contains(category);
        
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (category == 'All') {
                            selectedCategories = {category};
                          } else {
                            selectedCategories.remove('All');
                            if (isSelected) {
                              selectedCategories.remove(category);
                              if (selectedCategories.isEmpty) selectedCategories.add('All');
                            } else {
                              selectedCategories.add(category);
                            }
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryA0 : Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 1),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(Icons.check,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                              Text(
                                category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(height: 1.5, color: Colors.white, width: double.infinity),
              Expanded(
                child: filteredMenuItems.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.search_off,
                          size: 60, color: AppColors.surfaceA50),
                      SizedBox(height: 12),
                      Text(
                        'No items found.',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.surfaceA50),
                      ),
                    ],
                  ),
                )
                    : ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    ..._groupByCategory(filteredMenuItems)
                        .entries
                        .map((entry) {
                      final category = entry.key;
                      final items = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5),
                              child: Text(
                                category,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            ...items.map(
                                (item) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlideFromRightPageRoute(
                                    page: FoodDetailsPage(
                                      menuId: item['id'],
                                      imageUrl: item['imageUrl'] ?? placeholderImage,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.white, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          placeholderImage,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SizedBox(
                                          height: 90,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                item['name'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.1,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '₱${item['price'] ?? ''}.00',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryA0,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              SlideFromRightPageRoute(
                                                page: FoodDetailsPage(
                                                  menuId: item['id'],
                                                  imageUrl: item['imageUrl'] ?? placeholderImage,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}