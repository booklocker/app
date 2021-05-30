import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final DocumentReference ref;
  final String name;
  final String author;
  final List<dynamic> chapters;

  Book({required this.ref, required this.name, required this.author, required this.chapters});
}