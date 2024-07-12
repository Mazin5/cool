import 'dart:ffi';

import 'package:cool/screens/UpdateProfileScreen.dart';
import 'package:cool/screens/my_service_screen.dart';
import 'package:cool/screens/vendor_login_screen.dart';
import 'package:flutter/material.dart';
import '../screens/UpdateProfileScreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () { 
              MyServiceScreen();
            },
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
              'John Doe',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'johndoe@example.com',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
                );
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 30),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            ProfileMenuItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: () {
                // Implement settings functionality
              },
            ),
            ProfileMenuItem(
              icon: Icons.payment,
              text: 'Billing Details',
              onTap: () {
                // Implement billing details functionality
              },
            ),
            ProfileMenuItem(
              icon: Icons.person,
              text: 'User Management',
              onTap: () {
                // Implement user management functionality
              },
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[400]),
            const SizedBox(height: 10),
            ProfileMenuItem(
              icon: Icons.info,
              text: 'Information',
              onTap: () {
                // Implement information functionality
              },
            ),
            ProfileMenuItem(
              icon: Icons.logout,
              text: 'Logout',
              textColor: Colors.red,
              onTap: () {
                VendorLoginScreen();
              },
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
