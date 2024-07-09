import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vendor_login_screen.dart'; // Import the login screen

class VendorSignUpScreen extends StatefulWidget {
  @override
  _VendorSignUpScreenState createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _companyName = '';
  bool _loading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        await FirebaseFirestore.instance.collection('vendors').doc(userCredential.user!.uid).set({
          'email': _email,
          'role': 'vendor',
          'companyName': _companyName,
        });

        // Sign the user out after successful registration
        await FirebaseAuth.instance.signOut();

        // Redirect to the login page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VendorLoginScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Sign-Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Company Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a company name' : null,
                onChanged: (value) {
                  setState(() {
                    _companyName = value;
                  });
                },
              ),
              SizedBox(height: 20.0),
              _loading ? CircularProgressIndicator() : ElevatedButton(
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
