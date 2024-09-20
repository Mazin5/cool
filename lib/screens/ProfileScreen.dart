import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'vendor_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentVendor;
  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentVendor = _auth.currentUser;
    if (_currentVendor != null) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('vendors').doc(_currentVendor!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc.data()?['name'] ?? '';
          _email = _currentVendor!.email ?? '';
          _profileImageUrl = userDoc.data()?['profileImageUrl'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  Future<void> _pickAndUploadProfilePicture() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        String fileName = 'profile_${_currentVendor!.uid}.jpg';
        UploadTask uploadTask = FirebaseStorage.instance.ref('profile_pictures/$fileName').putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        // Update Firestore with new profile image URL
        await FirebaseFirestore.instance.collection('vendors').doc(_currentVendor!.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadProfilePicture,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl.isNotEmpty
                          ? NetworkImage(_profileImageUrl)
                          : AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                      child: Icon(Icons.camera_alt, size: 30, color: Colors.white.withOpacity(0.7)),
                    ),
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
                      // Navigate to Billing Details Screen (Placeholder)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlaceholderScreen(title: 'Billing Details')),
                      );
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

// Placeholder screen for Billing Details
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Placeholder for $title'),
      ),
    );
  }
}
