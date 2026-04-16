import '../models/country.dart';
import '../manager/country_manager.dart';

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  const ValidationResult.valid() : this(isValid: true);
  const ValidationResult.invalid(String message)
    : this(isValid: false, errorMessage: message);
}

/// Abstract phone validator interface
/// Future-ready for custom validation strategies
abstract class PhoneValidator {
  ValidationResult validate(String phoneNumber, Country country);
}

/// Length-based validator (default)
class LengthBasedValidator implements PhoneValidator {
  final CountryManager _manager;

  LengthBasedValidator(this._manager);

  @override
  ValidationResult validate(String phoneNumber, Country country) {
    final error = _manager.validatePhoneNumber(phoneNumber, country);

    if (error != null) {
      return ValidationResult.invalid(error);
    }

    return const ValidationResult.valid();
  }
}

/// Composite validator (supports multiple validation strategies)
class CompositeValidator implements PhoneValidator {
  final List<PhoneValidator> validators;

  CompositeValidator(this.validators);

  @override
  ValidationResult validate(String phoneNumber, Country country) {
    for (var validator in validators) {
      final result = validator.validate(phoneNumber, country);
      if (!result.isValid) {
        return result;
      }
    }
    return const ValidationResult.valid();
  }
}

/// Regex-based validator (for future use)
class RegexValidator implements PhoneValidator {
  final Map<String, RegExp> countryPatterns;

  RegexValidator(this.countryPatterns);

  @override
  ValidationResult validate(String phoneNumber, Country country) {
    final pattern = countryPatterns[country.code];

    if (pattern == null) {
      // No pattern defined, skip validation
      return const ValidationResult.valid();
    }

    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (pattern.hasMatch(digitsOnly)) {
      return const ValidationResult.valid();
    }

    return ValidationResult.invalid(
      'Invalid phone number format for ${country.name}',
    );
  }
}
