class Hall {
  String? hallName;
  String? hallPhone;
  String? location;
  String? description;
  List<String>? hallPictures;

  Hall({
    this.hallName,
    this.hallPhone,
    this.location,
    this.description,
    this.hallPictures,
  });

  factory Hall.fromMap(Map<String, dynamic> map) {
    return Hall(
      hallName: map['hallName'],
      hallPhone: map['hallPhone'],
      location: map['location'],
      description: map['description'],
      hallPictures: List<String>.from(map['hallPictures']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hallName': hallName,
      'hallPhone': hallPhone,
      'location': location,
      'description': description,
      'hallPictures': hallPictures,
    };
  }
}
