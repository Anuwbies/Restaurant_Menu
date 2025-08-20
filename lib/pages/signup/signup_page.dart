import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_menu/assets/app_colors.dart';
import '../../assets/transition/fromright.dart';
import '../../firebase/emailpass_auth.dart';
import '../login/login_page.dart';
import '../text/privacy_policy_page.dart';
import '../text/terms_of_use_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final EmailPassAuth _authService = EmailPassAuth();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _usernameError;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Garahe Ni Kuya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryA0,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Username is required';
                    if (value.length < 3) return 'Username must be at least 3 characters';
                    if (value.length > 10) return 'Cannot exceed 10 characters';
                    return null;
                  },
                  errorText: _usernameError,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Name is required';
                    if (value.length < 3) return 'Name must be at least 3 characters';
                    if (value.length > 30) return 'Cannot exceed 30 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (value.contains(' ')) return 'Enter a valid email';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                  errorText: _emailError,
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: !_passwordVisible,
                  onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: !_confirmPasswordVisible,
                  onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 280,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Reset inline errors first
                      setState(() {
                        _usernameError = null;
                        _emailError = null;
                      });

                      if (_formKey.currentState!.validate()) {
                        try {
                          // Show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final user = await _authService.signUp(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            username: _usernameController.text.trim(),
                            name: _nameController.text.trim(),
                          );

                          Navigator.of(context).pop(); // close loading dialog

                          if (user != null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          }
                        } on FirebaseException catch (e) {
                          Navigator.of(context).pop(); // close loading
                          setState(() {
                            // Reset errors each attempt
                            _usernameError = null;
                            _emailError = null;

                            if (e.message != null) {
                              final parts = e.message!.split('|');
                              for (var part in parts) {
                                if (part.startsWith('username:')) {
                                  _usernameError = part.replaceFirst('username:', '').trim();
                                }
                                if (part.startsWith('email:')) {
                                  _emailError = part.replaceFirst('email:', '').trim();
                                }
                              }
                            }
                          });
                        } catch (e) {
                          Navigator.of(context).pop(); // close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.surfaceA50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                            transitionDuration: const Duration(milliseconds: 300),
                            reverseTransitionDuration: const Duration(milliseconds: 300),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryA10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'By joining Garahe Ni Kuya Jo, you agree \nto our ',
                      style: const TextStyle(fontSize: 13, color: AppColors.surfaceA50),
                      children: [
                        TextSpan(
                          text: 'Terms of Use',
                          style: const TextStyle(color: AppColors.primaryA10),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(
                              context,
                              SlideFromRightPageRoute(page: const TermsOfUsePage()),
                            );
                          },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(color: AppColors.primaryA10),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(
                              context,
                              SlideFromRightPageRoute(page: const PrivacyPolicyPage()),
                            );
                          },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? errorText, // inline error
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.surfaceA50,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(
          color: AppColors.primaryA50,
          fontSize: 12,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryA50, width: 2),
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryA10,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryA10, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: AppColors.surfaceA10,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // only runs if explicitly provided
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.surfaceA50,
        ),
        errorStyle: const TextStyle(
          color: AppColors.primaryA50,
          fontSize: 12,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryA50, width: 2),
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.primaryA10,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primaryA10, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: AppColors.surfaceA10,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            size: 22,
            color: AppColors.surfaceA50,
          ),
          onPressed: onToggle,
        ),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.white),
      obscureText: obscureText,
      validator: validator, // only runs if explicitly provided
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
    );
  }
}