import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:lio/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class AddAppliancePage extends StatefulWidget {
  @override
  _AddAppliancePageState createState() => _AddAppliancePageState();
}

class _AddAppliancePageState extends State<AddAppliancePage> {
  final _formKey = GlobalKey<FormState>();

  // Get the base URL for API calls
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.13:3000/api';
    } else if (Platform.isIOS) {
      return 'http://192.168.1.13:3000/api';
    }
    return 'http://192.168.1.13:3000/api';
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController maintenanceDurationController = TextEditingController();
  TextEditingController purchaseDateController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();

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
            ),
          ),
          child: child!,
        );
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

  Future<void> addAppliance() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
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

      // Close loading dialog
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
      // Close loading dialog
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
                // Appliance Info Section
                _buildSectionHeader('Appliance Information'),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Appliance Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home_repair_service),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter appliance name' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: purchaseDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Purchase Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            hintText: 'Select purchase date',
                          ),
                          onTap: () => _selectDate(context, true),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: expiryDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Warranty Expiry Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event_available),
                            hintText: 'Select warranty expiry date',
                          ),
                          onTap: () => _selectDate(context, false),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Maintenance Section
                _buildSectionHeader('Maintenance Details'),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: maintenanceDurationController,
                      decoration: InputDecoration(
                        labelText: 'Maintenance Interval',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.update),
                        suffixText: 'months',
                        helperText:
                            'How often should this appliance be maintained?',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter maintenance duration' : null,
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
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
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
}
