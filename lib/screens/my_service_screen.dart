import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'update_service_screen.dart';
import 'reserve_date_screen.dart';

class MyServiceScreen extends StatefulWidget {
  @override
  _MyServiceScreenState createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends State<MyServiceScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference? _serviceCollection;
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
    _serviceCollection = FirebaseFirestore.instance.collection(_serviceType!);
    try {
      DocumentSnapshot serviceDoc = await _serviceCollection!.doc(uid).get();
      if (serviceDoc.exists) {
        setState(() {
          _serviceData = serviceDoc.data() as Map<String, dynamic>?;
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
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: _serviceData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _serviceData!['name'] != null
                              ? 'Name: ${_serviceData!['name']}'
                              : 'Service Name',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 15),
                        if (_serviceData!['pictures'] != null)
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 250.0,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.8,
                            ),
                            items: (_serviceData!['pictures'] as List<dynamic>)
                                .map((picture) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: NetworkImage(picture),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 20),
                        _buildInfoRow(Icons.location_on, 'Location', _serviceData!['location']),
                        _buildInfoRow(Icons.phone, 'Phone', _serviceData!['phone']),
                        _buildInfoRow(Icons.description, 'Description', _serviceData!['description']),
                        _buildInfoRow(Icons.attach_money, 'Price', _serviceData!['price']),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _navigateToUpdateService,
                            child: Text('Update Service'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
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
                            child: Text('Reserve Local Date'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.lightBlueAccent, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Text(
            value != null ? value.toString() : 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
