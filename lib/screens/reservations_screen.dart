import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _bookingsRef;
  List<Map<String, String>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchBookings(user.uid);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchBookings(String uid) async {
    _bookingsRef = FirebaseDatabase.instance.reference().child('Venues').child(uid).child('bookings');
    try {
      final snapshot = await _bookingsRef!.once();
      final bookingsMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (bookingsMap != null) {
        List<Map<String, String>> tempBookings = [];

        bookingsMap.forEach((key, value) {
          tempBookings.add({
            'customerName': value['customerName'] ?? '',
            'date': value['date'] ?? '',
            'status': value['status'] ?? '',
          });
          print('Booking: $value'); // Print each booking to the console
        });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F5FF), // Background color from Figma
      appBar: AppBar(
        title: Text('Reservations'),
        backgroundColor: Color(0xFF5956EB), // Light/primary color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text('No data found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Title Container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Reservations',
                              style: TextStyle(
                                fontFamily: 'Roboto Flex',
                                fontSize: 72,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5956EB),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List of Bookings
                      Expanded(
                        child: ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 3,
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF5956EB),
                                  ),
                                  title: Text(
                                    bookings[index]['date']!,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000).withOpacity(0.87),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${bookings[index]['customerName']} - ${bookings[index]['status']}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000).withOpacity(0.6),
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF000000).withOpacity(0.6),
                                  ),
                                  onTap: () {
                                    // Handle tap
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
