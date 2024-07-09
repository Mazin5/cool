import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hall.dart';

class MyServiceScreen extends StatefulWidget {
  @override
  _MyServiceScreenState createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends State<MyServiceScreen> {
  Hall? hall;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFirstHall();
  }

  _fetchFirstHall() async {
    DatabaseReference hallRef = FirebaseDatabase.instance.reference().child('Hall');
    
    hallRef.limitToFirst(1).once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> hallMap = snapshot.value as Map<dynamic, dynamic>;
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
    });
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
                  title: Text(hall!.title),
                  subtitle: Text(hall!.description),
                  leading: Image.network(hall!.image),
                  trailing: Text(hall!.rating.toString()),
                ),
    );
  }
}
