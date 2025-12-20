
import 'dart:convert';
import 'package:http/http.dart' as http;

class Place {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;

  Place({
    required this.placeId,
    required this.name, 
    required this.latitude, 
    required this.longitude
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'],
      name: json['name'],
      latitude: json['geometry']['location']['lat'],
      longitude: json['geometry']['location']['lng'],
    );
  }
}

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  Future<List<Place>> findPlaces(double lat, double lng, String placeType) async {
    final String url = 
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=$placeType&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final List results = data['results'];
        return results.map((place) => Place.fromJson(place)).toList();
      } else {
        print('Places API Error: ${data['status']}');
        return [];
      }
    } else {
      throw Exception('Failed to fetch places from API');
    }
  }
}
