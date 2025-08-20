import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import 'package:restaurant_menu/pages/navbar/navbar_page.dart';
import 'package:restaurant_menu/pages/text/help_support_page.dart';
import 'package:restaurant_menu/pages/text/privacy_policy_page.dart';
import '../../assets/transition/fromright.dart';
import '../login/login_page.dart';
import '../text/about_page.dart';
import '../text/terms_of_use_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static String? cachedUsername; // store username across instances
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (cachedUsername == null) {
      _loadUsername();
    }
  }

  Future<void> _loadUsername() async {
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            cachedUsername = doc['username'] ?? 'Unknown';
          });
        } else {
          setState(() {
            cachedUsername = 'Unknown';
          });
        }
      } catch (e) {
        setState(() {
          cachedUsername = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username = user != null
        ? (cachedUsername ?? 'Loading...')
        : 'Guest';
    final String joinedDate = user?.metadata.creationTime != null
        ? 'Joined: ${DateFormat('MMM d, y').format(user!.metadata.creationTime!.toLocal())}'
        : 'Sign in to join';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Profile',
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
      body: Column(
        children: [
          // Header with profile picture, username, joined date, and edit/login button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture with border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    backgroundColor: Colors.grey[700],
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 80, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (user != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: user!.emailVerified ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user!.emailVerified ? 'Verified' : 'Unverified',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        joinedDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (user != null) {
                            // Navigate to edit profile page
                          } else {
                            // Navigate to login page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          user != null ? AppColors.primaryA0 : AppColors.primaryA0,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          user != null ? 'Edit Profile' : 'Log In',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable actions
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  _buildActionTile(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: user != null
                        ? () {
                      // Navigate to change password page
                    }
                        : null,
                    iconColor: user != null ? Colors.white : Colors.grey,
                    textColor: user != null ? Colors.white : Colors.grey,
                  ),
                  _buildActionTile(context,
                      icon: Icons.info_outline,
                      title: 'About',
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(page: const AboutPage()),
                      );
                    },
                  ),
                  _buildActionTile(context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(page: const HelpSupportPage()),
                      );
                    },
                  ),
                  _buildActionTile(context,
                      icon: Icons.description_outlined,
                      title: 'Terms of Use',
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(page: const TermsOfUsePage()),
                      );
                    },
                  ),
                  _buildActionTile(context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideFromRightPageRoute(page: const PrivacyPolicyPage()),
                      );
                    },
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: user != null
                        ? () async {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                          const EdgeInsets.fromLTRB(24, 20, 24, 20),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Confirm Log Out',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Are you sure you want to log out?',
                                style: TextStyle(color: AppColors.primaryA50),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.surfaceA10,
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel',
                                          style: TextStyle(
                                              color: AppColors.primaryA0)),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppColors.primaryA0,
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Log Out',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          user = null;
                          cachedUsername = null; // clear cached username
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const NavbarPage()),
                        );
                      }
                    }
                        : null,
                    iconColor: user != null ? Colors.white : Colors.grey,
                    textColor: user != null ? Colors.white : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _buildActionTile to include icon
  Widget _buildActionTile(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback? onTap,
        Color iconColor = Colors.white,
        Color textColor = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}