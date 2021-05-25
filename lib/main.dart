import 'package:booklocker/struct/book.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';

final String API_ENDPOINT = "http://192.168.0.220:10000";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Locker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: BookList(title: 'My Books'),
    );
  }
}

class BookListing extends StatelessWidget {
  final Book book;

  BookListing({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 70,
            alignment: Alignment.center,
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              border: Border.all(
                width: 1,
                color: Colors.black,
              ),
            ),
            child: Text(
              this.book.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ),
          Container(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                this.book.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Container(height: 2),
              Text(
                this.book.author,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookList extends StatefulWidget {
  BookList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse(API_ENDPOINT + "/books")).timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => new Book.fromJson(book)).toList();
    } else {
      throw Exception("Failed to load book list");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Book>>(
        future: fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var errMsg = snapshot.error.toString();
            if (snapshot.error is TimeoutException) {
              errMsg = "Couldn't connect to the server";
            }

            return Container(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Failed to fetch book list!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Container(height: 10),
                        Text("Error: " + errMsg),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    child: MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10),
                      shape: CircleBorder(),
                      onPressed: () {
                        print("refresh");
                        this.setState(() {});
                      },
                      child: Icon(
                        Icons.refresh,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Book> books = snapshot.data!;

          return ListView.separated(
            itemCount: books.length + 2,
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black,
                height: 2,
              );
            },
            itemBuilder: (context, index) {
              if (index < 1 || index > books.length) return Container();
              return BookListing(
                book: books[index - 1],
              );
            },
          );
        },
      ),
    );
  }
}
