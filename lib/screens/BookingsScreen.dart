import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> confirmedBookings = [];
  List<Map<String, dynamic>> rejectedBookings = [];
  List<Map<String, dynamic>> locallyReservedBookings = [];
  bool isLoading = true;
  String? _serviceType;
  String? _vendorId;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        _fetchBookings();
      }
    } catch (error) {
      print('Error fetching service type: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBookings() async {
    if (_serviceType == null || _vendorId == null) return;

    try {
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection(_serviceType!)
          .doc(_vendorId)
          .collection('bookings')
          .get();

      List<Map<String, dynamic>> tempConfirmed = [];
      List<Map<String, dynamic>> tempRejected = [];
      List<Map<String, dynamic>> tempLocallyReserved = [];

      for (var bookingDoc in bookingsSnapshot.docs) {
        Map<String, dynamic> booking = bookingDoc.data() as Map<String, dynamic>;
        final userId = booking['userId'];

        if (booking['status'] == 'locally reserved') {
          final customerName = booking['name'] ?? 'Unknown';
          final customerEmail = booking['email'] ?? 'Unknown';
          final customerPhone = booking['phone'] ?? 'Unknown';
          final date = booking['date'] ?? 'Unknown';

          booking['customerName'] = customerName;
          booking['email'] = customerEmail;
          booking['phoneNumber'] = customerPhone;

          tempLocallyReserved.add(booking);
        } else {
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

          if (booking['status'] == 'confirmed') {
            tempConfirmed.add(booking);
          } else if (booking['status'] == 'rejected') {
            tempRejected.add(booking);
          }
        }
      }

      setState(() {
        confirmedBookings = tempConfirmed;
        rejectedBookings = tempRejected;
        locallyReservedBookings = tempLocallyReserved;
        isLoading = false;
      });
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
      case 'rejected':
        return Colors.red;
      case 'locally reserved':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'locally reserved':
        return Icons.watch_later;
      default:
        return Icons.info_outline;
    }
  }

  Widget buildBookingsList(List<Map<String, dynamic>> bookingsList) {
    if (bookingsList.isEmpty) {
      return Center(child: Text('No bookings found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookingsList.length,
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
                      'Name: ${bookingsList[index]['customerName']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      'Email: ${bookingsList[index]['email']}',
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
                      'Phone: ${bookingsList[index]['phoneNumber']}',
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
                      'Date: ${bookingsList[index]['date']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(getStatusIcon(bookingsList[index]['status']!), color: getStatusColor(bookingsList[index]['status']!)),
                    SizedBox(width: 8),
                    Text(
                      bookingsList[index]['status']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: getStatusColor(bookingsList[index]['status']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Bookings',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: "Confirmed"),
          Tab(text: "Rejected"),
          Tab(text: "Locally Reserved"),
        ],
      ),
    ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildBookingsList(confirmedBookings),
                buildBookingsList(rejectedBookings),
                buildBookingsList(locallyReservedBookings),
              ],
            ),
    );
  }
}
