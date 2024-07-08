class Hall {
  final String key; // Add a key field to identify the hall in Firebase
  final String name;
  final String description;
  final String location;
  final String phoneNumber;
  final String imageUrl;
  final String capacity;
  final String price;

  Hall({
    required this.key,
    required this.name,
    required this.description,
    required this.location,
    required this.phoneNumber,
    required this.imageUrl,
    required this.capacity,
    required this.price,
  });

  // Add a factory method to create a Hall object from a map
  factory Hall.fromMap(Map<String, dynamic> data, String key) {
    return Hall(
      key: key,
      name: data['name'].toString(),
      description: data['description'].toString(),
      location: data['location'].toString(),
      phoneNumber: data['phoneNumber'].toString(),
      imageUrl: data['imageUrl'].toString(),
      capacity: data['capacity'].toString(),
      price: data['price'].toString(),
    );
  }

  // Add a method to convert a Hall object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'price': price,
    };
  }
}
