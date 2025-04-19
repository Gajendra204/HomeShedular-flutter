import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lio/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

class AddAppliancePage extends StatefulWidget {
  @override
  _AddAppliancePageState createState() => _AddAppliancePageState();
}

class _AddAppliancePageState extends State<AddAppliancePage> {
  final _formKey = GlobalKey<FormState>();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000/api'
        : 'http://localhost:3000/api';
  }

  // List of valid appliance types (must match backend)
  final List<String> applianceTypes = [
    'refrigerator',
    'washer',
    'dryer',
    'dishwasher',
    'microwave',
    'oven',
    'tv',
    'ac',
    'heater',
    'vacuum',
    'computer',
    'printer',
    'fan',
    'water_heater',
    'coffee_maker',
    'other'
  ];

  TextEditingController nameController = TextEditingController();
  TextEditingController maintenanceDurationController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();

  String selectedType = 'other'; // Default type
  DateTime? purchaseDate;
  DateTime? expiryDate;

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat("yyyy-MM-dd").format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (DateTime date) {
        if (isPurchaseDate) return true;
        return purchaseDate == null ? true : date.isAfter(purchaseDate!);
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isPurchaseDate) {
          purchaseDate = pickedDate;
          purchaseDateController.text = formatDate(pickedDate);
        } else {
          expiryDate = pickedDate;
          expiryDateController.text = formatDate(pickedDate);
        }
      });
    }
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedType,
      items: applianceTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Appliance Type',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      validator: (value) => value == null ? 'Select appliance type' : null,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> addAppliance() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      final token =
          await Provider.of<AuthProvider>(context, listen: false).getToken();
      final url = Uri.parse('$_baseUrl/add-appliance');
      final body = jsonEncode({
        "name": nameController.text,
        "type": selectedType, // Include the selected type
        "purchaseDate": formatDate(purchaseDate),
        "warrantyExpiryDate": formatDate(expiryDate),
        "maintenanceDuration":
            int.tryParse(maintenanceDurationController.text) ?? 0,
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      Navigator.pop(context);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appliance Added Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 401) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Appliance'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildSectionHeader('Appliance Information'),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildFormField(
                          label: 'Appliance Name',
                          icon: Icons.home_repair_service,
                          controller: nameController,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter appliance name' : null,
                        ),
                        SizedBox(height: 16),
                        _buildDropdownField(), // Type dropdown
                        SizedBox(height: 16),
                        _buildFormField(
                          label: 'Purchase Date',
                          icon: Icons.calendar_today,
                          controller: purchaseDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                        ),
                        SizedBox(height: 16),
                        _buildFormField(
                          label: 'Warranty Expiry Date',
                          icon: Icons.event_available,
                          controller: expiryDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _buildSectionHeader('Maintenance Details'),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: _buildFormField(
                      label: 'Maintenance Interval (months)',
                      icon: Icons.update,
                      controller: maintenanceDurationController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter maintenance duration' : null,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: addAppliance,
                    child: Text(
                      'ADD APPLIANCE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
