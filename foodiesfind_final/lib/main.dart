import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/homepage.dart';
import 'screens/restaurantlist.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Set system UI overlay for fullscreen but safe (edge-to-edge)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // statusBarColor: Colors.transparent,
      // statusBarIconBrightness: Brightness.light, // ✅ FIXED: black icons
      // systemNavigationBarColor: Colors.white,
      // systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ Enable edge-to-edge layout
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
      home: const HomePage(),
      routes: {'/restaurants': (context) => RestaurantListingPage()},
    );
  }
}
