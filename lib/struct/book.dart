class Book {
  final int id;
  final String name;
  final String author;

  final List<dynamic> chapters;

  Book({required this.id, required this.name, required this.author, required this.chapters});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json["id"],
      name: json["name"],
      author: json["author"],
      chapters: json["chapters"],
    );
  }
}