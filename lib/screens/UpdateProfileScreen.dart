import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();
  late User _currentUser;
  String _name = '';
  String _phone = '';
  String _location = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final snapshot = await _database.child('vendors/${_currentUser.uid}/profile').once();
    if (snapshot.snapshot.value != null) {
      final profile = Map<String, dynamic>.from(snapshot.snapshot.value as Map<dynamic, dynamic>);
      setState(() {
        _name = profile['name'];
        _phone = profile['phone'];
        _location = profile['location'];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        await _database.child('vendors/${_currentUser.uid}/profile').update({
          'name': _name,
          'phone': _phone,
          'location': _location,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: ${e.toString()}')));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildTextFormField(String label, String initialValue, ValueChanged<String> onChanged, String validationMessage) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? validationMessage : null,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Color(0xFF5956EB),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildTextFormField('Name', _name, (value) => setState(() => _name = value), 'Please enter your name'),
                    _buildTextFormField('Phone', _phone, (value) => setState(() => _phone = value), 'Please enter your phone number'),
                    _buildTextFormField('Location', _location, (value) => setState(() => _location = value), 'Please enter your location'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
