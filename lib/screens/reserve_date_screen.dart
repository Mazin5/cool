import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
  DatabaseReference? _reservedRef;
  List<DateTime> reservedDates = [];
  List<Map<String, dynamic>> vendorReservedDates = [];

  @override
  void initState() {
    super.initState();
    _reservedRef = FirebaseDatabase.instance
        .reference()
        .child(widget.serviceType)
        .child(widget.serviceId)
        .child('reserved');
    _fetchReservedDates();
  }

  Future<void> _fetchReservedDates() async {
    try {
      DatabaseEvent event = await _reservedRef!.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> reservedMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
        List<DateTime> tempReservedDates = [];
        List<Map<String, dynamic>> tempVendorReservedDates = [];
        reservedMap.forEach((key, value) {
          DateTime reservedDate = DateFormat('yyyy-MM-dd').parse(key);
          tempReservedDates.add(reservedDate);
          if (value['vendorReserved'] == true) {
            tempVendorReservedDates.add({
              'date': reservedDate,
              'label': value['label'] ?? '',
              'name': value['name'] ?? 'Vendor',
            });
          }
        });
        setState(() {
          reservedDates = tempReservedDates;
          vendorReservedDates = tempVendorReservedDates;
        });
      }
    } catch (error) {
      print('Error fetching reserved dates: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        // Disable dates that are already reserved
        return !reservedDates.contains(date);
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDateLabel = null;
      });
      _showLabelDialog();
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
      DatabaseReference reservedDateRef = _reservedRef!.child(formattedDate);
      DatabaseEvent event = await reservedDateRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorry, this date is already reserved. Please select another date.')),
        );
        return;
      }

      try {
        await reservedDateRef.set({'reserved': true, 'vendorReserved': true, 'label': selectedDateLabel, 'name': 'Vendor'});

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
    DatabaseReference reservedDateRef = _reservedRef!.child(formattedDate);

    try {
      await reservedDateRef.remove();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Date'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedDate == null
                  ? 'No date selected!'
                  : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Select Date'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmReservation,
              child: Text('Confirm Reservation'),
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
                  return ListTile(
                    title: Text(formattedDate),
                    subtitle: Text('Label: ${reservation['label']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteReservation(date),
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
