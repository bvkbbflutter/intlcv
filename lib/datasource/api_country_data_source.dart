import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';
import 'country_data_source.dart';

/// API-based country data source
/// Fetches country data from a remote endpoint
class ApiCountryDataSource implements CountryDataSource {
  final String apiUrl;
  final Duration timeout;
  final Map<String, String>? headers;

  ApiCountryDataSource({
    required this.apiUrl,
    this.timeout = const Duration(seconds: 10),
    this.headers,
  });

  @override
  Future<Map<String, Country>?> fetchCountries() async {
    try {
      final response = await http
          .get(Uri.parse(apiUrl), headers: headers)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final Map<String, Country> countries = {};

        for (var item in jsonList) {
          try {
            final country = Country.fromJson(item as Map<String, dynamic>);
            countries[country.code] = country;
          } catch (e) {
            // Skip malformed entries
            print('Warning: Skipping malformed country entry: $e');
          }
        }

        return countries.isNotEmpty ? countries : null;
      }

      print('API returned status code: ${response.statusCode}');
      return null;
    } catch (e) {
      // Silent fallback - API failure should not break the app
      print('Country API fetch failed: $e');
      return null;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .head(Uri.parse(apiUrl), headers: headers)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
