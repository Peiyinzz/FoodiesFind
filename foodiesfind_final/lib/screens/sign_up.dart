import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // For showing a loading spinner if needed

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (username.isEmpty) {
      _showError('Please enter a username');
      return;
    }
    if (email.isEmpty) {
      _showError('Please enter an email');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter a password');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final accepted = await _showTermsAndConditionsDialog();
      if (!accepted) {
        setState(() => _isLoading = false);
        return;
      }

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        _showError('Sign-up failed. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'tncAccepted': true,
      });

      Navigator.pushReplacementNamed(
        context,
        '/userprofile',
        arguments: {'username': username, 'email': email},
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Sign-up failed');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showTermsAndConditionsDialog() async {
    bool accepted = false;
    bool isChecked = false;

    while (!accepted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Terms & Conditions'),
                content: SizedBox(
                  height: 320,
                  width: double.maxFinite,
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to FoodiesFind. By registering or using our services, you agree to be bound by the following terms:\n\n'
                            '1. User Accounts\n'
                            'You must provide accurate and complete information during registration.\n\n'
                            '2. Content\n'
                            'User-submitted content must not be offensive or infringe on others.\n\n'
                            '3. Data Collection\n'
                            'We use your info based on our Privacy Policy. We do not sell your data.\n\n'
                            '4. Usage Rules\n'
                            'No misuse or unauthorized access of data.\n\n'
                            '5. Modification & Termination\n'
                            'We may update terms or suspend accounts that violate them.\n\n'
                            '6. Limitation of Liability\n'
                            'FoodiesFind is not liable for food reactions or third-party info changes.\n\n'
                            'By accepting, you confirm you have read and agree to abide by these Terms & Conditions.',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: isChecked,
                                onChanged: (val) {
                                  setState(() {
                                    isChecked = val ?? false;
                                  });
                                },
                              ),
                              const Flexible(
                                child: Text(
                                  'I have read the Terms & Conditions.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You must accept the Terms & Conditions to continue.',
                          ),
                        ),
                      );
                    },
                    child: const Text('Decline'),
                  ),
                  ElevatedButton(
                    onPressed:
                        isChecked
                            ? () {
                              Navigator.of(context).pop(true);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isChecked
                              ? const Color(0xFFC8E0CA)
                              : Colors.grey.shade400,
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == true) {
        accepted = true;
      }
    }

    return accepted;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background color
      backgroundColor: const Color(0xFF0E2223),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // App logo (centered)
              Center(
                child: Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/foodiesfind-21552.firebasestorage.app/o/Logo%2Ffoodiesfind_plainlogo.png?alt=media&token=d8c5030f-0802-42e3-84c4-61da0a1a7fc4',
                  width: 160,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(controller: _emailController, label: 'Email'),
              const SizedBox(height: 16),

              // Password
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8E0CA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // "Already have an account?" + "Log In"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFFC8E0CA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // or divider
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white54, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('or', style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: Divider(color: Colors.white54, thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // Sign up with Google button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: handle Google sign-up logic
                  },
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text(
                    'Sign up with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white, // Make the typing cursor white
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFFC8E0CA), // Floating label color
        ),
        filled: true,
        fillColor: Colors.white10, // Slight translucent white background
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC8E0CA), width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
