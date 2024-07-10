import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Map<String, String>> reservations = [];
  bool isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference vendorRef = FirebaseDatabase.instance
          .reference()
          .child('vendors')
          .child(user.uid)
          .child('halls');

      vendorRef.once().then((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> hallMap =
              snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, String>> tempReservations = [];

          hallMap.forEach((hallKey, hallValue) {
            if (hallValue['reservations'] != null) {
              Map<dynamic, dynamic> reservationMap =
                  hallValue['reservations'] as Map<dynamic, dynamic>;
              reservationMap.forEach((resKey, resValue) {
                tempReservations.add({
                  'customerName': resValue['customerName'] ?? 'No Name',
                  'customerContact':
                      resValue['customerContact'] ?? 'No Contact',
                  'date': resValue['date'] ?? 'No Date',
                  'status': resValue['status'] ?? 'No Status'
                });
              });
            }
          });

          setState(() {
            reservations = tempReservations;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((error) {
        print('Error fetching reservations: $error');
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
      backgroundColor: Color(0xFFF2F5FF), // Background color from Figma
      appBar: AppBar(
        title: Text('Reservations'),
        backgroundColor: Color(0xFF5956EB), // Light/primary color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5956EB),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List of Reservations
                  Expanded(
                    child: ListView.builder(
                      itemCount: reservations.length,
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
                                reservations[index]['date']!,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000).withOpacity(0.87),
                                ),
                              ),
                              subtitle: Text(
                                reservations[index]['customerName']!,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF000000).withOpacity(0.6),
                                ),
                              ),
                              trailing: Text(
                                reservations[index]['status']!,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: reservations[index]['status'] ==
                                          'confirmed'
                                      ? Colors.green
                                      : reservations[index]['status'] ==
                                              'canceled'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
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
