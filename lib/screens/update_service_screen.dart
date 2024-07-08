import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hall.dart'; // Import the existing Hall model

class UpdateServiceScreen extends StatefulWidget {
  final Hall hall;

  const UpdateServiceScreen({super.key, required this.hall});

  @override
  _UpdateServiceScreenState createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;

  final DatabaseReference servicesRef =
      FirebaseDatabase.instance.ref().child('services');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hall.name);
    _descriptionController =
        TextEditingController(text: widget.hall.description);
    _locationController = TextEditingController(text: widget.hall.location);
    _phoneController = TextEditingController(text: widget.hall.phoneNumber);
    _capacityController = TextEditingController(text: widget.hall.capacity);
    _priceController = TextEditingController(text: widget.hall.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update My Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Hall Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _updateService,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateService() {
    final updatedHall = Hall(
      key: widget.hall.key,
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      phoneNumber: _phoneController.text,
      imageUrl: widget.hall.imageUrl, // Assuming imageUrl remains unchanged
      capacity: _capacityController.text,
      price: _priceController.text,
    );

    servicesRef.child(widget.hall.key).update(updatedHall.toMap()).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update details: $error')),
      );
    });
  }
}
