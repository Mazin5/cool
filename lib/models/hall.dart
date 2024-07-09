class Hall {
  String? id;
  String title;
  String description;
  String image;
  double rating;
  Map<String, Reservation>? reservations;

  Hall({
    this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.rating,
    this.reservations,
  });

  factory Hall.fromJson(Map<String, dynamic> json, String id) {
    Map<String, Reservation> reservations = {};
    if (json['reservations'] != null) {
      json['reservations'].forEach((key, value) {
        reservations[key] = Reservation.fromJson(Map<String, dynamic>.from(value));
      });
    }
    return Hall(
      id: id,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] ?? 0).toDouble(),
      reservations: reservations,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['image'] = this.image;
    data['rating'] = this.rating;
    if (this.reservations != null) {
      data['reservations'] = this.reservations!.map((key, value) => MapEntry(key, value.toJson()));
    }
    return data;
  }
}

class Reservation {
  String date;
  String? email;
  String? phoneNumber;

  Reservation({required this.date, this.email, this.phoneNumber});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      date: json['date'] ?? 'No Date',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    if (this.email != null) {
      data['email'] = this.email;
    }
    if (this.phoneNumber != null) {
      data['phoneNumber'] = this.phoneNumber;
    }
    return data;
  }
}
