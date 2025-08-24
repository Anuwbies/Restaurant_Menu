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
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Pizza',
    },
    {
      'name': 'Pepperoni Pizza',
      'desc': 'Pepperoni, mozzarella, and tomato sauce.',
      'price': 499,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
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
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Salad',
    },
    {
      'name': 'Spaghetti Carbonara',
      'desc': 'Pasta with pancetta, egg, and parmesan cheese.',
      'price': 299,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Pasta',
    },
    {
      'name': 'Lasagna',
      'desc': 'Layered pasta with beef, tomato, and cheese.',
      'price': 399,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
      'type': 'Pasta',
    },
    {
      'name': 'Grilled Salmon',
      'desc': 'Fresh salmon fillet with lemon and herbs.',
      'price': 599,
      'img': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=400&q=80',
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

  Map<String, List<Map<String, dynamic>>> _groupByType(List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      final type = item['type'] as String;
      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(item);
    }
    return grouped;
  }

  Set<String> selectedTypes = {'All'}; // default
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

    if (selectedTypes.contains('All')) {
      filtered = menuItems;
    } else if (selectedTypes.contains('Favorite')) {
      filtered = menuItems.where((item) => favorites.contains(item['name'])).toList();
    } else {
      filtered = menuItems.where((item) => selectedTypes.contains(item['type'])).toList();
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
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                              transitionDuration: const Duration(milliseconds: 300),
                              reverseTransitionDuration: const Duration(milliseconds: 300),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
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
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
              height: 45 + 2,
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                scrollDirection: Axis.horizontal,
                itemCount: foodTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final type = foodTypes[index];
                  final isSelected = selectedTypes.contains(type);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (type == 'All' || type == 'Favorite') {
                          selectedTypes = {type};
                        } else {

                          selectedTypes.remove('All');
                          selectedTypes.remove('Favorite');

                          if (isSelected) {
                            selectedTypes.remove(type);
                            if (selectedTypes.isEmpty) selectedTypes.add('All');
                          } else {
                            selectedTypes.add(type);
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (type == 'Favorite' && !isSelected)
                              const Icon(Icons.favorite, color: Colors.white, size: 18),
                            if (isSelected) const Icon(Icons.check, color: Colors.white, size: 18),
                            if ((type == 'Favorite' && !isSelected) || isSelected)
                              const SizedBox(width: 4),
                            Text(
                              type,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                  children: const [
                    Icon(Icons.search_off, size: 60, color: AppColors.surfaceA50),
                    SizedBox(height: 12),
                    Text(
                      'No items found.',
                      style: TextStyle(fontSize: 18, color: AppColors.surfaceA50),
                    ),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  // group items by type
                  ..._groupByType(filteredMenuItems).entries.map((entry) {
                    final type = entry.key;
                    final items = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food type heading
                          Padding(
                            padding: const EdgeInsets.symmetric( horizontal: 5),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // List of foods under this type
                          ...items.map((item) => Card(
                            color: Colors.transparent,
                            elevation: 0,
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
                                      item['img'],
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
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₱${item['price']}',
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
                                    width: 36, // smaller size
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryA0,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero, // removes default padding
                                      icon: const Icon(Icons.add, color: Colors.white, size: 18), // smaller icon
                                      onPressed: () {
                                        // TODO: Add to cart
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
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
    );
  }
}
