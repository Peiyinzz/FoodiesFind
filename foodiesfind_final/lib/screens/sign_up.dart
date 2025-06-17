import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  Future<void> _handleSignUp() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final accepted = await _showTermsAndConditionsDialog();
      if (!accepted) {
        setState(() => _isLoading = false);
        return;
      }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      final user = cred.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _usernameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'tncAccepted': true,
      });

      Navigator.pushReplacementNamed(
        context,
        '/userprofile',
        arguments: {
          'username': _usernameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _emailError = 'Email already in use';
            break;
          case 'invalid-email':
            _emailError = 'Invalid email address';
            break;
          case 'weak-password':
            _passwordError = 'Password is too weak';
            break;
          default:
            _emailError = 'Sign-up failed';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showTermsAndConditionsDialog() async {
    bool accepted = false, isChecked = false;
    while (!accepted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => StatefulBuilder(
              builder:
                  (ctx, setSt) => AlertDialog(
                    title: const Text('Terms & Conditions'),
                    content: SizedBox(
                      height: 320,
                      width: double.maxFinite,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome to FoodiesFind. By registering or using our services, you agree to the following Terms & Conditions:\n\n'
                                '1. User Accounts\n'
                                'You agree to provide accurate and complete information during registration and to keep your profile up to date.\n\n'
                                '2. Content\n'
                                'You are responsible for any content you submit. Content must not be offensive, misleading, or infringe on third-party rights.\n\n'
                                '3. Data Collection & PDPA Compliance\n'
                                'We collect and use your personal data in accordance with the Personal Data Protection Act (PDPA) and our Privacy Policy. '
                                'Your data will only be used to enhance your experience and will never be sold to third parties.\n\n'
                                '4. Usage Rules\n'
                                'You agree not to misuse the platform, engage in illegal activities, or attempt unauthorized access to data or services.\n\n'
                                '5. Modification & Termination\n'
                                'We reserve the right to update these terms and to suspend or terminate accounts found in violation of our policies.\n\n'
                                '6. Limitation of Liability\n'
                                'FoodiesFind is not liable for food allergies, health reactions, or inaccurate information provided by third-party restaurants.\n\n'
                                '7. Acceptance\n'
                                'By clicking accept, you confirm that you have read, understood, and agreed to comply with these Terms & Conditions and our Privacy Policy.',
                                style: TextStyle(fontSize: 13),
                              ),

                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged:
                                        (v) => setSt(() => isChecked = v!),
                                  ),
                                  const Expanded(
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
                              content: Text('You must accept to continue.'),
                            ),
                          );
                        },
                        child: const Text('Decline'),
                      ),
                      ElevatedButton(
                        onPressed:
                            isChecked
                                ? () => Navigator.of(ctx).pop(true)
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isChecked ? const Color(0xFFC8E0CA) : Colors.grey,
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
            ),
      );
      if (result == true) accepted = true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2223),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/foodiesfind_plainlogo.png',
                  width: 220,
                  height: 140,
                ),
              ),
              const SizedBox(height: 24),
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

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    TextFormField(
                      controller: _usernameCtrl,
                      cursorColor: Colors.white70,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        errorText: _usernameError,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC8E0CA),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      cursorColor: Colors.white70,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        errorText: _emailError,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC8E0CA),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!v.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      cursorColor: Colors.white70,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        errorText: _passwordError,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC8E0CA),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (v.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmCtrl,
                      cursorColor: Colors.white70,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        errorText: _confirmError,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC8E0CA),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
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
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // or divider
                    // Row(
                    //   children: const [
                    //     Expanded(child: Divider(color: Colors.white54)),
                    //     Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 8.0),
                    //       child: Text(
                    //         'or',
                    //         style: TextStyle(color: Colors.white70),
                    //       ),
                    //     ),
                    //     Expanded(child: Divider(color: Colors.white54)),
                    //   ],
                    // ),
                    // const SizedBox(height: 16),

                    // Hidden Google sign-up button
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       // TODO: handle Google sign-up logic
                    //     },
                    //     icon: Image.asset(
                    //       'assets/images/google_logo.png',
                    //       width: 20,
                    //       height: 20,
                    //     ),
                    //     label: const Text(
                    //       'Sign up with Google',
                    //       style: TextStyle(color: Colors.white),
                    //     ),
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: Colors.white,
                    //       side: const BorderSide(color: Colors.white),
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
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
            ],
          ),
        ),
      ),
    );
  }
}
