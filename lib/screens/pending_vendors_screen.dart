import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class PendingVendorsScreen extends StatefulWidget {
  @override
  _PendingVendorsScreenState createState() => _PendingVendorsScreenState();
}

class _PendingVendorsScreenState extends State<PendingVendorsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pendingVendors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingVendors();
  }

  Future<void> _fetchPendingVendors() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('vendors').where('status', isEqualTo: 'pending').get();
      List<Map<String, dynamic>> vendors = snapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id
      }).toList();

      setState(() {
        _pendingVendors = vendors;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching pending vendors: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchServiceData(String uid, String serviceType) async {
    DatabaseReference serviceRef = FirebaseDatabase.instance.reference().child(serviceType).child(uid);
    try {
      final snapshot = await serviceRef.once();
      final serviceData = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (serviceData != null) {
        return Map<String, dynamic>.from(serviceData);
      }
      return null;
    } catch (error) {
      print('Error fetching service data: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Vendors'),
        backgroundColor: Color(0xFF5956EB), // Light/primary color
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _pendingVendors.isEmpty
              ? Center(child: Text('No pending vendors found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _pendingVendors.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: _fetchServiceData(_pendingVendors[index]['id'], _pendingVendors[index]['serviceType']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(child: Text('Error fetching service data'));
                        }
                        final serviceData = snapshot.data as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${serviceData['name']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Location: ${serviceData['location']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Phone: ${serviceData['phone']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Description: ${serviceData['description']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Price: ${serviceData['price']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                if (serviceData['pictures'] != null)
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 200.0,
                                      enableInfiniteScroll: true,
                                      enlargeCenterPage: true,
                                    ),
                                    items: (serviceData['pictures'] as List<dynamic>).map((picture) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Image.file(
                                              File(picture),
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
