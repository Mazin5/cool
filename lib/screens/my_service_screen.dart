import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_service_screen.dart';
import 'reserve_date_screen.dart';

class MyServiceScreen extends StatefulWidget {
  @override
  _MyServiceScreenState createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends State<MyServiceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _serviceRef;
  Map<String, dynamic>? _serviceData;
  String? _serviceType;
  String? _serviceId;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _serviceId = user.uid;
        _fetchServiceType(user.uid);
      }
    });
  }

  Future<void> _fetchServiceType(String uid) async {
    try {
      DocumentSnapshot vendorDoc = await FirebaseFirestore.instance.collection('vendors').doc(uid).get();
      if (vendorDoc.exists) {
        setState(() {
          _serviceType = vendorDoc['serviceType'];
        });
        _fetchServiceData(uid);
      }
    } catch (error) {
      print('Error fetching service type: $error');
      setState(() {
        _serviceData = {};
      });
    }
  }

  Future<void> _fetchServiceData(String uid) async {
    if (_serviceType == null) return;
    _serviceRef = FirebaseDatabase.instance.reference().child(_serviceType!).child(uid);
    try {
      final snapshot = await _serviceRef!.once();
      final serviceMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (serviceMap != null) {
        setState(() {
          _serviceData = Map<String, dynamic>.from(serviceMap);
        });
      } else {
        setState(() {
          _serviceData = {};
        });
      }
    } catch (error) {
      print('Error fetching service data: $error');
      setState(() {
        _serviceData = {};
      });
    }
  }

  Future<void> _navigateToUpdateService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateServiceScreen(
          serviceType: _serviceType!,
          serviceId: _serviceId!,
          serviceData: _serviceData!,
        ),
      ),
    );

    if (result == true) {
      _fetchServiceData(_serviceId!); // Refresh the service data after returning
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Service'),
        backgroundColor: Color.fromARGB(255, 106, 106, 255), // Light/primary color
      ),
      body: _serviceData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name: ${_serviceData!['name']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0), // Light/primary color
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_serviceData!['pictures'] != null)
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200.0,
                              enableInfiniteScroll: true, // Enable infinite scrolling
                              enlargeCenterPage: true,
                            ),
                            items: (_serviceData!['pictures'] as List<dynamic>).map((picture) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Image.network(
                                      picture,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 10),
                        Text(
                          'Location: ${_serviceData!['location']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Phone: ${_serviceData!['phone']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Description: ${_serviceData!['description']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Price: ${_serviceData!['price']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _navigateToUpdateService,
                            child: Text('Want to update ?'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 0, 0, 0), // Light/primary color
                              backgroundColor: Color.fromARGB(255, 106, 106, 255), // Light/primary color
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReserveDateScreen(
                                    serviceType: _serviceType!,
                                    serviceId: _serviceId!,
                                  ),
                                ),
                              );
                            },
                            child: Text('Reserve Date'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 0, 0, 0), // Light/primary color
                              backgroundColor: Color.fromARGB(255, 106, 106, 255), // Light/primary color
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
