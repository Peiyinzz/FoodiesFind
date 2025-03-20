import 'dart:convert';
import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  final String apiKey;

  ReverseGeocodingService(this.apiKey);

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return null;
    } catch (e) {
      print("Reverse Geocoding Error: $e");
      return null;
    }
  }
}
