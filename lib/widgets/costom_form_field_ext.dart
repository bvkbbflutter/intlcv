// import 'package:flutter/material.dart';

// import '../phone_field.dart';

// /// A wrapper that makes CustomPhoneField work with Form
// class CustomFormPhoneField extends FormField<PhoneNumber> {
//   CustomFormPhoneField({
//     Key? key,
//     required PhoneFieldConfig config,
//     FormFieldValidator<PhoneNumber>? validator,
//     ValueChanged<PhoneNumber>? onChanged,
//     void Function(Country)? onCountryChanged,
//     TextEditingController? controller,
//     FocusNode? focusNode,
//     void Function(String)? onSubmit,
//     AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
//   }) : super(
//          key: key,
//          validator: validator,
//          autovalidateMode: autovalidateMode,
//          builder: (FormFieldState<PhoneNumber> state) {
//            return Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                CustomPhoneField(
//                  config: config,
//                  controller: controller,
//                  focusNode: focusNode,
//                  onChanged: (phoneNumber) {
//                    state.didChange(phoneNumber);
//                    onChanged?.call(phoneNumber);
//                  },
//                  onCountryChanged: onCountryChanged,
//                  onSubmit: onSubmit,
//                  validator: (value) {
//                    // Use the form field validator
//                    return state.errorText;
//                  },
//                ),
//                if (state.hasError)
//                  Padding(
//                    padding: const EdgeInsets.only(left: 12, top: 6),
//                    child: Text(
//                      state.errorText!,
//                      style: const TextStyle(fontSize: 12, color: Colors.red),
//                    ),
//                  ),
//              ],
//            );
//          },
//        );

//   @override
//   FormFieldState<PhoneNumber> createState() => _CustomFormPhoneFieldState();
// }

// class _CustomFormPhoneFieldState extends FormFieldState<PhoneNumber> {
//   @override
//   void didChange(PhoneNumber? value) {
//     super.didChange(value);
//     // Trigger validation
//     setState(() {});
//   }
// }
