import '../models/country.dart';
import '../data/default_countries.dart';
import '../datasource/country_data_source.dart';
import '../cache/country_cache.dart';

/// Centralized country data manager
/// Handles data priority: Local overrides > API > Cache > Defaults
class CountryManager {
  static final CountryManager _instance = CountryManager._internal();
  factory CountryManager() => _instance;
  CountryManager._internal();

  /// Current active countries
  Map<String, Country> _countries = {};

  /// Local overrides (highest priority)
  Map<String, Country> _overrides = {};

  /// Cache manager
  final CountryCache _cache = CountryCache();

  /// Whether the manager has been initialized
  bool _initialized = false;

  /// Get all available countries
  Map<String, Country> get countries => _getEffectiveCountries();

  /// Get a specific country by code
  Country? getCountry(String code) {
    return _getEffectiveCountries()[code.toUpperCase()];
  }

  /// Get countries sorted by name
  List<Country> getSortedCountries() {
    final countryList = _getEffectiveCountries().values.toList();
    countryList.sort((a, b) => a.name.compareTo(b.name));
    return countryList;
  }

  /// Search countries by name or dial code
  List<Country> searchCountries(String query) {
    if (query.isEmpty) return getSortedCountries();

    final lowerQuery = query.toLowerCase();
    return _getEffectiveCountries().values.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.dialCode.contains(query) ||
          country.code.toLowerCase().contains(lowerQuery);
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Initialize the manager
  Future<void> initialize({
    CountryDataSource? remoteSource,
    List<Country> overrides = const [],
  }) async {
    if (_initialized) return;

    // 1. Load default countries
    _countries = Map.from(defaultCountries);

    // 2. Try to load from cache
    final cachedCountries = await _cache.loadCountries();
    if (cachedCountries != null && cachedCountries.isNotEmpty) {
      _countries = cachedCountries;
    }

    // 3. Fetch from API if available
    if (remoteSource != null) {
      final apiCountries = await remoteSource.fetchCountries();
      if (apiCountries != null && apiCountries.isNotEmpty) {
        _countries = apiCountries;
        // Save to cache for next time
        await _cache.saveCountries(apiCountries);
      }
    }

    // 4. Apply overrides
    if (overrides.isNotEmpty) {
      for (var country in overrides) {
        _overrides[country.code] = country;
      }
    }

    _initialized = true;
  }

  /// Override a specific country
  /// Throws exception if country code doesn't exist
  void overrideCountry(Country country) {
    if (!defaultCountries.containsKey(country.code)) {
      throw ArgumentError(
        'Country code "${country.code}" does not exist in default dataset. '
        'Use addCountry() to add new countries.',
      );
    }
    _overrides[country.code] = country;
  }

  /// Add a new country (not in defaults)
  void addCountry(Country country) {
    _overrides[country.code] = country;
  }

  /// Upsert a country (add or override)
  void upsertCountry(Country country) {
    _overrides[country.code] = country;
  }

  /// Override all countries at once
  void overrideAll(Map<String, Country> countries) {
    _overrides = Map.from(countries);
  }

  /// Remove a specific override
  void removeOverride(String countryCode) {
    _overrides.remove(countryCode.toUpperCase());
  }

  /// Clear all overrides
  void clearOverrides() {
    _overrides.clear();
  }

  /// Reset to default countries (clears cache and overrides)
  Future<void> reset() async {
    _countries = Map.from(defaultCountries);
    _overrides.clear();
    await _cache.clearCache();
    _initialized = false;
  }

  /// Refresh data from remote source
  Future<void> refresh(CountryDataSource remoteSource) async {
    final apiCountries = await remoteSource.fetchCountries();
    if (apiCountries != null && apiCountries.isNotEmpty) {
      _countries = apiCountries;
      await _cache.saveCountries(apiCountries);
    }
  }

  /// Get effective countries (with overrides applied)
  Map<String, Country> _getEffectiveCountries() {
    final effective = Map<String, Country>.from(_countries);
    effective.addAll(_overrides);
    return effective;
  }

  /// Validate a phone number for a country
  String? validatePhoneNumber(String phoneNumber, Country country) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return 'Phone number is required';
    }

    final length = digitsOnly.length;

    if (length < country.minLength) {
      return 'Phone number is too short (min ${country.minLength} digits)';
    }

    if (length > country.maxLength) {
      return 'Phone number is too long (max ${country.maxLength} digits)';
    }

    return null; // Valid
  }

  /// Get country by dial code
  Country? getCountryByDialCode(String dialCode) {
    final cleanDialCode = dialCode.replaceAll(RegExp(r'[^\d]'), '');
    return _getEffectiveCountries().values.firstWhere(
      (country) => country.dialCode == cleanDialCode,
      orElse: () => _getEffectiveCountries().values.first,
    );
  }

  /// Get country by country code (ISO)
  Country? getCountryByCode(String code) {
    final upperCode = code.toUpperCase();

    final countries = _getEffectiveCountries();

    return countries.values.firstWhere(
      (country) => country.code.toUpperCase() == upperCode,
      orElse: () => countries.values.first, // fallback (optional)
    );
  }
}
