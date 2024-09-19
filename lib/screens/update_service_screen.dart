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
        };

        // Update service details in Firestore
        CollectionReference serviceCollection = FirebaseFirestore.instance.collection(widget.serviceType);
        await serviceCollection.doc(widget.serviceId).update(updatedData);

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
        backgroundColor: Color(0xFF5956EB),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _phone,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) => value!.isEmpty ? 'Please enter the phone number' : null,
                  onChanged: (value) {
                    setState(() {
                      _phone = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _location,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _price,
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
                _existingPictures.isNotEmpty
                    ? Wrap(
                        spacing: 10,
                        children: _existingPictures.map((url) {
                          return Stack(
                            children: [
                              Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _existingPictures.remove(url);
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
                    : Text('No existing images'),
                _servicePictures.isNotEmpty
                    ? Wrap(
                        spacing: 10,
                        children: _servicePictures.map((file) {
                          return Stack(
                            children: [
                              Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
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
                    : Text('No new images selected'),
                SizedBox(height: 20.0),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _updateService,
                        child: Text('Update Service'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
