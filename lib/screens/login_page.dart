
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'main_navigation_page.dart';
import 'signup_page.dart';
import 'phone_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw StateError('User session not found after login.');
      }

      // Refresh the account information from Firebase.
      await user.reload();

      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw StateError('Unable to load user information.');
      }

      // Check if the phone number is already linked.
      final bool phoneVerified =
          updatedUser.phoneNumber != null &&
          updatedUser.phoneNumber!.isNotEmpty;

      if (!mounted) return;

      if (phoneVerified) {
        // Phone already linked: enter Returnly directly.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigationPage(),
          ),
        );
      } else {
        // No linked phone: go to phone verification.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PhoneVerificationPage(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.message ?? e.code}'),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(
                    Icons.lock_outline,
                    size: 45,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Welcome to Returnly',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text('Create an Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
