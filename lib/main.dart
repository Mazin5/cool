import 'package:cool/screens/vendor_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vendor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VendorLoginScreen(), // Set the initial screen to login
    );
  }
}
