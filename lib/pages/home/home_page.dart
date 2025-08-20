import 'package:flutter/material.dart';
import 'package:restaurant_menu/assets/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> carouselImages = [
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
  ];

  final String foodTypeImage =
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=400&q=80';

  final List<Map<String, dynamic>> foodTypes = [
    {'type': 'Pizza'},
    {'type': 'Salad'},
    {'type': 'Pasta'},
    {'type': 'Main'},
    {'type': 'Dessert'},
    {'type': 'Drinks'},
    {'type': 'Appetizers'},
    {'type': 'Burgers'},
    {'type': 'Sandwiches'},
    {'type': 'Soups'},
    {'type': 'Seafood'},
    {'type': 'Vegetarian'},
  ];

  late PageController _pageController;
  int _carouselIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: carouselImages.length * 1000,
      viewportFraction: 0.92,
    );
    _carouselIndex = carouselImages.length * 1000;

    double startFade = 40;
    double endFade = 160;

    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      double opacity = 1.0;
      if (offset > startFade && offset < endFade) {
        opacity = 1 - ((offset - startFade) / (endFade - startFade)).clamp(0, 1);
      } else if (offset >= endFade) {
        opacity = 0.0;
      }
      if (opacity != _appBarOpacity) {
        setState(() {
          _appBarOpacity = opacity;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _appBarOpacity,
          child: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Garahe Ni Kuya Jo',
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
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 85),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              child: Row(
                children: [
                  Image.asset(
                    'images/logo_gnk.png',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryA0,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Enjoy browsing our delicious menu and discover your next favorite meal.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 1.5,
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _carouselIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final img = carouselImages[index % carouselImages.length];
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 15),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'EXPLORE DIFFERENT DISHES',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryA0,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: List.generate(
                  (foodTypes.length / 2).ceil(),
                      (rowIndex) {
                    final leftIndex = rowIndex * 2;
                    final rightIndex = leftIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FoodTypeCard(
                              type: foodTypes[leftIndex]['type'],
                              imageUrl: foodTypeImage,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (rightIndex < foodTypes.length)
                            Expanded(
                              child: _FoodTypeCard(
                                type: foodTypes[rightIndex]['type'],
                                imageUrl: foodTypeImage,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodTypeCard extends StatelessWidget {
  final String type;
  final String imageUrl;

  const _FoodTypeCard({required this.type, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(6),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          type,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}