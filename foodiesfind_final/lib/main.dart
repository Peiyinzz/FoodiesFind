import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/sign_up.dart';
import 'screens/homepage.dart';
import 'screens/restaurantlist.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Only initialize if no default app exists.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // If it's a duplicate-app error, log and continue.
    if (e.toString().contains("already exists")) {
      debugPrint(
        "Firebase already initialized. Skipping duplicate initialization.",
      );
    } else {
      rethrow;
    }
  }

  // Set system UI overlay for fullscreen (edge-to-edge)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // You can adjust these if needed.
      // statusBarColor: Colors.transparent,
      // statusBarIconBrightness: Brightness.light,
      // systemNavigationBarColor: Colors.white,
      // systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Enable edge-to-edge layout
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
      // Set the home page to SignUpPage so it loads at startup.
      home: const SignUpPage(),
      // The "routes" property is a map of named routes that can be navigated to in your app.
      routes: {
        '/home': (context) => const HomePage(),
        '/restaurants': (context) => RestaurantListingPage(),
        // Add other routes as needed.
      },
    );
  }
}
