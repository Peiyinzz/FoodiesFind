import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../firebase_options.dart';
import 'package:flutter/widgets.dart';

// Firebase packages
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Initialize the binding so ServicesBinding.instance is available.
  WidgetsFlutterBinding.ensureInitialized();
  print('Script started...');

  // 1. Initialize Firebase
  print('Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase initialized.');

  // 2. Define your Google Places API parameters
  final String apiKey = googleApiKey; // Must be enabled for Places
  final double lat = 5.326; // e.g. your location near Arena Curve
  final double lng = 100.281;
  final int radius = 1500; // in meters (1.5 km radius)
  final String type = 'restaurant';

  // Build the Nearby Search URL
  final nearbyUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&type=$type'
      '&key=$apiKey';

  print('Nearby Search URL: $nearbyUrl');

  // 3. Fetch Nearby Restaurants
  print('Fetching nearby places...');
  final nearbyResponse = await http.get(Uri.parse(nearbyUrl));
  print('Nearby search HTTP status: ${nearbyResponse.statusCode}');
  if (nearbyResponse.statusCode != 200) {
    print('Failed to fetch nearby places: ${nearbyResponse.statusCode}');
    return;
  }

  final nearbyData = jsonDecode(nearbyResponse.body) as Map<String, dynamic>;
  // Optional: Check the "status" field from the Places API
  print('Nearby search API status: ${nearbyData['status']}');

  final results = (nearbyData['results'] as List?) ?? [];
  print('Found ${results.length} places nearby.');

  // If zero, you can check logs or lat/lng/radius
  if (results.isEmpty) {
    print('No places found. Possibly out of range or invalid parameters.');
  }

  // 4. For each place, call Place Details to get full info
  for (final place in results) {
    final placeId = place['place_id'];
    if (placeId == null) {
      print('Skipping a place with no place_id.');
      continue;
    }
    print('\nFetching details for placeId: $placeId');

    // Build the Details URL
    final detailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,rating,formatted_address,geometry,formatted_phone_number,opening_hours'
        '&key=$apiKey';

    print('Details URL: $detailsUrl');
    final detailsResponse = await http.get(Uri.parse(detailsUrl));
    print('Details HTTP status: ${detailsResponse.statusCode}');
    if (detailsResponse.statusCode != 200) {
      print(
        'Failed to fetch details for $placeId: ${detailsResponse.statusCode}',
      );
      continue;
    }

    final detailsData =
        jsonDecode(detailsResponse.body) as Map<String, dynamic>;
    final detailsResult = detailsData['result'] as Map<String, dynamic>?;

    // Optional: Print the "status" from the details response
    print('Place Details API status: ${detailsData['status']}');

    if (detailsResult == null) {
      print('No details found for $placeId');
      continue;
    }

    // 5. Parse the detail fields you need
    final name = detailsResult['name'] as String? ?? '';
    final rating = (detailsResult['rating'] as num?)?.toDouble() ?? 0.0;
    final address = detailsResult['formatted_address'] as String? ?? '';
    final phone = detailsResult['formatted_phone_number'] as String? ?? '';

    // geometry -> location -> lat/lng
    final geometry = detailsResult['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final detailLat = (location?['lat'] as num?)?.toDouble() ?? 0.0;
    final detailLng = (location?['lng'] as num?)?.toDouble() ?? 0.0;

    print(
      'Parsed details: name=$name, rating=$rating, address=$address, phone=$phone',
    );
    print('Coordinates: ($detailLat, $detailLng)');

    // opening_hours -> weekday_text
    final openingHoursMap = <String, String>{};
    final oh = detailsResult['opening_hours'] as Map<String, dynamic>?;
    final weekdayText = oh?['weekday_text'] as List?;
    if (weekdayText != null) {
      print('Opening hours data found.');
      for (final line in weekdayText) {
        final text = line as String;
        final parts = text.split(': ');
        if (parts.length == 2) {
          final day = parts[0].toLowerCase(); // e.g. "monday"
          final hours = parts[1]; // e.g. "11:30 am – 9:30 pm"
          openingHoursMap[day] = hours;
        }
      }
    } else {
      print('No opening_hours or weekday_text found.');
    }

    // 6. Write to Firestore
    print('Writing "$name" to Firestore...');
    final docRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(placeId);

    await docRef.set({
      'name': name,
      'address': address,
      'loc': GeoPoint(detailLat, detailLng),
      'rating': rating,
      'phoneNum': phone,
      'openingHours': openingHoursMap,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('Stored "$name" (placeId: $placeId) in Firestore.');
  }

  print('Done! Script finished.');
}
