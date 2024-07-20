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

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
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
    if (_serviceType == null) return;
    _bookingsRef = FirebaseDatabase.instance.reference().child(_serviceType!).child(uid).child('bookings');
    try {
      final snapshot = await _bookingsRef!.once();
      final bookingsMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (bookingsMap != null) {
        List<Map<String, dynamic>> tempBookings = [];
        for (var bookingKey in bookingsMap.keys) {
          final booking = Map<String, dynamic>.from(bookingsMap[bookingKey]);
          final userId = booking['userId'];

          if (userId != null) {
            print('Fetching user data for userId: $userId'); // Debugging line
            final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
            if (userSnapshot.exists) {
              final userData = userSnapshot.data() as Map<String, dynamic>;
              print('User data: $userData'); // Debugging line

              booking['customerName'] = '${userData['name']} ${userData['lastName']}';
              booking['phoneNumber'] = userData['phoneNumber'];
              booking['email'] = userData['email'];
            } else {
              print('No user data found for userId: $userId'); // Debugging line
              booking['customerName'] = 'Unknown';
              booking['phoneNumber'] = 'Unknown';
              booking['email'] = 'Unknown';
            }
          } else {
            print('No userId found in booking'); // Debugging line
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
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings'),
        backgroundColor: Color(0xFF5956EB), // Light/primary color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text('No bookings found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
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
                              'Name: ${bookings[index]['customerName']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${bookings[index]['email']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Phone: ${bookings[index]['phoneNumber']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date: ${bookings[index]['date']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  bookings[index]['status']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusColor(bookings[index]['status']!),
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
