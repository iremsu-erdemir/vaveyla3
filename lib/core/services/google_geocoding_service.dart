import 'dart:convert';

import 'package:http/http.dart' as http;

class GoogleGeocodingService {
  static const String _apiKey = 'AIzaSyDw-141Zuzz-kSUYReoANpEpUIASTIVf44';

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw GoogleGeocodingException(
        'GOOGLE_MAPS_API_KEY tanimli degil.',
      );
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'latlng': '$latitude,$longitude',
        'key': _apiKey,
        'language': 'tr',
      },
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GoogleGeocodingException(
        'Google Geocoding istegi basarisiz oldu.',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw GoogleGeocodingException('Gecersiz cevap formati.');
    }

    final status = data['status']?.toString() ?? 'UNKNOWN';
    if (status != 'OK') {
      final error = data['error_message']?.toString();
      throw GoogleGeocodingException(
        error ?? 'Google Geocoding hatasi: $status',
      );
    }

    final results = data['results'];
    if (results is List && results.isNotEmpty) {
      final first = results.first;
      if (first is Map<String, dynamic>) {
        return first['formatted_address']?.toString();
      }
    }

    return null;
  }
}

class GoogleGeocodingException implements Exception {
  GoogleGeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}
