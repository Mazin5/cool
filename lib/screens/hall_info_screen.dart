import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/hall.dart';

class HallInfoScreen extends StatefulWidget {
  @override
  _HallInfoScreenState createState() => _HallInfoScreenState();
}

class _HallInfoScreenState extends State<HallInfoScreen> {
  List<Hall> halls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHalls();
  }

  _fetchHalls() async {
    try {
      DatabaseReference hallRef = FirebaseDatabase.instance.reference().child('Hall');
      DatabaseEvent event = await hallRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> hallMap = snapshot.value as Map<dynamic, dynamic>;
        print('Hall data: $hallMap'); // Debug print
        List<Hall> tempHalls = [];
        hallMap.forEach((key, value) {
          if (value is Map) {
            Hall hall = Hall.fromJson(Map<String, dynamic>.from(value), key);
            tempHalls.add(hall);
          }
        });

        if (mounted) {
          setState(() {
            halls = tempHalls;
            isLoading = false;
          });
        }
      } else {
        print('No data available in snapshot.');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching halls: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halls Information'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : halls.isEmpty
              ? Center(child: Text('No halls available'))
              : ListView.builder(
                  itemCount: halls.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        title: Text(
                          halls[index].title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(halls[index].description),
                            SizedBox(height: 10),
                            Text('Rating: ${halls[index].rating.toString()}'),
                          ],
                        ),
                        leading: Image.network(halls[index].image, fit: BoxFit.cover, width: 100),
                      ),
                    );
                  },
                ),
    );
  }
}
