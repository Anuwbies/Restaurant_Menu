import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import '../login/login_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Margherita Pizza',
      'desc': 'Classic pizza with tomato, mozzarella, and basil.',
      'price': 349,
      'img': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80',
      'type': 'Pizza',
    },
    {
      'name': 'Pepperoni Pizza',
      'desc': 'Pepperoni, mozzarella, and tomato sauce.',
      'price': 499,
      'img': 'https://images.unsplash.com/photo-1548365328-8b849e6c7d7b?auto=format&fit=crop&w=400&q=80',
      'type': 'Pizza',
    },
    {
      'name': 'Caesar Salad',
      'desc': 'Crisp romaine lettuce, parmesan, and croutons.',
      'price': 199,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Salad',
    },
    {
      'name': 'Greek Salad',
      'desc': 'Tomatoes, cucumber, olives, feta cheese.',
      'price': 229,
      'img': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      'type': 'Salad',
    },
    {
      'name': 'Spaghetti Carbonara',
      'desc': 'Pasta with pancetta, egg, and parmesan cheese.',
      'price': 299,
      'img': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
      'type': 'Pasta',
    },
    {
      'name': 'Lasagna',
      'desc': 'Layered pasta with beef, tomato, and cheese.',
      'price': 399,
      'img': 'https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80',
      'type': 'Pasta',
    },
    {
      'name': 'Grilled Salmon',
      'desc': 'Fresh salmon fillet with lemon and herbs.',
      'price': 599,
      'img': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=400&q=80',
      'type': 'Main',
    },
    {
      'name': 'Steak',
      'desc': 'Juicy grilled steak with garlic butter.',
      'price': 899,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Main',
    },
  ];

  String selectedType = 'All';
  String searchQuery = '';
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  Set<String> favorites = {};

  final String foodCardImage =
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80';

  List<String> get foodTypes {
    final types = menuItems.map((item) => item['type'] as String).toSet().toList();
    types.sort();
    return ['All', 'Favorite', ...types];
  }

  List<Map<String, dynamic>> get filteredMenuItems {
    final lowerQuery = searchQuery.trim().toLowerCase();
    List<Map<String, dynamic>> filtered;
    if (selectedType == 'All') {
      filtered = menuItems;
    } else if (selectedType == 'Favorite') {
      filtered = menuItems.where((item) => favorites.contains(item['name'])).toList();
    } else {
      filtered = menuItems.where((item) => item['type'] == selectedType).toList();
    }
    if (lowerQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              (item['name'] as String).toLowerCase().contains(lowerQuery) ||
              (item['desc'] as String).toLowerCase().contains(lowerQuery))
          .toList();
    }
    return filtered;
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (favorites.contains(name)) {
        favorites.remove(name);
      } else {
        favorites.add(name);
      }
    });
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
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                // TODO: Handle cart action
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  color: AppColors.primaryA0.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sign up or log in to save your favorites and orders!',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search menu...',
                    hintStyle: const TextStyle(color: AppColors.surfaceA50, fontSize: 14),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search, color: AppColors.surfaceA50),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceA10,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.surfaceA50, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primaryA0, width: 1),
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.surfaceA50),
                        onPressed: () {
                          _searchController.clear();  // clear the text field
                          setState(() {
                            searchQuery = '';        // clear the filter
                          });
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
              height: 45+2,
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 10),
                scrollDirection: Axis.horizontal,
                itemCount: foodTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final type = foodTypes[index];
                  final isSelected = selectedType == type;
                  final isFavorite = type == 'Favorite';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedType = type;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryA0 : Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Favorite icon (only when not selected)
                            if (isFavorite && !isSelected)
                              const Icon(Icons.favorite, color: Colors.white, size: 18),

                            if (isSelected)
                              const Icon(Icons.check, color: Colors.white, size: 18),

                            if ((isFavorite && !isSelected) || isSelected)
                              const SizedBox(width: 4),

                            Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 1.5,
              color: Colors.white,
              width: double.infinity,
            ),
            Expanded(
              child: filteredMenuItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: AppColors.surfaceA50,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No items found.',
                      style: TextStyle(fontSize: 18, color: AppColors.surfaceA50),
                    ),
                  ],
                ),
              )
              :ListView.separated(
                padding: const EdgeInsets.all(10),
                itemCount: filteredMenuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 5),
                itemBuilder: (context, index) {
                  final item = filteredMenuItems[index];
                  return Card(
                    color: Colors.transparent, // transparent background
                    elevation: 0, // no shadow (keeps it clean with border)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white, width: 1), // white border
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              foodCardImage,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // white text
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱${item['price'].toString()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2), // white border
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent, // transparent bg
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  // TODO: Add to cart logic
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
