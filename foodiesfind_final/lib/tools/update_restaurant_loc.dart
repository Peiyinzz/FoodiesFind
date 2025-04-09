// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> fixAllRestaurantLocFields() async {
//   final firestore = FirebaseFirestore.instance;

//   final snapshot = await firestore.collection('restaurants').get();

//   for (var doc in snapshot.docs) {
//     final data = doc.data();
//     final loc = data['loc'];

//     if (loc is List &&
//         loc.length == 2 &&
//         loc[0] is String &&
//         loc[1] is String) {
//       final latRaw = loc[0].toString();
//       final lonRaw = loc[1].toString();

//       print('📍 Found loc for ${doc.id}: [$latRaw, $lonRaw]');

//       try {
//         double cleanCoordinate(String coord) {
//           return double.parse(coord.replaceAll(RegExp(r'[^\d.-]'), ''));
//         }

//         final lat = cleanCoordinate(latRaw);
//         final lon = cleanCoordinate(lonRaw);

//         await firestore.collection('restaurants').doc(doc.id).update({
//           'loc': [lat, lon],
//         });

//         print('✅ Updated ${doc.id} → [$lat, $lon]');
//       } catch (e) {
//         print('❌ Failed to update ${doc.id}: $e');
//       }
//     } else {
//       print('⚠️ Skipped ${doc.id} — loc is not a list of strings');
//     }
//   }

//   print('🎉 Finished updating all loc fields.');
// }
