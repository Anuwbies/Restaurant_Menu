import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: const Text(
            'About',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Garahe ni Kuya Jo: A Taste of Home and Comfort',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Garahe ni Kuya Jo is a beloved Filipino restaurant chain that offers an array of unlimited (unli) meals, including chicken wings, sisig, bagnet, pasta, fries, and iced tea. With branches in various locations such as Quezon City, Dagupan, and Caloocan, it has become a go-to spot for food enthusiasts seeking hearty and affordable meals.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'What Sets Us Apart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'At Garahe ni Kuya Jo, we pride ourselves on providing a cozy and welcoming atmosphere where friends and families can gather to enjoy delicious meals. Our unli meals are not only satisfying but also offer great value, making it a popular choice for those looking to indulge without breaking the bank.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Join Us Today!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Whether you\'re craving for crispy chicken wings, savory sisig, or a refreshing glass of iced tea, Garahe ni Kuya Jo has something for everyone. Visit us at any of our branches and experience the taste of home and comfort.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}