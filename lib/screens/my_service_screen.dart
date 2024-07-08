import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'update_service_screen.dart'; // Import the update screen
import 'add_service_screen.dart'; // Import the add service screen
import '../models/hall.dart';

class MyServiceScreen extends StatelessWidget {
  final DatabaseReference servicesRef =
      FirebaseDatabase.instance.ref().child('services');

  MyServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service'),
      ),
      body: StreamBuilder(
        stream: servicesRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No services available.'));
          }

          List<Hall> halls = [];
          final data = snapshot.data!.snapshot.value;
          if (data is Map) {
            data.forEach((key, value) {
              halls.add(Hall.fromMap(Map<String, dynamic>.from(value), key));
            });
          }

          return ListView.builder(
            itemCount: halls.length,
            itemBuilder: (context, index) {
              var hall = halls[index];
              return HallCard(hall: hall);
            },
          );
        },
      ),
    );
  }
}

class HallCard extends StatelessWidget {
  final Hall hall;

  const HallCard({super.key, required this.hall});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hall.imageUrl != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(hall.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              hall.name,
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              hall.description,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Location: ${hall.location}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Phone: ${hall.phoneNumber}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Capacity: ${hall.capacity}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Price: \$${hall.price}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateServiceScreen(hall: hall)),
                );
              },
              child: const Text('Want to update?'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddServiceScreen()),
                );
              },
              child: const Text('Add New Service'),
            ),
          ],
        ),
      ),
    );
  }
}
