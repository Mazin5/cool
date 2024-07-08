import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReservationsScreen extends StatelessWidget {
  final DatabaseReference reservationsRef =
      FirebaseDatabase.instance.ref().child('reservations');

  ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
      ),
      body: StreamBuilder(
        stream: reservationsRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No reservations available.'));
          }

          // Handle data as List or Map
          List<Reservation> reservations = [];
          if (snapshot.data!.snapshot.value is List) {
            final dataList = snapshot.data!.snapshot.value as List;
            reservations = dataList
                .where((element) =>
                    element != null) // Handle potential null entries
                .map((element) {
              final reservationData = Map<String, dynamic>.from(element);
              return Reservation(
                customerName: reservationData['customerName'],
                reservationDate: reservationData['reservationDate'],
                status: reservationData['status'],
              );
            }).toList();
          } else if (snapshot.data!.snapshot.value is Map) {
            final reservationsMap =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            reservations = reservationsMap.entries.map((entry) {
              final reservationData =
                  Map<String, dynamic>.from(entry.value as Map);
              return Reservation(
                customerName: reservationData['customerName'],
                reservationDate: reservationData['reservationDate'],
                status: reservationData['status'],
              );
            }).toList();
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              var reservation = reservations[index];
              return ReservationCard(
                customerName: reservation.customerName,
                reservationDate: reservation.reservationDate,
                status: reservation.status,
              );
            },
          );
        },
      ),
    );
  }
}

class Reservation {
  final String customerName;
  final String reservationDate;
  final String status;

  Reservation({
    required this.customerName,
    required this.reservationDate,
    required this.status,
  });
}

class ReservationCard extends StatelessWidget {
  final String customerName;
  final String reservationDate;
  final String status;

  const ReservationCard({
    super.key,
    required this.customerName,
    required this.reservationDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Date: $reservationDate',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 16.0,
                color: status == 'Confirmed'
                    ? Colors.green
                    : status == 'Pending'
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
