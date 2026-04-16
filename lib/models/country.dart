/// Country model representing phone number metadata
class Country {
  /// ISO 3166-1 alpha-2 country code (e.g., "SO", "US")
  final String code;

  /// Dial code without + prefix (e.g., "252", "1")
  final String dialCode;

  /// Display country code (can differ from dialCode for formatting)
  final String displayCC;

  /// Country flag emoji
  final String flag;

  /// Full country code (typically same as dialCode)
  final String fullCountryCode;

  /// Minimum valid phone number length (excluding country code)
  final int minLength;

  /// Maximum valid phone number length (excluding country code)
  final int maxLength;

  /// Country name in English
  final String name;

  /// Optional region code for subdivisions
  final String? regionCode;

  final String? pattern;

  const Country({
    required this.code,
    required this.dialCode,
    required this.displayCC,
    required this.flag,
    required this.fullCountryCode,
    required this.minLength,
    required this.maxLength,
    required this.name,
    this.regionCode,
    this.pattern,
  });

  /// Create a copy with optional field overrides
  Country copyWith({
    String? dialCode,
    String? displayCC,
    String? flag,
    String? fullCountryCode,
    int? minLength,
    int? maxLength,
    String? name,
    String? regionCode,
    String? pattern,
  }) {
    return Country(
      code: code,
      dialCode: dialCode ?? this.dialCode,
      displayCC: displayCC ?? this.displayCC,
      flag: flag ?? this.flag,
      fullCountryCode: fullCountryCode ?? this.fullCountryCode,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      name: name ?? this.name,
      regionCode: regionCode ?? this.regionCode,
      pattern: pattern ?? this.pattern,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'dialCode': dialCode,
      'displayCC': displayCC,
      'flag': flag,
      'fullCountryCode': fullCountryCode,
      'minLength': minLength,
      'maxLength': maxLength,
      'name': name,
      'regionCode': regionCode,
      'pattern': pattern,
    };
  }

  /// Create from JSON
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      code: json['code'] as String,
      dialCode: json['dialCode'] as String,
      displayCC: json['displayCC'] as String,
      flag: json['flag'] as String,
      fullCountryCode: json['fullCountryCode'] as String,
      minLength: json['minLength'] as int,
      maxLength: json['maxLength'] as int,
      name: json['name'] as String,
      regionCode: json['regionCode'] as String?,
    );
  }

  @override
  String toString() {
    return 'Country(code: $code, name: $name, dialCode: $dialCode, minLength: $minLength, maxLength: $maxLength)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Country && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
