import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _bookingsRef;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String? _serviceType;
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _vendorId = user.uid;
        _fetchServiceType(user.uid);
      } else {
        setState(() {
          isLoading = false;
        });
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
        _fetchBookings(uid);
      }
    } catch (error) {
      print('Error fetching service type: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBookings(String uid) async {
    if (_serviceType == null || _vendorId == null) return;

    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection(_serviceType!)
          .doc(_vendorId)
          .collection('bookings')
          .get();

      if (bookingsSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> tempBookings = [];

        for (var bookingDoc in bookingsSnapshot.docs) {
          Map<String, dynamic> booking = bookingDoc.data() as Map<String, dynamic>;
          final userId = booking['userId'];

          if (userId != null) {
            final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
            if (userSnapshot.exists) {
              final userData = userSnapshot.data() as Map<String, dynamic>;
              booking['customerName'] = '${userData['name']} ${userData['lastName']}';
              booking['phoneNumber'] = userData['phoneNumber'];
              booking['email'] = userData['email'];
            } else {
              booking['customerName'] = 'Unknown';
              booking['phoneNumber'] = 'Unknown';
              booking['email'] = 'Unknown';
            }
          } else {
            booking['customerName'] = 'Unknown';
            booking['phoneNumber'] = 'Unknown';
            booking['email'] = 'Unknown';
          }

          tempBookings.add(booking);
        }

        setState(() {
          bookings = tempBookings;
          isLoading = false;
        });
      } else {
        setState(() {
          bookings = [];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching bookings: $error');
      setState(() {
        bookings = [];
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'processing_payment':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(
                  child: Text(
                    'No bookings found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text(
                                  'Name: ${bookings[index]['customerName']}',
                                  style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text(
                                  'Email: ${bookings[index]['email']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text(
                                  'Phone: ${bookings[index]['phoneNumber']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.indigo),
                                SizedBox(width: 8),
                                Text(
                                  'Date: ${bookings[index]['date']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getStatusColor(
                                        bookings[index]['status']!),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    bookings[index]['status']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
