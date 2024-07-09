import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hall.dart';

class AddServiceScreen extends StatefulWidget {
  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late String image;
  late double rating;

  _addHall() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      DatabaseReference hallRef = FirebaseDatabase.instance.reference().child('Hall').push();
      Hall newHall = Hall(
        title: title,
        description: description,
        image: image,
        rating: rating,
      );
      hallRef.set(newHall.toJson()).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Service'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Image URL'),
                onSaved: (value) => image = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                onSaved: (value) => rating = double.parse(value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addHall,
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
