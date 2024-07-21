import 'package:cool/screens/vendor_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  User? _currentVendor;
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _currentVendor = _auth.currentUser;
    if (_currentVendor != null) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    final userDoc = await FirebaseFirestore.instance.collection('vendors').doc(_currentVendor!.uid).get();
    if (userDoc.exists) {
      setState(() {
        _name = userDoc.data()?['name'] ?? '';
        _email = _currentVendor!.email ?? '';
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VendorLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/profile.jpg'), // Update this path
            ),
            const SizedBox(height: 10),
            Text(
              _name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _email,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 30),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            ProfileMenuItem(
              icon: Icons.payment,
              text: 'Billing Details',
              onTap: () {
                // Implement billing details functionality
              },
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            ProfileMenuItem(
              icon: Icons.logout,
              text: 'Logout',
              textColor: Colors.red,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        text,
        style: TextStyle(color: textColor ?? Colors.black),
      ),
      onTap: onTap,
    );
  }
}
