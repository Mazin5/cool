import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hall.dart';

class MyServiceScreen extends StatefulWidget {
  @override
  _MyServiceScreenState createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends State<MyServiceScreen> {
  Hall? hall;
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchVendorHalls();
  }

  Future<void> _fetchVendorHalls() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference vendorRef = FirebaseDatabase.instance
          .reference()
          .child('vendors')
          .child(user.uid)
          .child('halls');

      vendorRef.limitToFirst(1).once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> hallMap =
              snapshot.value as Map<dynamic, dynamic>;
          hallMap.forEach((key, value) {
            hall = Hall.fromJson(Map<String, dynamic>.from(value), key);
          });
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((error) {
        print('Error fetching hall data: $error');
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Service'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hall == null
              ? Center(child: Text('No halls available'))
              : ListTile(
                  title: Text(hall!.hallName),
                  subtitle: Text(hall!.description),
                  leading: hall!.pictureUrls.isNotEmpty
                      ? Image.network(hall!.pictureUrls.first)
                      : Icon(Icons.image_not_supported),
                  trailing: Text('Hall Number: ${hall!.hallNumber}'),
                ),
    );
  }
}
