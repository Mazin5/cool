import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart'; // Import the home screen for vendors
import 'vendor_sign_up_screen.dart'; // Import the sign-up screen

class VendorLoginScreen extends StatefulWidget {
  @override
  _VendorLoginScreenState createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        DocumentSnapshot vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(userCredential.user!.uid).get();
        if (vendorDoc.exists) {
          // Navigate to the vendor home screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          // If the user is not a vendor, sign them out
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No vendor account found for this email.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String inlineSvg = '''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-2.4-.35-4.5-1.5-6.03-3.22l1.46-1.46a7.93 7.93 0 0010.27 0l1.46 1.46c-1.53 1.72-3.63 2.87-6.03 3.22V13h-2v6.93zM12 4c2.2 0 4.2.89 5.66 2.34L16.17 8.83a6.001 6.001 0 00-8.34 0L6.34 6.34A7.938 7.938 0 0112 4zm0 10h2v-2h-2v2zm0-4h2V7h-2v3z"/>
    </svg>
    ''';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.string(
                      inlineSvg,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "WELCOME BACK",
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "LOGIN",
                    style: GoogleFonts.roboto(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 32),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  _loading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: Text('Login'),
                        ),
                  SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => VendorSignUpScreen()));
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: GoogleFonts.roboto(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
