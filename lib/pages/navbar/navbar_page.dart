import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import 'package:restaurant_menu/pages/history/history_page.dart';
import 'package:restaurant_menu/pages/order/order_page.dart';
import 'package:restaurant_menu/pages/profile/profile_page.dart';
import '../menu/menu_page.dart';
import '../home/home_page.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    MenuPage(),
    OrderPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, // black/dark icons
        statusBarColor: Colors.transparent, // keep transparent if desired
      ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_selectedIndex],
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
          child: SizedBox(
            height: 60,
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.black,
                items: [
                  _buildNavBarItem(Icons.home, 'Home', 0),
                  _buildNavBarItem(Icons.restaurant_menu, 'Menu', 1),
                  _buildNavBarItem(Icons.list_alt, 'Order', 2),
                  _buildNavBarItem(Icons.history, 'History', 3),
                  _buildNavBarItem(Icons.account_circle, 'Profile', 4),
                ],
                selectedItemColor: AppColors.primaryA30,
                unselectedItemColor: AppColors.surfaceA40,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                iconSize: 22,
                selectedFontSize: 11,
                unselectedFontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryA0: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0), // tighter padding
        child: Icon(icon, size: 26),
      ),
      label: label,
    );
  }
}
