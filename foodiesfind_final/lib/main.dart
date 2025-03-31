import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:foodiesfind_final/screens/sign_up.dart';
import 'package:foodiesfind_final/screens/sign_in.dart';
import 'package:foodiesfind_final/screens/user_profile.dart';
import 'package:foodiesfind_final/screens/review_form.dart';
import 'screens/homepage.dart';
import 'screens/restaurantlist.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains("already exists")) {
      debugPrint(
        "Firebase already initialized. Skipping duplicate initialization.",
      );
    } else {
      rethrow;
    }
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodiesFind',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SignUpPage(),

      // ✅ Dynamic route generation with argument support
      onGenerateRoute: (settings) {
        if (settings.name == '/userprofile') {
          final args = settings.arguments;

          if (args != null && args is Map<String, String>) {
            return MaterialPageRoute(
              builder:
                  (_) => UserProfilePage(
                    initialUsername: args['username'] ?? '',
                    email: args['email'] ?? '',
                  ),
            );
          } else {
            return MaterialPageRoute(
              builder:
                  (_) => const UserProfilePage(initialUsername: '', email: ''),
            );
          }
        }

        // Static fallback routes
        switch (settings.name) {
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const SignInPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/restaurants':
            return MaterialPageRoute(builder: (_) => RestaurantListingPage());
          case '/reviewform':
            return MaterialPageRoute(
              builder: (_) => const ReviewFormPage(restaurantId: ''),
            );
        }

        // Unknown route fallback
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
