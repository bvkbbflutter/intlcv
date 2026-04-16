import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';

/// Cache for country data using SharedPreferences
class CountryCache {
  static const String _cacheKey = 'phone_field_countries_cache';
  static const String _timestampKey = 'phone_field_countries_timestamp';
  static const Duration _cacheExpiry = Duration(days: 7);

  /// Save countries to cache
  Future<void> saveCountries(Map<String, Country> countries) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonList = countries.values
          .map((country) => country.toJson())
          .toList();

      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to save countries to cache: $e');
    }
  }

  /// Load countries from cache
  Future<Map<String, Country>?> loadCountries() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if cache exists
      if (!prefs.containsKey(_cacheKey)) {
        return null;
      }

      // Check cache expiry
      final timestamp = prefs.getInt(_timestampKey);
      if (timestamp != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = DateTime.now().difference(cacheDate);

        if (age > _cacheExpiry) {
          print('Cache expired (${age.inDays} days old)');
          await clearCache();
          return null;
        }
      }

      // Load and parse
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = json.decode(jsonString);
      final Map<String, Country> countries = {};

      for (var item in jsonList) {
        final country = Country.fromJson(item as Map<String, dynamic>);
        countries[country.code] = country;
      }

      return countries.isNotEmpty ? countries : null;
    } catch (e) {
      print('Failed to load countries from cache: $e');
      return null;
    }
  }

  /// Clear the cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_timestampKey);
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  /// Check if cache is valid
  Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_cacheKey)) {
        return false;
      }

      final timestamp = prefs.getInt(_timestampKey);
      if (timestamp == null) return false;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cacheDate);

      return age <= _cacheExpiry;
    } catch (e) {
      return false;
    }
  }
}
