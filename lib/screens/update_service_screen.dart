import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UpdateServiceScreen extends StatefulWidget {
  final String serviceType;
  final String serviceId;
  final Map<String, dynamic> serviceData;

  UpdateServiceScreen({required this.serviceType, required this.serviceId, required this.serviceData});

  @override
  _UpdateServiceScreenState createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;
  late String _location;
  late String _description;
  late String _price;
  List<File> _servicePictures = [];
  List<String> _existingPictures = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.serviceData['name'];
    _phone = widget.serviceData['phone'];
    _location = widget.serviceData['location'];
    _description = widget.serviceData['description'];
    _price = widget.serviceData['price'];
    _existingPictures = List<String>.from(widget.serviceData['pictures'] ?? []);
  }

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        // Upload new images to Firebase Storage and get URLs
        List<String> newImageUrls = await _uploadImagesToStorage(widget.serviceId);

        // Prepare updated service data
        Map<String, dynamic> updatedData = {
          'name': _name,
          'phone': _phone,
          'location': _location,
          'description': _description,
          'price': _price,
          'pictures': _existingPictures + newImageUrls,
          'status': 'pending_update', // Change the status to 'pending_update'
        };

        // Update the service details in the specific service collection (venue, singer, etc.)
        CollectionReference serviceCollection = FirebaseFirestore.instance.collection(widget.serviceType);
        await serviceCollection.doc(widget.serviceId).update(updatedData);

        // Update the vendor's status in the vendors collection
        CollectionReference vendorsCollection = FirebaseFirestore.instance.collection('vendors');
        await vendorsCollection.doc(widget.serviceId).update({
          'status': 'pending_update', // Change the vendor's status to 'pending_update'
        });

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ${e.toString()}')));
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
      setState(() {
        _servicePictures.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Service'),
        backgroundColor: Color(0xFF4A90E2), // Updated to a brighter color for modern feel
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField('Name', _name, (value) {
                  setState(() {
                    _name = value;
                  });
                }, Icons.business),
                _buildTextField('Phone', _phone, (value) {
                  setState(() {
                    _phone = value;
                  });
                }, Icons.phone),
                _buildTextField('Location', _location, (value) {
                  setState(() {
                    _location = value;
                  });
                }, Icons.location_on),
                _buildTextField('Description', _description, (value) {
                  setState(() {
                    _description = value;
                  });
                }, Icons.description),
                _buildTextField('Price', _price, (value) {
                  setState(() {
                    _price = value;
                  });
                }, Icons.attach_money),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _pickImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Pick Images', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                _buildImageSection('Existing Images', _existingPictures, true),
                _buildImageSection('New Images', _servicePictures.map((file) => file.path).toList(), false),
                SizedBox(height: 20),
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton(
                          onPressed: _updateService,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A90E2),
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text('Update Service', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImageSection(String label, List<String> imagePaths, bool isExisting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePaths.isNotEmpty)
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        imagePaths.isNotEmpty
            ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children: imagePaths.map((path) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                          image: DecorationImage(
                            image: isExisting ? NetworkImage(path) : FileImage(File(path)) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExisting) {
                                _existingPictures.remove(path);
                              } else {
                                _servicePictures.removeWhere((file) => file.path == path);
                              }
                            });
                          },
                          child: Icon(Icons.remove_circle, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              )
            : Text('No $label selected', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
