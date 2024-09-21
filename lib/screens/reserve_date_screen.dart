import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class ReserveDateScreen extends StatefulWidget {
  final String serviceType;
  final String serviceId;

  ReserveDateScreen({required this.serviceType, required this.serviceId});

  @override
  _ReserveDateScreenState createState() => _ReserveDateScreenState();
}

class _ReserveDateScreenState extends State<ReserveDateScreen> {
  DateTime? selectedDate;
  String? selectedDateLabel;
  String? customerName;
  String? customerEmail;
  String? customerPhone;
  List<DateTime> reservedDates = [];
  List<Map<String, dynamic>> vendorReservedDates = [];
  Map<DateTime, List<String>> events = {};
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchReservedDates();
  }

  Future<void> _fetchReservedDates() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(widget.serviceType)
          .doc(widget.serviceId)
          .collection('bookings')
          .where('status', isEqualTo: 'locally reserved')
          .get();

      List<DateTime> tempReservedDates = [];
      List<Map<String, dynamic>> tempVendorReservedDates = [];
      Map<DateTime, List<String>> tempEvents = {};

      querySnapshot.docs.forEach((doc) {
        DateTime reservedDate = DateFormat('yyyy-MM-dd').parse(doc['date']);
        tempReservedDates.add(reservedDate);
        tempVendorReservedDates.add({
          'date': reservedDate,
          'label': doc['label'] ?? '',
          'name': doc['name'] ?? 'Unknown',
          'email': doc['email'] ?? 'Unknown',
          'phone': doc['phone'] ?? 'Unknown',
        });
        tempEvents[reservedDate] = ['Reserved'];
      });

      setState(() {
        reservedDates = tempReservedDates;
        vendorReservedDates = tempVendorReservedDates;
        events = tempEvents;
      });
    } catch (error) {
      print('Error fetching reserved dates: $error');
    }
  }

  Future<void> _showLabelDialog() async {
    TextEditingController labelController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Reservation Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(labelText: 'Label'),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  selectedDateLabel = labelController.text;
                  customerName = nameController.text;
                  customerEmail = emailController.text;
                  customerPhone = phoneController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmReservation() async {
    if (selectedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      // Check if the date is already reserved in 'bookings'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.serviceType)
          .doc(widget.serviceId)
          .collection('bookings')
          .where('date', isEqualTo: formattedDate)
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorry, this date is already reserved. Please select another date.')),
        );
        return;
      }

      try {
        User? user = _auth.currentUser;
        if (user == null) throw 'User is not logged in.';

        // Save to the 'bookings' collection, following the same structure
        await FirebaseFirestore.instance
            .collection(widget.serviceType)
            .doc(widget.serviceId)
            .collection('bookings')
            .add({
          'userId': user.uid,
          'userName': user.email,
          'date': formattedDate,
          'label': selectedDateLabel ?? 'No Label',
          'status': 'locally reserved',
          'name': customerName ?? 'Unknown',
          'email': customerEmail ?? 'Unknown',
          'phone': customerPhone ?? 'Unknown',
          'user_archive': false,
          'vendor_archive': false,
          'admin_archive': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation confirmed for $formattedDate')),
        );

        setState(() {
          vendorReservedDates.add({
            'date': selectedDate!,
            'label': selectedDateLabel ?? '',
            'name': customerName,
            'email': customerEmail,
            'phone': customerPhone,
          });
          reservedDates.add(selectedDate!);
          selectedDate = null;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm reservation: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
    }
  }

  Future<void> _deleteReservation(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      // Delete from the 'bookings' collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.serviceType)
          .doc(widget.serviceId)
          .collection('bookings')
          .where('date', isEqualTo: formattedDate)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation for $formattedDate deleted')),
      );
      setState(() {
        vendorReservedDates.removeWhere((element) => element['date'] == date);
        reservedDates.remove(date);
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reservation: $error')),
      );
    }
  }

  bool _isDateReserved(DateTime date) {
    return reservedDates.contains(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Date'),
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
      // Set this to true to avoid overflow when the keyboard is up
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                selectedDayPredicate: (day) {
                  return isSameDay(selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isAfter(DateTime.now().subtract(Duration(days: 1))) && !_isDateReserved(selectedDay)) {
                    setState(() {
                      selectedDate = selectedDay;
                      selectedDateLabel = null;
                    });
                    _showLabelDialog();
                  } else if (selectedDay.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You cannot select a past date.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('This date is already reserved. Please select another date.')),
                    );
                  }
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    if (_isDateReserved(date) || date.isBefore(DateTime.now())) {
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: date.isBefore(DateTime.now()) ? Colors.grey : Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return null;
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                      );
                    }
                  },
                ),
                eventLoader: (day) {
                  return events[day] ?? [];
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('Confirm Reservation', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
