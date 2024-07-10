class Hall {
  String? id;
  String description;
  String hallName;
  String hallNumber;
  String location;
  List<String> pictureUrls;
  Map<String, Reservation>? reservations;

  Hall({
    this.id,
    required this.description,
    required this.hallName,
    required this.hallNumber,
    required this.location,
    required this.pictureUrls,
    this.reservations,
  });

  factory Hall.fromJson(Map<String, dynamic> json, String id) {
    Map<String, Reservation> reservations = {};
    if (json['reservations'] != null) {
      json['reservations'].forEach((key, value) {
        reservations[key] =
            Reservation.fromJson(Map<String, dynamic>.from(value));
      });
    }
    return Hall(
      id: id,
      description: json['description'] ?? 'No Description',
      hallName: json['hallName'] ?? 'No Name',
      hallNumber: json['hallNumber'] ?? 'No Number',
      location: json['location'] ?? 'No Location',
      pictureUrls: List<String>.from(json['pictureUrls'] ?? []),
      reservations: reservations,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['hallName'] = this.hallName;
    data['hallNumber'] = this.hallNumber;
    data['location'] = this.location;
    data['pictureUrls'] = this.pictureUrls;
    if (this.reservations != null) {
      data['reservations'] =
          this.reservations!.map((key, value) => MapEntry(key, value.toJson()));
    }
    return data;
  }
}

class Reservation {
  String customerName;
  String customerContact;
  String date;
  String status;

  Reservation({
    required this.customerName,
    required this.customerContact,
    required this.date,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      customerName: json['customerName'] ?? 'No Name',
      customerContact: json['customerContact'] ?? 'No Contact',
      date: json['date'] ?? 'No Date',
      status: json['status'] ?? 'No Status',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerName'] = this.customerName;
    data['customerContact'] = this.customerContact;
    data['date'] = this.date;
    data['status'] = this.status;
    return data;
  }
}
