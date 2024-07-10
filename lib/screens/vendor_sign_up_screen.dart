import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class VendorSignUpScreen extends StatefulWidget {
  @override
  _VendorSignUpScreenState createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _hallDescriptionController =
      TextEditingController();
  final TextEditingController _hallNameController = TextEditingController();
  final TextEditingController _hallNumberController = TextEditingController();
  final TextEditingController _hallLocationController = TextEditingController();
  final TextEditingController _hallPictureUrlsController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        // Store email and role in Firestore under vendors collection
        await _firestore.collection('vendors').doc(uid).set({
          'email': _emailController.text.trim(),
          'role': 'vendor',
        });

        // Store vendor details and hall information in the real-time database
        await _database.child('vendors').child(uid).set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'halls': {
            'hall1': {
              'description': _hallDescriptionController.text.trim(),
              'hallName': _hallNameController.text.trim(),
              'hallNumber': _hallNumberController.text.trim(),
              'location': _hallLocationController.text.trim(),
              'pictureUrls': _hallPictureUrlsController.text.trim().split(','),
              'reservations': {},
            }
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              Divider(),
              Text('Hall Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _hallDescriptionController,
                decoration: InputDecoration(labelText: 'Hall Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter hall description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hallNameController,
                decoration: InputDecoration(labelText: 'Hall Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter hall name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hallNumberController,
                decoration: InputDecoration(labelText: 'Hall Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter hall number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hallLocationController,
                decoration: InputDecoration(labelText: 'Hall Location'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter hall location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hallPictureUrlsController,
                decoration: InputDecoration(
                    labelText: 'Hall Picture URLs (comma separated)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter hall picture URLs';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
