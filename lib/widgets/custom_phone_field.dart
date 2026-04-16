import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/country.dart';
import '../manager/country_manager.dart';
import '../config/phone_field_config.dart';

/// Phone number data model
class PhoneNumber {
  final Country country;
  final String phoneNumber;

  PhoneNumber({required this.country, required this.phoneNumber});

  /// Get complete phone number with country code
  String get completeNumber {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '+${country.dialCode}$digits';
  }

  /// Get phone number without country code
  String get number => phoneNumber;

  @override
  String toString() => completeNumber;
}

/// Custom phone input field with country selection
class CustomPhoneField extends StatefulWidget {
  /// Configuration
  final PhoneFieldConfig config;

  /// Called when phone number changes
  final ValueChanged<PhoneNumber>? onChanged;

  /// Custom validator
  final FormFieldValidator<String>? validator;

  /// Controller for the text field
  final TextEditingController? controller;

  /// Focus node
  final FocusNode? focusNode;

  /// On country changed
  final ValueChanged<Country>? onCountryChanged;

  /// On submit
  final ValueChanged<String>? onSubmit;

  /// Initial country dial code (e.g., '+91', '91', '+1')
  final String? initialDialCode;

  /// Initial country code (e.g., 'IN', 'US')
  final String? initialCountryCode;

  const CustomPhoneField({
    Key? key,
    this.config = const PhoneFieldConfig(),
    this.onChanged,
    this.validator,
    this.controller,
    this.focusNode,
    this.onCountryChanged,
    this.onSubmit,
    this.initialDialCode,
    this.initialCountryCode,
  }) : super(key: key);

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late Country _selectedCountry;
  final CountryManager _manager = CountryManager();
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _initializeCountry();

    // Add listener for external controller changes
    if (widget.controller != null) {
      widget.controller!.addListener(_onExternalControllerChanged);
    }
  }

  void _onExternalControllerChanged() {
    if (_controller.text != widget.controller!.text) {
      _controller.text = widget.controller!.text;
      _validateAndUpdate(_controller.text);
    }
  }

  void _initializeCountry() {
    Country? foundCountry;

    // Priority 1: Try to find by dial code
    if (widget.initialDialCode != null && widget.initialDialCode!.isNotEmpty) {
      final cleanDialCode = widget.initialDialCode!.replaceAll('+', '').trim();
      foundCountry = _manager.getCountryByDialCode(cleanDialCode);
    }

    // Priority 2: Try to find by country code
    if (foundCountry == null &&
        widget.initialCountryCode != null &&
        widget.initialCountryCode!.isNotEmpty) {
      foundCountry = _manager.getCountry(widget.initialCountryCode!);
    }

    // Priority 3: Use config initial country code
    if (foundCountry == null && widget.config.initialCountryCode != null) {
      foundCountry = _manager.getCountry(widget.config.initialCountryCode!);
    }

    // Priority 4: Use config default country code
    if (foundCountry == null) {
      foundCountry = _manager.getCountry(widget.config.defaultCountryCode);
    }

    // Priority 5: Fallback to first country
    _selectedCountry = foundCountry ?? _manager.countries.values.first;
  }

  @override
  void didUpdateWidget(CustomPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initial dial code or country code changed
    if (oldWidget.initialDialCode != widget.initialDialCode ||
        oldWidget.initialCountryCode != widget.initialCountryCode) {
      _initializeCountry();
      _controller.clear();
      _hasInteracted = false;
      _errorText = null;
      setState(() {});
    }

    // Update controller if changed
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onExternalControllerChanged);
      if (widget.controller != null) {
        widget.controller!.addListener(_onExternalControllerChanged);
        _controller.text = widget.controller!.text;
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      widget.controller!.removeListener(_onExternalControllerChanged);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onCountryChanged(Country country) {
    setState(() {
      _selectedCountry = country;
      _controller.clear();
      _hasInteracted = false;
      _errorText = null;
    });
    widget.onCountryChanged?.call(country);
    _notifyChange();
  }

  void _notifyChange() {
    final phoneNumber = PhoneNumber(
      country: _selectedCountry,
      phoneNumber: _controller.text,
    );
    widget.onChanged?.call(phoneNumber);
  }

  String? _validateInput(String value) {
    // Skip validation if not interacted
    if (!_hasInteracted && !widget.config.showValidationOnEmpty) {
      return null;
    }

    // Custom validator from widget
    if (widget.validator != null) {
      final customError = widget.validator!(value);
      if (customError != null) return customError;
    }

    // Check if empty
    if (value.isEmpty) {
      return widget.config.emptyErrorMessage;
    }

    // Get digits only
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // Check max length (custom or country-specific)
    final maxLength = widget.config.maxPhoneLength > 0
        ? widget.config.maxPhoneLength
        : _selectedCountry.maxLength;

    final minLength = widget.config.minPhoneLength > 0
        ? widget.config.minPhoneLength
        : _selectedCountry.minLength;

    // Length validation
    if (digits.length < minLength) {
      return 'Phone number must be at least $minLength digits';
    }

    if (digits.length > maxLength) {
      return 'Phone number cannot exceed $maxLength digits';
    }

    // Country-specific pattern validation if enabled
    if (widget.config.enablePatternValidation &&
        _selectedCountry.pattern != null) {
      final pattern = RegExp(_selectedCountry.pattern!);
      if (!pattern.hasMatch(digits)) {
        return 'Invalid ${_selectedCountry.name} number format';
      }
    }

    return null;
  }

  void _validateAndUpdate(String value) {
    setState(() {
      _hasInteracted = true;
      _errorText = _validateInput(value);
    });
    _notifyChange();
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CountryPickerDialog(
        config: widget.config,
        selectedCountry: _selectedCountry,
        manager: _manager,
      ),
    );

    if (selected != null && selected.code != _selectedCountry.code) {
      _onCountryChanged(selected);
    }
  }

  int _getMaxLength() {
    if (widget.config.maxPhoneLength > 0) {
      return widget.config.maxPhoneLength;
    }
    return _selectedCountry.maxLength;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null && _errorText!.isNotEmpty;
    final isValid =
        _hasInteracted && _errorText == null && _controller.text.isNotEmpty;
    final showSuccess =
        widget.config.showSuccessIndicator && isValid && _hasInteracted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.config.autofocus,
          obscureText: widget.config.obscureText,
          keyboardType: widget.config.keyboardType,
          textInputAction: widget.config.textInputAction,
          cursorColor: widget.config.cursorColor,
          maxLines: widget.config.maxLines,
          minLines: widget.config.minLines,
          maxLength: _getMaxLength(),
          enableInteractiveSelection: widget.config.enableInteractiveSelection,
          readOnly: widget.config.readOnly,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_getMaxLength()),
          ],
          decoration: (widget.config.decoration ?? const InputDecoration())
              .copyWith(
                prefixIcon: _buildCountrySelector(hasError),
                counterText: '',
                errorText: hasError ? _errorText : null,
                errorMaxLines: 2,
              ),
          onChanged: (value) {
            _validateAndUpdate(value);
          },
          onSubmitted: widget.onSubmit,
        ),

        // Success message
        if (showSuccess)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Row(
              children: [
                Icon(
                  widget.config.successIcon,
                  size: 14,
                  color: widget.config.successColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.config.successMessage ?? 'Valid phone number',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.config.successColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCountrySelector(bool hasError) {
    return InkWell(
      onTap: widget.config.readOnly ? null : _showCountryPicker,
      child: Container(
        padding: widget.config.selectorButtonPadding,
        decoration: BoxDecoration(
          border: hasError && widget.config.showErrorBorder
              ? Border(
                  right: BorderSide(color: widget.config.errorColor, width: 1),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.showFlag) ...[
              Text(_selectedCountry.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
            ],
            if (widget.config.showDialCode)
              Text(
                '+${_selectedCountry.dialCode}',
                style:
                    widget.config.dialCodeTextStyle ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            if (widget.config.showDropdownIcon) ...[
              const SizedBox(width: 4),
              Icon(widget.config.dropdownIcon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Country picker dialog
class _CountryPickerDialog extends StatefulWidget {
  final PhoneFieldConfig config;
  final Country selectedCountry;
  final CountryManager manager;

  const _CountryPickerDialog({
    Key? key,
    required this.config,
    required this.selectedCountry,
    required this.manager,
  }) : super(key: key);

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  late List<Country> _allCountries;
  late List<Country> _filteredCountries;
  late List<Country> _preferredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCountries();
    _searchController.addListener(_filterCountries);
  }

  void _initializeCountries() {
    _allCountries = widget.manager.getSortedCountries();

    if (widget.config.countryCodes != null &&
        widget.config.countryCodes!.isNotEmpty) {
      _allCountries = _allCountries
          .where((c) => widget.config.countryCodes!.contains(c.code))
          .toList();
    }

    _preferredCountries = [];
    if (widget.config.preferredCountries != null) {
      for (var code in widget.config.preferredCountries!) {
        final country = widget.manager.getCountry(code);
        if (country != null && _allCountries.contains(country)) {
          _preferredCountries.add(country);
        }
      }
    }

    _filteredCountries = _allCountries;
  }

  void _filterCountries() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = widget.manager.searchCountries(query);
        if (widget.config.countryCodes != null &&
            widget.config.countryCodes!.isNotEmpty) {
          _filteredCountries = _filteredCountries
              .where((c) => widget.config.countryCodes!.contains(c.code))
              .toList();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.config.dialogTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.config.enableSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration:
                      widget.config.searchDecoration ??
                      InputDecoration(
                        hintText: widget.config.searchHintText,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  if (_preferredCountries.isNotEmpty &&
                      _searchController.text.isEmpty) ...[
                    ..._preferredCountries.map(_buildCountryTile),
                    const Divider(height: 1),
                  ],
                  ..._filteredCountries.map(_buildCountryTile),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountryTile(Country country) {
    final isSelected = country.code == widget.selectedCountry.code;

    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
      title: Text(country.name),
      trailing: Text(
        '+${country.dialCode}',
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () => Navigator.pop(context, country),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intlcv/validator/phone_validator.dart';
// import '../models/country.dart';
// import '../manager/country_manager.dart';
// import '../config/phone_field_config.dart';

// /// Phone number data model
// class PhoneNumber {
//   final Country country;
//   final String phoneNumber;

//   PhoneNumber({required this.country, required this.phoneNumber});

//   /// Get complete phone number with country code
//   String get completeNumber {
//     final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
//     return '+${country.dialCode}$digits';
//   }

//   /// Get phone number without country code
//   String get number => phoneNumber;

//   @override
//   String toString() => completeNumber;
// }

// /// Custom phone input field with country selection
// class CustomPhoneField extends StatefulWidget {
//   /// Configuration
//   final PhoneFieldConfig config;

//   /// Called when phone number changes
//   final ValueChanged<PhoneNumber>? onChanged;

//   /// Custom validator
//   final FormFieldValidator<String>? validator;

//   /// Controller for the text field
//   final TextEditingController? controller;

//   /// Focus node
//   final FocusNode? focusNode;

//   /// On country changed
//   final ValueChanged<Country>? onCountryChanged;

//   /// On submit
//   final ValueChanged<String>? onSubmit;

//   const CustomPhoneField({
//     Key? key,
//     this.config = const PhoneFieldConfig(),
//     this.onChanged,
//     this.validator,
//     this.controller,
//     this.focusNode,
//     this.onCountryChanged,
//     this.onSubmit,
//   }) : super(key: key);

//   @override
//   State<CustomPhoneField> createState() => _CustomPhoneFieldState();
// }

// class _CustomPhoneFieldState extends State<CustomPhoneField> {
//   late TextEditingController _controller;
//   late FocusNode _focusNode;
//   late Country _selectedCountry;
//   final CountryManager _manager = CountryManager();
//   String? _errorText;
//   bool _hasInteracted = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _initializeCountry();
//   }

//   void _initializeCountry() {
//     final initialCode =
//         widget.config.initialCountryCode ?? widget.config.defaultCountryCode;
//     _selectedCountry =
//         _manager.getCountry(initialCode) ??
//         _manager.getCountry(widget.config.defaultCountryCode) ??
//         _manager.countries.values.first;
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _onCountryChanged(Country country) {
//     setState(() {
//       _selectedCountry = country;
//       _controller.clear();
//       _hasInteracted = false;
//       _errorText = null;
//     });
//     widget.onCountryChanged?.call(country);
//     _notifyChange();
//   }

//   void _notifyChange() {
//     final phoneNumber = PhoneNumber(
//       country: _selectedCountry,
//       phoneNumber: _controller.text,
//     );
//     widget.onChanged?.call(phoneNumber);
//   }

//   String? _validateInput(String value) {
//     // Skip validation if not interacted
//     if (!_hasInteracted && !widget.config.showValidationOnEmpty) {
//       return null;
//     }

//     // Custom validator from widget
//     if (widget.validator != null) {
//       final customError = widget.validator!(value);
//       if (customError != null) return customError;
//     }

//     // Check if empty
//     if (value.isEmpty) {
//       return widget.config.emptyErrorMessage;
//     }

//     // Get digits only
//     final digits = value.replaceAll(RegExp(r'\D'), '');

//     // Check max length (custom or country-specific)
//     final maxLength = widget.config.maxPhoneLength > 0
//         ? widget.config.maxPhoneLength
//         : _selectedCountry.maxLength;

//     final minLength = widget.config.minPhoneLength > 0
//         ? widget.config.minPhoneLength
//         : _selectedCountry.minLength;

//     // Length validation
//     if (digits.length < minLength) {
//       return 'Phone number must be at least $minLength digits';
//     }

//     if (digits.length > maxLength) {
//       return 'Phone number cannot exceed $maxLength digits';
//     }

//     // Country-specific pattern validation if enabled
//     if (widget.config.enablePatternValidation &&
//         _selectedCountry.pattern != null) {
//       final pattern = RegExp(_selectedCountry.pattern!);
//       if (!pattern.hasMatch(digits)) {
//         return 'Invalid ${_selectedCountry.name} number format';
//       }
//     }

//     return null;
//   }

//   void _validateAndUpdate(String value) {
//     setState(() {
//       _hasInteracted = true;
//       _errorText = _validateInput(value);
//     });
//     _notifyChange();
//   }

//   Future<void> _showCountryPicker() async {
//     final selected = await showModalBottomSheet<Country>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => _CountryPickerDialog(
//         config: widget.config,
//         selectedCountry: _selectedCountry,
//         manager: _manager,
//       ),
//     );

//     if (selected != null) {
//       _onCountryChanged(selected);
//     }
//   }

//   int _getMaxLength() {
//     if (widget.config.maxPhoneLength > 0) {
//       return widget.config.maxPhoneLength;
//     }
//     return _selectedCountry.maxLength;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasError = _errorText != null && _errorText!.isNotEmpty;
//     final isValid =
//         _hasInteracted && _errorText == null && _controller.text.isNotEmpty;
//     final showSuccess =
//         widget.config.showSuccessIndicator && isValid && _hasInteracted;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextField(
//           controller: _controller,
//           focusNode: _focusNode,
//           autofocus: widget.config.autofocus,
//           obscureText: widget.config.obscureText,
//           keyboardType: widget.config.keyboardType,
//           textInputAction: widget.config.textInputAction,
//           cursorColor: widget.config.cursorColor,
//           maxLines: widget.config.maxLines,
//           minLines: widget.config.minLines,
//           maxLength: _getMaxLength(),
//           enableInteractiveSelection: widget.config.enableInteractiveSelection,
//           readOnly: widget.config.readOnly,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//             LengthLimitingTextInputFormatter(_getMaxLength()),
//           ],
//           decoration: (widget.config.decoration ?? const InputDecoration())
//               .copyWith(
//                 prefixIcon: _buildCountrySelector(hasError),
//                 counterText: '',
//                 errorText: hasError ? _errorText : null,
//                 errorMaxLines: 2,
//               ),
//           onChanged: (value) {
//             _validateAndUpdate(value);
//           },
//           onSubmitted: widget.onSubmit,
//           // validator: PhoneValidator().validate(, country),
//         ),

//         // Success message
//         if (showSuccess)
//           Padding(
//             padding: const EdgeInsets.only(top: 6, left: 12),
//             child: Row(
//               children: [
//                 Icon(
//                   widget.config.successIcon,
//                   size: 14,
//                   color: widget.config.successColor,
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     widget.config.successMessage ?? 'Valid phone number',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: widget.config.successColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildCountrySelector(bool hasError) {
//     return InkWell(
//       onTap: widget.config.readOnly ? null : _showCountryPicker,
//       child: Container(
//         padding: widget.config.selectorButtonPadding,
//         decoration: BoxDecoration(
//           border: hasError && widget.config.showErrorBorder
//               ? Border(
//                   right: BorderSide(color: widget.config.errorColor, width: 1),
//                 )
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.config.showFlag) ...[
//               Text(_selectedCountry.flag, style: const TextStyle(fontSize: 24)),
//               const SizedBox(width: 8),
//             ],
//             if (widget.config.showDialCode)
//               Text(
//                 '+${_selectedCountry.dialCode}',
//                 style:
//                     widget.config.dialCodeTextStyle ??
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             if (widget.config.showDropdownIcon) ...[
//               const SizedBox(width: 4),
//               Icon(widget.config.dropdownIcon, size: 20),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Country picker dialog
// class _CountryPickerDialog extends StatefulWidget {
//   final PhoneFieldConfig config;
//   final Country selectedCountry;
//   final CountryManager manager;

//   const _CountryPickerDialog({
//     Key? key,
//     required this.config,
//     required this.selectedCountry,
//     required this.manager,
//   }) : super(key: key);

//   @override
//   State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
// }

// class _CountryPickerDialogState extends State<_CountryPickerDialog> {
//   late List<Country> _allCountries;
//   late List<Country> _filteredCountries;
//   late List<Country> _preferredCountries;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCountries();
//     _searchController.addListener(_filterCountries);
//   }

//   void _initializeCountries() {
//     _allCountries = widget.manager.getSortedCountries();

//     if (widget.config.countryCodes != null &&
//         widget.config.countryCodes!.isNotEmpty) {
//       _allCountries = _allCountries
//           .where((c) => widget.config.countryCodes!.contains(c.code))
//           .toList();
//     }

//     _preferredCountries = [];
//     if (widget.config.preferredCountries != null) {
//       for (var code in widget.config.preferredCountries!) {
//         final country = widget.manager.getCountry(code);
//         if (country != null && _allCountries.contains(country)) {
//           _preferredCountries.add(country);
//         }
//       }
//     }

//     _filteredCountries = _allCountries;
//   }

//   void _filterCountries() {
//     final query = _searchController.text;
//     setState(() {
//       if (query.isEmpty) {
//         _filteredCountries = _allCountries;
//       } else {
//         _filteredCountries = widget.manager.searchCountries(query);
//         if (widget.config.countryCodes != null &&
//             widget.config.countryCodes!.isNotEmpty) {
//           _filteredCountries = _filteredCountries
//               .where((c) => widget.config.countryCodes!.contains(c.code))
//               .toList();
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.5,
//       maxChildSize: 0.9,
//       expand: false,
//       builder: (context, scrollController) {
//         return Column(
//           children: [
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 widget.config.dialogTitle,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (widget.config.enableSearch)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration:
//                       widget.config.searchDecoration ??
//                       InputDecoration(
//                         hintText: widget.config.searchHintText,
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                 ),
//               ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: ListView(
//                 controller: scrollController,
//                 children: [
//                   if (_preferredCountries.isNotEmpty &&
//                       _searchController.text.isEmpty) ...[
//                     ..._preferredCountries.map(_buildCountryTile),
//                     const Divider(height: 1),
//                   ],
//                   ..._filteredCountries.map(_buildCountryTile),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCountryTile(Country country) {
//     final isSelected = country.code == widget.selectedCountry.code;

//     return ListTile(
//       leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
//       title: Text(country.name),
//       trailing: Text(
//         '+${country.dialCode}',
//         style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
//       ),
//       selected: isSelected,
//       selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
//       onTap: () => Navigator.pop(context, country),
//     );
//   }
// }
// *****************************************************************************************
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../models/country.dart';
// import '../manager/country_manager.dart';
// import '../config/phone_field_config.dart';

// /// Phone number data model
// class PhoneNumber {
//   final Country country;
//   final String phoneNumber;

//   PhoneNumber({required this.country, required this.phoneNumber});

//   /// Get complete phone number with country code
//   String get completeNumber {
//     final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
//     return '+${country.dialCode}$digits';
//   }

//   /// Get phone number without country code
//   String get number => phoneNumber;

//   @override
//   String toString() => completeNumber;
// }

// /// Custom phone input field with country selection
// class CustomPhoneField extends StatefulWidget {
//   /// Configuration
//   final PhoneFieldConfig config;

//   /// Called when phone number changes
//   final ValueChanged<PhoneNumber>? onChanged;

//   /// Custom validator
//   final FormFieldValidator<String>? validator;

//   /// Controller for the text field
//   final TextEditingController? controller;

//   /// Focus node
//   final FocusNode? focusNode;

//   /// On country changed
//   final ValueChanged<Country>? onCountryChanged;

//   /// On submit
//   final ValueChanged<String>? onSubmit;

//   const CustomPhoneField({
//     Key? key,
//     this.config = const PhoneFieldConfig(),
//     this.onChanged,
//     this.validator,
//     this.controller,
//     this.focusNode,
//     this.onCountryChanged,
//     this.onSubmit,
//   }) : super(key: key);

//   @override
//   State<CustomPhoneField> createState() => _CustomPhoneFieldState();
// }

// class _CustomPhoneFieldState extends State<CustomPhoneField> {
//   late TextEditingController _controller;
//   late FocusNode _focusNode;
//   late Country _selectedCountry;
//   final CountryManager _manager = CountryManager();
//   String? _errorText;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _initializeCountry();
//   }

//   void _initializeCountry() {
//     final initialCode =
//         widget.config.initialCountryCode ?? widget.config.defaultCountryCode;
//     _selectedCountry =
//         _manager.getCountry(initialCode) ??
//         _manager.getCountry(widget.config.defaultCountryCode) ??
//         _manager.countries.values.first;
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _onCountryChanged(Country country) {
//     setState(() {
//       _selectedCountry = country;
//     });
//     widget.onCountryChanged?.call(country);
//     _notifyChange();
//   }

//   void _notifyChange() {
//     final phoneNumber = PhoneNumber(
//       country: _selectedCountry,
//       phoneNumber: _controller.text,
//     );
//     widget.onChanged?.call(phoneNumber);
//   }

//   Future<void> _showCountryPicker() async {
//     final selected = await showModalBottomSheet<Country>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => _CountryPickerDialog(
//         config: widget.config,
//         selectedCountry: _selectedCountry,
//         manager: _manager,
//       ),
//     );

//     if (selected != null) {
//       _onCountryChanged(selected);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: _controller,
//       focusNode: _focusNode,
//       autofocus: widget.config.autofocus,
//       obscureText: widget.config.obscureText,
//       keyboardType: widget.config.keyboardType,
//       textInputAction: widget.config.textInputAction,
//       cursorColor: widget.config.cursorColor,
//       maxLines: widget.config.maxLines,
//       minLines: widget.config.minLines,
//       maxLength: widget.config.maxLength,
//       enableInteractiveSelection: widget.config.enableInteractiveSelection,
//       readOnly: widget.config.readOnly,
//       // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//         if (widget.config.maxLength != null)
//           LengthLimitingTextInputFormatter(widget.config.maxLength),
//       ],
//       // decoration: (widget.config.decoration ?? const InputDecoration())
//       //     .copyWith(
//       //       prefixIcon: _buildCountrySelector(),
//       //       counterText: '', // Hide character counter
//       //     ),
//       decoration: (widget.config.decoration ?? const InputDecoration())
//           .copyWith(
//             prefixIcon: _buildCountrySelector(),
//             counterText: '',
//             errorText: _errorText,
//           ),
//       // onChanged: (value) => _notifyChange(),
//       onChanged: (value) {
//         _notifyChange();

//         if (widget.validator != null) {
//           setState(() {
//             _errorText = widget.validator!(value);
//           });
//         }
//       },
//       onSubmitted: widget.onSubmit,
//     );
//   }

//   Widget _buildCountrySelector() {
//     return InkWell(
//       onTap: widget.config.readOnly ? null : _showCountryPicker,
//       child: Padding(
//         padding: widget.config.selectorButtonPadding,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (widget.config.showFlag) ...[
//               Text(_selectedCountry.flag, style: const TextStyle(fontSize: 24)),
//               const SizedBox(width: 8),
//             ],
//             if (widget.config.showDialCode)
//               Text(
//                 '+${_selectedCountry.dialCode}',
//                 style:
//                     widget.config.dialCodeTextStyle ??
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             if (widget.config.showDropdownIcon) ...[
//               const SizedBox(width: 4),
//               Icon(widget.config.dropdownIcon, size: 20),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Country picker dialog
// class _CountryPickerDialog extends StatefulWidget {
//   final PhoneFieldConfig config;
//   final Country selectedCountry;
//   final CountryManager manager;

//   const _CountryPickerDialog({
//     Key? key,
//     required this.config,
//     required this.selectedCountry,
//     required this.manager,
//   }) : super(key: key);

//   @override
//   State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
// }

// class _CountryPickerDialogState extends State<_CountryPickerDialog> {
//   late List<Country> _allCountries;
//   late List<Country> _filteredCountries;
//   late List<Country> _preferredCountries;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCountries();
//     _searchController.addListener(_filterCountries);
//   }

//   void _initializeCountries() {
//     // Get all countries
//     _allCountries = widget.manager.getSortedCountries();

//     // Apply country filter if specified
//     if (widget.config.countryCodes != null &&
//         widget.config.countryCodes!.isNotEmpty) {
//       _allCountries = _allCountries
//           .where((c) => widget.config.countryCodes!.contains(c.code))
//           .toList();
//     }

//     // Get preferred countries
//     _preferredCountries = [];
//     if (widget.config.preferredCountries != null) {
//       for (var code in widget.config.preferredCountries!) {
//         final country = widget.manager.getCountry(code);
//         if (country != null && _allCountries.contains(country)) {
//           _preferredCountries.add(country);
//         }
//       }
//     }

//     _filteredCountries = _allCountries;
//   }

//   void _filterCountries() {
//     final query = _searchController.text;
//     setState(() {
//       if (query.isEmpty) {
//         _filteredCountries = _allCountries;
//       } else {
//         _filteredCountries = widget.manager.searchCountries(query);
//         // Apply filter if specified
//         if (widget.config.countryCodes != null &&
//             widget.config.countryCodes!.isNotEmpty) {
//           _filteredCountries = _filteredCountries
//               .where((c) => widget.config.countryCodes!.contains(c.code))
//               .toList();
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       minChildSize: 0.5,
//       maxChildSize: 0.9,
//       expand: false,
//       builder: (context, scrollController) {
//         return Column(
//           children: [
//             // Handle
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             // Title
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 widget.config.dialogTitle,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             // Search field
//             if (widget.config.enableSearch)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration:
//                       widget.config.searchDecoration ??
//                       InputDecoration(
//                         hintText: widget.config.searchHintText,
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                 ),
//               ),
//             const SizedBox(height: 8),
//             // Country list
//             Expanded(
//               child: ListView(
//                 controller: scrollController,
//                 children: [
//                   // Preferred countries
//                   if (_preferredCountries.isNotEmpty &&
//                       _searchController.text.isEmpty) ...[
//                     ..._preferredCountries.map(
//                       (country) => _buildCountryTile(country),
//                     ),
//                     const Divider(height: 1),
//                   ],
//                   // All countries
//                   ..._filteredCountries.map(
//                     (country) => _buildCountryTile(country),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildCountryTile(Country country) {
//     final isSelected = country.code == widget.selectedCountry.code;

//     return ListTile(
//       leading: Text(country.flag, style: const TextStyle(fontSize: 28)),
//       title: Text(country.name),
//       trailing: Text(
//         '+${country.dialCode}',
//         style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
//       ),
//       selected: isSelected,
//       selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
//       onTap: () => Navigator.pop(context, country),
//     );
//   }
// }
