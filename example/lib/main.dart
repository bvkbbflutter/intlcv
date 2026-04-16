import 'package:flutter/material.dart';
import 'package:intlcv/phone_field.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with Somalia override (9 digits fix)
  await PhoneField.initialize(
    // Optional: Add API source
    // remoteSource: ApiCountryDataSource(
    //   apiUrl: 'https://api.example.com/countries',
    // ),
    overrides: [
      // Fix Somalia to accept 9 digits
      const Country(
        code: 'SO',
        dialCode: '252',
        displayCC: '252',
        flag: '🇸🇴',
        fullCountryCode: '252',
        minLength: 9,
        maxLength: 9,
        name: 'Somalia',
      ),
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Field Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PhoneFieldDemo(),
    );
  }
}

class PhoneFieldDemo extends StatefulWidget {
  const PhoneFieldDemo({Key? key}) : super(key: key);

  @override
  State<PhoneFieldDemo> createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<PhoneFieldDemo> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumber? _phoneNumber;
  String? _validationError;

  final _phoneController = TextEditingController(text: "9090909090");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Field Demo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo 1: Basic usage
            // _buildSection(
            //   'Basic Phone Input',
            //   CustomPhoneField(
            //     config: const PhoneFieldConfig(
            //       initialCountryCode: 'US',
            //       decoration: InputDecoration(
            //         labelText: 'Phone Number',
            //         border: OutlineInputBorder(),
            //         hintText: 'Enter phone number',
            //       ),
            //     ),
            //     onChanged: (phoneNumber) {
            //       setState(() {
            //         _phoneNumber = phoneNumber;
            //         _validationError = PhoneField.manager.validatePhoneNumber(
            //           phoneNumber.number,
            //           phoneNumber.country,
            //         );
            //       });
            //     },
            //   ),
            // ),

            // // Show current value
            // if (_phoneNumber != null) ...[
            //   const SizedBox(height: 8),
            //   Card(
            //     color: _validationError == null
            //         ? Colors.green.shade50
            //         : Colors.red.shade50,
            //     child: Padding(
            //       padding: const EdgeInsets.all(12),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Complete Number: ${_phoneNumber!.completeNumber}',
            //             style: const TextStyle(fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 4),
            //           Text('Country: ${_phoneNumber!.country.name}'),
            //           Text('Dial Code: +${_phoneNumber!.country.dialCode}'),
            //           Text('Number: ${_phoneNumber!.number}'),
            //           const SizedBox(height: 8),
            //           Text(
            //             _validationError ?? '✓ Valid',
            //             style: TextStyle(
            //               color: _validationError == null
            //                   ? Colors.green
            //                   : Colors.red,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ],

            // const SizedBox(height: 24),

            // Demo 2: Somalia example
            // _buildSection(
            //   'Somalia (9 digits)',
            //   CustomPhoneField(
            //     config: const PhoneFieldConfig(
            //       initialCountryCode: 'SO',
            //       decoration: InputDecoration(
            //         labelText: 'Somalia Phone',
            //         border: OutlineInputBorder(),
            //         helperText: 'Fixed to accept 9 digits',
            //       ),
            //     ),
            //     onChanged: (phoneNumber) {
            //       print('Somalia: ${phoneNumber.completeNumber}');
            //     },
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Demo 3: Preferred countries
            // _buildSection(
            //   'Preferred Countries',
            //   CustomPhoneField(
            //     config: const PhoneFieldConfig(
            //       preferredCountries: ['US', 'IN', 'GB', 'SO'],
            //       decoration: InputDecoration(
            //         labelText: 'Phone with Preferred',
            //         border: OutlineInputBorder(),
            //         helperText: 'US, IN, GB, SO shown first',
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Demo 4: Country filter
            // _buildSection(
            //   'Filtered Countries',
            //   CustomPhoneField(
            //     config: const PhoneFieldConfig(
            //       countryCodes: ['US', 'CA', 'MX', 'GB', 'IN'],
            //       decoration: InputDecoration(
            //         labelText: 'Limited Countries',
            //         border: OutlineInputBorder(),
            //         helperText: 'Only US, CA, MX, GB, IN',
            //       ),
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Demo 5: Custom styling
            // _buildSection(
            //   'Custom Styling',
            //   CustomPhoneField(
            //     config: PhoneFieldConfig(
            //       initialCountryCode: 'IN',
            //       decoration: InputDecoration(
            //         labelText: 'Styled Phone Input',
            //         border: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         filled: true,
            //         fillColor: Colors.blue.shade50,
            //         prefixIconColor: Colors.blue,
            //       ),
            //       dialCodeTextStyle: const TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.blue,
            //       ),
            //       cursorColor: Colors.blue,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 24),

            // Runtime override demonstration
            // _buildSection(
            //   'Runtime Operations',
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       ElevatedButton.icon(
            //         onPressed: () {
            //           // Override a country at runtime
            //           PhoneField.manager.upsertCountry(
            //             const Country(
            //               code: 'US',
            //               dialCode: '1',
            //               displayCC: '1',
            //               flag: '🇺🇸',
            //               fullCountryCode: '1',
            //               minLength: 10,
            //               maxLength: 11, // Changed from 10
            //               name: 'United States (Modified)',
            //             ),
            //           );
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(
            //               content: Text(
            //                 'US country updated to allow 10-11 digits',
            //               ),
            //             ),
            //           );
            //         },
            //         icon: const Icon(Icons.edit),
            //         label: const Text('Override US Country'),
            //       ),
            //       const SizedBox(height: 8),
            //       ElevatedButton.icon(
            //         onPressed: () async {
            //           await PhoneField.manager.reset();
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(
            //               content: Text('Reset to default countries'),
            //             ),
            //           );
            //         },
            //         icon: const Icon(Icons.refresh),
            //         label: const Text('Reset to Defaults'),
            //       ),
            //       const SizedBox(height: 8),
            //       ElevatedButton.icon(
            //         onPressed: () {
            //           final countries = PhoneField.manager.countries;
            //           showDialog(
            //             context: context,
            //             builder: (context) => AlertDialog(
            //               title: const Text('Country Stats'),
            //               content: Text(
            //                 'Total countries: ${countries.length}\n'
            //                 'Countries with 9 digits: ${countries.values.where((c) => c.minLength == 9 && c.maxLength == 9).length}\n'
            //                 'Somalia config: min=${countries['SO']?.minLength}, max=${countries['SO']?.maxLength}',
            //               ),
            //               actions: [
            //                 TextButton(
            //                   onPressed: () => Navigator.pop(context),
            //                   child: const Text('Close'),
            //                 ),
            //               ],
            //             ),
            //           );
            //         },
            //         icon: const Icon(Icons.info),
            //         label: const Text('Show Country Stats'),
            //       ),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Form validation example
            _buildSection(
              'Form Validation',
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomPhoneField(
                      controller: _phoneController,
                      initialDialCode: '+91', // UK
                      initialCountryCode:
                          'US', // This will be ignored because dial code is provided
                      config: const PhoneFieldConfig(
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                      onChanged: (phoneNumber) {
                        // Auto-validate as user types
                        // setState(() {
                        _phoneController.text = phoneNumber.number;
                        _phoneNumber = phoneNumber;
                        //   _validationError = PhoneField.manager
                        //       .validatePhoneNumber(
                        //         phoneNumber.number,
                        //         phoneNumber.country,
                        //       );
                        // });
                        _formKey.currentState?.validate();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final country = _phoneNumber?.country;
                          final number = _phoneNumber?.number;

                          if (country == null || number == null) return;

                          final errorMessage = PhoneField.manager
                              .validatePhoneNumber(number, country);

                          if (errorMessage != null) {
                            /// ❌ INVALID
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Row(
                                  children: [
                                    Text(
                                      country.flag,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "$errorMessage\n(${country.name})",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            return;
                          }

                          /// ✅ VALID
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Row(
                                children: [
                                  Text(
                                    country.flag,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${country.name} number is valid ✔",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      // onPressed: () {
                      //   if (_formKey.currentState!.validate()) {
                      //     final phoneNumber = _phoneController.text.trim();
                      //     if (_phoneNumber?.number.length !=
                      //         _phoneNumber?.country.maxLength) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(
                      //           content: Text('Invalid Phone Number'),
                      //           backgroundColor: Colors.red,
                      //         ),
                      //       );
                      //       return;
                      //     }
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(
                      //         content: Text('Phone number is valid!'),
                      //         backgroundColor: Colors.green,
                      //       ),
                      //     );
                      //   }
                      // },
                      // onPressed: () {
                      //   if (_formKey.currentState!.validate()) {
                      //     final phoneNumber = _phoneController.text.trim();
                      //     final country = _phoneNumber?.country;

                      //     if (country == null || _phoneNumber == null) return;

                      //     final length = _phoneNumber!.number.length;

                      //     if (length != country.maxLength) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           backgroundColor: Colors.red,
                      //           content: Row(
                      //             children: [
                      //               Text(
                      //                 country.flag,
                      //                 style: const TextStyle(fontSize: 18),
                      //               ),
                      //               const SizedBox(width: 8),
                      //               Expanded(
                      //                 child: Text(
                      //                   "Invalid ${country.name} number ",
                      //                   // "Expected ${country.maxLength} digits, got $length",
                      //                 ),
                      //               ),
                      //               // Expanded(
                      //               //   child: Text(
                      //               //     "Invalid ${country.name} number "
                      //               //     "Expected ${country.maxLength} digits, got $length",
                      //               //   ),
                      //               // ),
                      //             ],
                      //           ),
                      //         ),
                      //       );
                      //       return;
                      //     }

                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //         backgroundColor: Colors.green,
                      //         content: Row(
                      //           children: [
                      //             Text(
                      //               country.flag,
                      //               style: const TextStyle(fontSize: 18),
                      //             ),
                      //             const SizedBox(width: 8),
                      //             Expanded(
                      //               child: Text(
                      //                 "${country.name} number is valid ✔",
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   }
                      // },
                      child: const Text('Validate Form'),
                    ),
                  ],
                ),
              ),
            ),
            //   const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
