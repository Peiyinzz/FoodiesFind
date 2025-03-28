// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config.dart';
// import '../firebase_options.dart';
// import 'package:flutter/widgets.dart';

// // Firebase packages
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // A helper function to fetch and store places for a given type.
// Future<void> fetchAndStore({
//   required String type,
//   required double lat,
//   required double lng,
//   required int radius,
//   required String apiKey,
// }) async {
//   print('\n=== Fetching type="$type" ===');

//   // Build the Nearby Search URL
//   final nearbyUrl =
//       'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
//       '?location=$lat,$lng'
//       '&radius=$radius'
//       '&type=$type'
//       '&key=$apiKey';

//   print('Nearby Search URL: $nearbyUrl');
//   final nearbyResponse = await http.get(Uri.parse(nearbyUrl));
//   print('Nearby search HTTP status: ${nearbyResponse.statusCode}');
//   if (nearbyResponse.statusCode != 200) {
//     print('Failed to fetch nearby places for type=$type');
//     return;
//   }

//   final nearbyData = jsonDecode(nearbyResponse.body) as Map<String, dynamic>;
//   print('Nearby search API status: ${nearbyData['status']}');

//   final results = (nearbyData['results'] as List?) ?? [];
//   print('Found ${results.length} places for type=$type.');

//   // For each place, call Place Details
//   for (final place in results) {
//     final placeId = place['place_id'];
//     if (placeId == null) {
//       print('Skipping a place with no place_id.');
//       continue;
//     }

//     print('\nFetching details for placeId: $placeId (type=$type)');

//     // Build the Place Details URL
//     final detailsUrl =
//         'https://maps.googleapis.com/maps/api/place/details/json'
//         '?place_id=$placeId'
//         '&fields=name,rating,formatted_address,geometry,'
//         'formatted_phone_number,opening_hours,types,reviews'
//         '&key=$apiKey';

//     print('Details URL: $detailsUrl');
//     final detailsResponse = await http.get(Uri.parse(detailsUrl));
//     print('Details HTTP status: ${detailsResponse.statusCode}');
//     if (detailsResponse.statusCode != 200) {
//       print('Failed to fetch details for $placeId');
//       continue;
//     }

//     final detailsData =
//         jsonDecode(detailsResponse.body) as Map<String, dynamic>;
//     print('Place Details API status: ${detailsData['status']}');
//     final detailsResult = detailsData['result'] as Map<String, dynamic>?;
//     if (detailsResult == null) {
//       print('No details found for $placeId');
//       continue;
//     }

//     // Parse detail fields
//     final name = detailsResult['name'] as String? ?? '';
//     final rating = (detailsResult['rating'] as num?)?.toDouble() ?? 0.0;
//     final address = detailsResult['formatted_address'] as String? ?? '';
//     final phone = detailsResult['formatted_phone_number'] as String? ?? '';

//     // geometry -> location -> lat/lng
//     final geometry = detailsResult['geometry'] as Map<String, dynamic>?;
//     final location = geometry?['location'] as Map<String, dynamic>?;
//     final detailLat = (location?['lat'] as num?)?.toDouble() ?? 0.0;
//     final detailLng = (location?['lng'] as num?)?.toDouble() ?? 0.0;

//     // Parse types as an array
//     final placeTypes =
//         (detailsResult['types'] as List<dynamic>?)
//             ?.map((t) => t.toString())
//             .toList() ??
//         [];

//     // Build an openingHoursList in Monday->Sunday order
//     final oh = detailsResult['opening_hours'] as Map<String, dynamic>?;
//     final weekdayText = oh?['weekday_text'] as List?;
//     final openingHoursList = <String>[];
//     if (weekdayText != null) {
//       final tempMap = <String, String>{};
//       for (final line in weekdayText) {
//         final text = line as String;
//         final parts = text.split(': ');
//         if (parts.length == 2) {
//           final day = parts[0].trim();
//           final hours = parts[1].trim();
//           tempMap[day] = hours;
//         }
//       }
//       final dayOrder = [
//         'Monday',
//         'Tuesday',
//         'Wednesday',
//         'Thursday',
//         'Friday',
//         'Saturday',
//         'Sunday',
//       ];
//       for (final day in dayOrder) {
//         if (tempMap.containsKey(day)) {
//           openingHoursList.add('$day: ${tempMap[day]}');
//         } else {
//           // Optionally mark as closed
//           openingHoursList.add('$day: Closed');
//         }
//       }
//     }

//     // Write the main doc to Firestore
//     final docRef = FirebaseFirestore.instance
//         .collection('restaurants')
//         .doc(placeId);

//     await docRef.set({
//       'name': name,
//       'address': address,
//       'loc': GeoPoint(detailLat, detailLng),
//       'rating': rating,
//       'phoneNum': phone,
//       'openingHours': openingHoursList,
//       'types': placeTypes,
//       'lastUpdated': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     // Limit to top 5 reviews
//     final googleReviews = detailsResult['reviews'] as List<dynamic>? ?? [];
//     final top5Reviews = googleReviews.take(5).toList();

//     for (final review in top5Reviews) {
//       final authorName = review['author_name'] as String? ?? 'Anonymous';
//       final reviewRating = (review['rating'] as num?)?.toDouble() ?? 0.0;
//       final text = review['text'] as String? ?? '';
//       final timeEpoch = review['time'] as int? ?? 0;

//       final reviewDoc = {
//         'authorName': authorName,
//         'rating': reviewRating,
//         'text': text,
//         'timeEpoch': timeEpoch,
//         'source': 'places',
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       // Subcollection: restaurants/{placeId}/reviews
//       await docRef.collection('reviews').add(reviewDoc);
//     }

//     print(
//       'Stored "$name" (placeId: $placeId) for type=$type with ${top5Reviews.length} reviews.',
//     );
//   }

//   print('Done fetching type="$type".');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   print('Script started...');

//   // 1. Initialize Firebase
//   print('Initializing Firebase...');
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('Firebase initialized.');

//   // 2. Common parameters
//   final String apiKey = googleApiKey;
//   final double lat = 5.326;
//   final double lng = 100.281;
//   final int radius = 2000;

//   // 3. Query #1: "restaurant"
//   await fetchAndStore(
//     type: 'restaurant',
//     lat: lat,
//     lng: lng,
//     radius: radius,
//     apiKey: apiKey,
//   );

//   // 4. Query #2: "cafe"
//   await fetchAndStore(
//     type: 'cafe',
//     lat: lat,
//     lng: lng,
//     radius: radius,
//     apiKey: apiKey,
//   );

//   print('All queries done. Script finished!');
// }
