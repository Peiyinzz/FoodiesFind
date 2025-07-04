import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:foodiesfind_final/screens/sign_up.dart';
import 'package:foodiesfind_final/screens/sign_in.dart';
import 'package:foodiesfind_final/screens/user_profile.dart';
import 'package:foodiesfind_final/screens/review_form.dart';
import 'package:foodiesfind_final/screens/restaurant_menu.dart';
import 'package:foodiesfind_final/widgets/menu_upload.dart';
import 'package:foodiesfind_final/screens/reviews_history.dart';
import 'package:foodiesfind_final/screens/manage_menu.dart';
import 'package:foodiesfind_final/screens/manage_item.dart';
import 'package:foodiesfind_final/screens/manage_category.dart';
import 'package:foodiesfind_final/screens/near_me.dart';
import 'package:foodiesfind_final/screens/featured_restaurants.dart';
import 'package:foodiesfind_final/screens/manage_restaurant.dart';

// ← import your new dashboard screen:
import 'package:foodiesfind_final/screens/foodies_dashboard.dart';

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
      home: const HomePage(),

      onGenerateRoute: (settings) {
        final user = FirebaseAuth.instance.currentUser;

        // ── User Profile ─────────────────────────────────────────
        if (settings.name == '/userprofile') {
          final args = settings.arguments;
          if (user == null) {
            return MaterialPageRoute(
              builder:
                  (_) => const UserProfilePage(initialUsername: '', email: ''),
            );
          }
          if (args is Map<String, String>) {
            return MaterialPageRoute(
              builder:
                  (_) => UserProfilePage(
                    initialUsername: args['username'] ?? '',
                    email: args['email'] ?? '',
                  ),
            );
          }
          return MaterialPageRoute(
            builder:
                (_) => const UserProfilePage(initialUsername: '', email: ''),
          );
        }

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
            final args = settings.arguments as Map<String, dynamic>;
            final restaurantId = args['restaurantId'] ?? '';
            if (user == null) {
              return MaterialPageRoute(builder: (_) => const HomePage());
            }
            return MaterialPageRoute(
              builder: (_) => ReviewFormPage(restaurantId: restaurantId),
            );

          case '/restaurantMenu':
            final args = settings.arguments as Map<String, String>?;
            final restaurantId = args?['restaurantId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => RestaurantMenuPage(restaurantId: restaurantId),
            );

          case '/uploadmenu':
            final args = settings.arguments as Map<String, String>?;
            final restaurantId = args?['restaurantId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => MenuUploadPage(restaurantId: restaurantId),
            );

          case '/reviewsHistory':
            if (user == null) {
              return MaterialPageRoute(builder: (_) => const HomePage());
            }
            return MaterialPageRoute(builder: (_) => const ReviewHistoryPage());

          case '/manageMenu':
            final args = settings.arguments as Map<String, String>?;
            final restaurantId = args?['restaurantId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => ManageMenuPage(restaurantId: restaurantId),
            );

          case '/manageItem':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => ManageItemPage(
                    restaurantId: args['restaurantId'],
                    itemId: args['itemId'],
                  ),
            );

          case '/manageCategory':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder:
                  (_) => ManageCategoryPage(
                    restaurantId: args['restaurantId'],
                    categoryName: args['categoryName'],
                  ),
            );

          case '/nearMe':
            final args = settings.arguments as Map<String, dynamic>?;
            final restaurantId = args?['restaurantId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => NearbyMapScreen(restaurantId: restaurantId),
            );

          case '/featuredRestaurants':
            return MaterialPageRoute(
              builder: (_) => const FeaturedRestaurantPage(),
            );

          case '/manageRestaurant':
            final args = settings.arguments as Map<String, dynamic>?;
            final restaurantId = args?['restaurantId'] ?? '';
            return MaterialPageRoute(
              builder: (_) => ManageRestaurantPage(restaurantId: restaurantId),
            );

          // ── NEW: Foodies Dashboard ────────────────────────────────
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => const FoodiesDashboardPage(),
            );
        }

        // ── Fallback ───────────────────────────────────────────────
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
    );
  }
}
