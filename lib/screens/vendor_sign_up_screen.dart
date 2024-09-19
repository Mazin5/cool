import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'vendor_login_screen.dart'; // Import the login page

class VendorSignUpScreen extends StatefulWidget {
  @override
  _VendorSignUpScreenState createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _serviceType = 'venue'; // Default service type
  String _name = ''; // Can be venueName, singerName, etc.
  String _phone = ''; // Can be venuePhone, singerPhone, etc.
  String _location = '';
  String _description = '';
  String _price = ''; // New price field
  List<File> _servicePictures = []; // Placeholder for service pictures
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

        String uid = userCredential.user!.uid;

        // Upload images to Firebase Storage and get URLs
        List<String> imageUrls = await _uploadImagesToStorage(uid);

        // Prepare vendor data for Firestore
        Map<String, dynamic> vendorData = {
          'email': _email,
          'role': 'vendor',
          'serviceType': _serviceType,
          'status': 'pending', // Set status to pending
        };

        // Save vendor data in Firestore
        await FirebaseFirestore.instance.collection('vendors').doc(uid).set(vendorData);

        // Prepare service details for Firestore
        Map<String, dynamic> serviceData = {
          'pictures': imageUrls, // Save URLs to the images
          'name': _name,
          'phone': _phone,
          'location': _location,
          'description': _description,
          'price': _price,
          'status': 'pending', // Set status to pending
          'email': _email, // Add email field
        };

        // Save service details in Firestore
        await FirebaseFirestore.instance.collection(_serviceType).doc(uid).set(serviceData);

        // Sign the user out after successful registration
        await FirebaseAuth.instance.signOut();

        // Redirect to the login page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VendorLoginScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The email address is already in use by another account.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up failed: ${e.message}')));
        }
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase error: ${e.message}')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up failed: ${e.toString()}')));
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<List<String>> _uploadImagesToStorage(String uid) async {
    List<String> imageUrls = [];
    for (File image in _servicePictures) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      Reference storageRef = FirebaseStorage.instance.ref().child('service_pictures/$uid/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                DropdownButtonFormField<String>(
                  value: _serviceType,
                  items: ['venue', 'singer', 'meals', 'decoration'].map((service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _serviceType = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Service Type'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) => value!.isEmpty ? 'Please enter the phone number' : null,
                  onChanged: (value) {
                    setState(() {
                      _phone = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
                  onChanged: (value) {
                    setState(() {
                      _price = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: Text('Pick Images'),
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
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : Text('No images selected'),
                SizedBox(height: 20.0),
                _loading ? CircularProgressIndicator() : ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
