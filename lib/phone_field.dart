library;

// Models
export 'models/country.dart';

// Data
export 'data/default_countries.dart';

// Manager
export 'manager/country_manager.dart';

// Data Sources
export 'datasource/country_data_source.dart';
export 'datasource/api_country_data_source.dart';

// Cache
export 'cache/country_cache.dart';

// Validator
export 'validator/phone_validator.dart';

// Config
export 'config/phone_field_config.dart';

// Widgets
export 'widgets/custom_phone_field.dart';

import 'datasource/country_data_source.dart';
import 'manager/country_manager.dart';
import 'models/country.dart';

/// PhoneField entry point
class PhoneField {
  /// Initialize the phone field plugin
  ///
  /// [remoteSource] - Optional remote data source (API)
  /// [overrides] - Local country overrides
  ///
  /// Example:
  /// ```dart
  /// await PhoneField.initialize(
  ///   remoteSource: ApiCountryDataSource(
  ///     apiUrl: 'https://api.example.com/countries',
  ///   ),
  ///   overrides: [
  ///     Country(
  ///       code: 'SO',
  ///       dialCode: '252',
  ///       displayCC: '252',
  ///       flag: '🇸🇴',
  ///       fullCountryCode: '252',
  ///       minLength: 9,
  ///       maxLength: 9,
  ///       name: 'Somalia',
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<void> initialize({
    CountryDataSource? remoteSource,
    List<Country> overrides = const [],
  }) async {
    final manager = CountryManager();
    await manager.initialize(remoteSource: remoteSource, overrides: overrides);
  }

  /// Get the country manager instance
  static CountryManager get manager => CountryManager();
}
