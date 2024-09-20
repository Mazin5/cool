import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'vendor_login_screen.dart';

class VendorSignUpScreen extends StatefulWidget {
  @override
  _VendorSignUpScreenState createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _serviceType = 'venue';
  String _name = '';
  String _phone = '';
  String _location = '';
  String _description = '';
  String _price = '';
  List<File> _servicePictures = [];
  bool _loading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      // ... (sign up logic here)

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      if (_servicePictures.length + pickedFiles.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You can only select up to 6 pictures.')));
      } else {
        setState(() {
          _servicePictures.addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Sign-Up'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField('Email', Icons.email, false, (value) {
                setState(() {
                  _email = value;
                });
              }),
              SizedBox(height: 16), // Add space between fields
              _buildTextField('Password', Icons.lock, true, (value) {
                setState(() {
                  _password = value;
                });
              }),
              SizedBox(height: 16),
              _buildDropdownField('Service Type', ['venue', 'singer', 'meals', 'decoration'], _serviceType, (value) {
                setState(() {
                  _serviceType = value!;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Name', Icons.business, false, (value) {
                setState(() {
                  _name = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Phone', Icons.phone, false, (value) {
                setState(() {
                  _phone = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Location', Icons.location_on, false, (value) {
                setState(() {
                  _location = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Description', Icons.description, false, (value) {
                setState(() {
                  _description = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Price', Icons.attach_money, false, (value) {
                setState(() {
                  _price = value;
                });
              }),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(color: Colors.blueAccent),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 4.0,
                  ),
                  child: Text('Pick Images', style: TextStyle(color: Colors.blueAccent)),
                ),
              ),
              SizedBox(height: 20.0),
              _servicePictures.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      children: _servicePictures.map((file) {
                        return Stack(
                          children: [
                            Image.file(file, width: 100, height: 100),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _servicePictures.remove(file);
                                  });
                                },
                                child: Icon(Icons.remove_circle, color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  : Text('No images selected'),
              SizedBox(height: 24),
              Center(
                child: _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          elevation: 8.0,
                        ),
                        child: Text('Sign Up'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool obscureText, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: obscureText,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((service) {
        return DropdownMenuItem<String>(
          value: service,
          child: Text(service),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
