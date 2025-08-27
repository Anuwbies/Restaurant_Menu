import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import 'package:restaurant_menu/pages/password/change_password_page.dart';
import 'package:restaurant_menu/pages/text/help_support_page.dart';
import 'package:restaurant_menu/pages/text/privacy_policy_page.dart';
import '../../assets/transition/fromright.dart';
import '../login/login_page.dart';
import '../password/set_password_page.dart';
import '../text/about_page.dart';
import '../text/terms_of_use_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  bool _isChangingPic = false; // flag to prevent spamming

  Future<void> _changeProfilePicture() async {
    if (_isChangingPic) return; // ignore if already processing
    setState(() => _isChangingPic = true);

    try {
      // TODO: open image picker & upload new photo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Change profile picture tapped")),
      );

      await Future.delayed(const Duration(seconds: 5)); // simulate upload
    } catch (e) {
      debugPrint("Error changing picture: $e");
    } finally {
      if (mounted) setState(() => _isChangingPic = false);
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController _nameController =
    TextEditingController(text: currentName);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white, width: 1.5),
              ),
              title: const Text(
                'Edit Name',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              content: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    const BorderSide(color: AppColors.primaryA0, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.primaryA0)),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: AppColors.primaryA0),
                  onPressed: isSaving
                      ? null
                      : () async {
                    final newName = _nameController.text.trim();

                    // Remove any previous SnackBar
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    if (newName.length < 3 || newName.length > 30) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Name must be between 3 and 30 characters')),
                      );
                      return;
                    }

                    if (newName.isNotEmpty && newName != currentName) {
                      setStateDialog(() => isSaving = true);
                      try {
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          await currentUser.updateDisplayName(newName);
                          await currentUser.reload();
                          final updatedUser = FirebaseAuth.instance.currentUser;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .update({'name': newName});

                          if (mounted) {
                            setState(() {
                              user = updatedUser;
                            });
                          }

                          Navigator.pop(context);

                          // Remove previous SnackBar just in case
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Name updated successfully')),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.message}')),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setStateDialog(() => isSaving = false);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  bool _hasPassword(User user) {
    return user.providerData.any((info) => info.providerId == 'password');
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = user != null
        ? (user?.displayName ?? 'Nameless')
        : 'Guest Account';
    final String? emailText = user?.email;
    final String joinedDate = user?.metadata.creationTime != null
        ? 'Joined: ${DateFormat('MMM d, y').format(user!.metadata.creationTime!.toLocal())}'
        : "Sign up to join";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (user != null)
                GestureDetector(
                  onTap: () async {
                    if (!user!.emailVerified) {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text(
                            'Verify Email',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                            'Send verification link to:\n\n${user!.email}',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.surfaceA10,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel',
                                  style: TextStyle(color: AppColors.primaryA0)),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryA0,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Send Link',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await user!.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification link sent to your email'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 3, 3, 3),
                    decoration: BoxDecoration(
                      color: user!.emailVerified ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user!.emailVerified ? 'Verified' : 'Unverified',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: Colors.grey[700],
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 90, color: Colors.white)
                            : null,
                      ),
                    ),
                    if (user != null) // Only show edit if logged in
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryA0,
                            ),
                            child: _isChangingPic
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.edit, color: Colors.white, size: 21),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3), // very small gap
                          if (user != null)
                            GestureDetector(
                              onTap: () => _showEditNameDialog(context, displayName),
                              child: const Icon(Icons.edit_rounded, color: AppColors.primaryA0, size: 22),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (emailText != null) ...[
                        Text(
                          emailText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      Text(
                        joinedDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      if (user == null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryA0,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 30),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text('Log In', style: TextStyle(fontSize: 14)),
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
                    title: user != null
                        ? (_hasPassword(user!) ? 'Change Password' : 'Set Password')
                        : 'Change Password',
                    onTap: user != null
                        ? () {
                      if (_hasPassword(user!)) {
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(page: const ChangePasswordPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          SlideFromRightPageRoute(page: const SetPasswordPage()),
                        );
                      }
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
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
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