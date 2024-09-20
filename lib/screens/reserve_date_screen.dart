import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  List<DateTime> reservedDates = [];
  List<Map<String, dynamic>> vendorReservedDates = [];
  Map<DateTime, List<String>> events = {};

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
          .collection('reserved')
          .get();

      List<DateTime> tempReservedDates = [];
      List<Map<String, dynamic>> tempVendorReservedDates = [];
      Map<DateTime, List<String>> tempEvents = {};

      querySnapshot.docs.forEach((doc) {
        DateTime reservedDate = DateFormat('yyyy-MM-dd').parse(doc.id);
        tempReservedDates.add(reservedDate);
        if (doc['vendorReserved'] == true) {
          tempVendorReservedDates.add({
            'date': reservedDate,
            'label': doc['label'] ?? '',
            'name': doc['name'] ?? 'Vendor',
          });
        }
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Label for Reserved Date'),
          content: TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: 'Label'),
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

      // Check if the date is already reserved
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(widget.serviceType)
          .doc(widget.serviceId)
          .collection('reserved')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorry, this date is already reserved. Please select another date.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection(widget.serviceType)
            .doc(widget.serviceId)
            .collection('reserved')
            .doc(formattedDate)
            .set({'reserved': true, 'vendorReserved': true, 'label': selectedDateLabel, 'name': 'Vendor'});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation confirmed for $formattedDate')),
        );
        setState(() {
          vendorReservedDates.add({'date': selectedDate!, 'label': selectedDateLabel ?? '', 'name': 'Vendor'});
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
      await FirebaseFirestore.instance
          .collection(widget.serviceType)
          .doc(widget.serviceId)
          .collection('reserved')
          .doc(formattedDate)
          .delete();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            Text(
              'Your Reserved Dates:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vendorReservedDates.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> reservation = vendorReservedDates[index];
                  DateTime date = reservation['date'];
                  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(formattedDate),
                      subtitle: Text('Label: ${reservation['label']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReservation(date),
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
