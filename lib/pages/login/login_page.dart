import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../assets/app_colors.dart';
import '../../firebase/emailpass_auth.dart';
import '../../firebase/gmail_auth.dart';
import '../signup/signup_page.dart';
import '../navbar/navbar_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  final EmailPassAuth _authService = EmailPassAuth();
  final GmailAuth _gmailAuth = GmailAuth();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_passwordVisible,
                      onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Forgot password logic
                        },
                        child: const Text(
                          "Forgot your password?",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.surfaceA50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 280,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryA0,
                          elevation: 3,
                          shadowColor: AppColors.primaryA10,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final user = await _authService.signIn(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );

                              if (user != null) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NavbarPage()),
                                      (Route<dynamic> route) => false,
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message ?? 'Login failed'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('An unexpected error occurred.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "OR",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 280,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.mail,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final user = await _gmailAuth.signInWithGoogle();
                          if (user != null) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const NavbarPage()),
                                  (Route<dynamic> route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google sign-in failed'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.surfaceA50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryA10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text.rich(
                  TextSpan(
                    text: 'By joining Garahe Ni Kuya, you agree \nto our ',
                    children: [
                      TextSpan(
                        text: 'Terms of Use',
                        style: const TextStyle(
                          color: AppColors.primaryA10,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.primaryA10,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.surfaceA50),
                ),
              ),
            ],
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
    String? Function(String?)? validator, // <-- keep nullable
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
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      style: const TextStyle(fontSize: 14, color: Colors.white),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // <-- no default
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
        contentPadding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
      validator: validator, // <-- no default
    );
  }
}