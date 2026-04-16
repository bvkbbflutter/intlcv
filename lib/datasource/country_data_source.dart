import '../models/country.dart';

/// Abstract data source for country data
/// Enables pluggable backends (API, local JSON, etc.)
abstract class CountryDataSource {
  /// Fetch country data from the source
  /// Returns null if fetch fails (silent fallback)
  Future<Map<String, Country>?> fetchCountries();

  /// Optional: Check if source is available/reachable
  Future<bool> isAvailable() async => true;
}
