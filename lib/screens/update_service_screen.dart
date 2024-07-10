// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../models/hall.dart';

// class UpdateServiceScreen extends StatefulWidget {
//   final Hall hall;

//   UpdateServiceScreen({required this.hall});

//   @override
//   _UpdateServiceScreenState createState() => _UpdateServiceScreenState();
// }

// class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late String title;
//   late String description;
//   late String image;
//   late double rating;

//   @override
//   void initState() {
//     super.initState();
//     title = widget.hall.title;
//     description = widget.hall.description;
//     image = widget.hall.image;
//     rating = widget.hall.rating;
//   }

//   _updateHall() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       DatabaseReference hallRef = FirebaseDatabase.instance.reference().child('Hall').child(widget.hall.id!);
//       Hall updatedHall = Hall(
//         id: widget.hall.id,
//         title: title,
//         description: description,
//         image: image,
//         rating: rating,
//       );
//       hallRef.set(updatedHall.toJson()).then((_) {
//         Navigator.pop(context);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Service'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: title,
//                 decoration: InputDecoration(labelText: 'Title'),
//                 onSaved: (value) => title = value!,
//               ),
//               TextFormField(
//                 initialValue: description,
//                 decoration: InputDecoration(labelText: 'Description'),
//                 onSaved: (value) => description = value!,
//               ),
//               TextFormField(
//                 initialValue: image,
//                 decoration: InputDecoration(labelText: 'Image URL'),
//                 onSaved: (value) => image = value!,
//               ),
//               TextFormField(
//                 initialValue: rating.toString(),
//                 decoration: InputDecoration(labelText: 'Rating'),
//                 keyboardType: TextInputType.number,
//                 onSaved: (value) => rating = double.parse(value!),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _updateHall,
//                 child: Text('Update'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
