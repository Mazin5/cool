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
  DatabaseReference? _reservedRef;
  List<DateTime> reservedDates = [];
  List<DateTime> vendorReservedDates = [];

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
        List<DateTime> tempVendorReservedDates = [];
        reservedMap.forEach((key, value) {
          DateTime reservedDate = DateFormat('yyyy-MM-dd').parse(key);
          tempReservedDates.add(reservedDate);
          if (value['vendorReserved'] == true) {
            tempVendorReservedDates.add(reservedDate);
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
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
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
        await reservedDateRef.set({'reserved': true, 'vendorReserved': true});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation confirmed for $formattedDate')),
        );
        setState(() {
          vendorReservedDates.add(selectedDate!);
          reservedDates.add(selectedDate!);
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
        vendorReservedDates.remove(date);
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
                  DateTime date = vendorReservedDates[index];
                  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  return ListTile(
                    title: Text(formattedDate),
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
