import 'package:flutter/material.dart';

/// Configuration for CustomPhoneField
class PhoneFieldConfig {
  /// Initial country code (e.g., "US", "IN")
  final String? initialCountryCode;

  /// Default country if initialCountryCode is null
  final String defaultCountryCode;

  /// Enable search in country picker
  final bool enableSearch;

  /// Show country flag
  final bool showFlag;

  /// Show country dial code
  final bool showDialCode;

  /// Show dropdown icon
  final bool showDropdownIcon;

  /// Dropdown icon
  final IconData dropdownIcon;

  /// Search decoration
  final InputDecoration? searchDecoration;

  /// Dialog title
  final String dialogTitle;

  /// Search hint text
  final String searchHintText;

  /// Country selector button padding
  final EdgeInsetsGeometry selectorButtonPadding;

  /// Input decoration
  final InputDecoration? decoration;

  /// Text style for dial code
  final TextStyle? dialCodeTextStyle;

  /// Autofocus the input field
  final bool autofocus;

  /// Obscure text (for PIN-like inputs)
  final bool obscureText;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction textInputAction;

  /// Auto validate mode
  final AutovalidateMode autovalidateMode;

  /// Show error border
  final bool showErrorBorder;

  /// Cursor color
  final Color? cursorColor;

  /// Maximum lines
  final int maxLines;

  /// Minimum lines
  final int minLines;

  /// Max length
  final int? maxLength;

  /// Enable interactive selection
  final bool enableInteractiveSelection;

  /// Read only
  final bool readOnly;

  /// Country filter (only show these countries)
  final List<String>? countryCodes;

  /// Preferred countries (show at top)
  final List<String>? preferredCountries;

  /// Max phone number length (overrides country-specific max)
  final int maxPhoneLength;

  /// Min phone number length (overrides country-specific min)
  final int minPhoneLength;

  /// Empty field error message
  final String emptyErrorMessage;

  /// Success message when valid
  final String? successMessage;

  /// Show success indicator
  final bool showSuccessIndicator;

  /// Success icon
  final IconData successIcon;

  /// Success color
  final Color successColor;

  /// Error color
  final Color errorColor;

  /// Show validation even when field is empty
  final bool showValidationOnEmpty;

  /// Enable pattern validation from country data
  final bool enablePatternValidation;

  const PhoneFieldConfig({
    this.initialCountryCode,
    this.defaultCountryCode = 'US',
    this.enableSearch = true,
    this.showFlag = true,
    this.showDialCode = true,
    this.showDropdownIcon = true,
    this.dropdownIcon = Icons.arrow_drop_down,
    this.searchDecoration,
    this.dialogTitle = 'Select Country',
    this.searchHintText = 'Search by name or dial code',
    this.selectorButtonPadding = const EdgeInsets.all(8),
    this.decoration,
    this.dialCodeTextStyle,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.phone,
    this.textInputAction = TextInputAction.done,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.showErrorBorder = true,
    this.cursorColor,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.enableInteractiveSelection = true,
    this.readOnly = false,
    this.countryCodes,
    this.preferredCountries,
    this.maxPhoneLength = 0,
    this.minPhoneLength = 0,
    this.emptyErrorMessage = 'Please enter phone number',
    this.successMessage,
    this.showSuccessIndicator = true,
    this.successIcon = Icons.check_circle_outline_rounded,
    this.successColor = Colors.green,
    this.errorColor = Colors.red,
    this.showValidationOnEmpty = false,
    this.enablePatternValidation = true,
  });

  PhoneFieldConfig copyWith({
    String? initialCountryCode,
    String? defaultCountryCode,
    bool? enableSearch,
    bool? showFlag,
    bool? showDialCode,
    bool? showDropdownIcon,
    IconData? dropdownIcon,
    InputDecoration? searchDecoration,
    String? dialogTitle,
    String? searchHintText,
    EdgeInsetsGeometry? selectorButtonPadding,
    InputDecoration? decoration,
    TextStyle? dialCodeTextStyle,
    bool? autofocus,
    bool? obscureText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    AutovalidateMode? autovalidateMode,
    bool? showErrorBorder,
    Color? cursorColor,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool? enableInteractiveSelection,
    bool? readOnly,
    List<String>? countryCodes,
    List<String>? preferredCountries,
  }) {
    return PhoneFieldConfig(
      initialCountryCode: initialCountryCode ?? this.initialCountryCode,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
      enableSearch: enableSearch ?? this.enableSearch,
      showFlag: showFlag ?? this.showFlag,
      showDialCode: showDialCode ?? this.showDialCode,
      showDropdownIcon: showDropdownIcon ?? this.showDropdownIcon,
      dropdownIcon: dropdownIcon ?? this.dropdownIcon,
      searchDecoration: searchDecoration ?? this.searchDecoration,
      dialogTitle: dialogTitle ?? this.dialogTitle,
      searchHintText: searchHintText ?? this.searchHintText,
      selectorButtonPadding:
          selectorButtonPadding ?? this.selectorButtonPadding,
      decoration: decoration ?? this.decoration,
      dialCodeTextStyle: dialCodeTextStyle ?? this.dialCodeTextStyle,
      autofocus: autofocus ?? this.autofocus,
      obscureText: obscureText ?? this.obscureText,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      showErrorBorder: showErrorBorder ?? this.showErrorBorder,
      cursorColor: cursorColor ?? this.cursorColor,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      maxLength: maxLength ?? this.maxLength,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
      readOnly: readOnly ?? this.readOnly,
      countryCodes: countryCodes ?? this.countryCodes,
      preferredCountries: preferredCountries ?? this.preferredCountries,
    );
  }
}
