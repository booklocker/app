import 'package:firebase_auth/firebase_auth.dart';
import 'package:openreader/page/chapters.dart';
import 'package:openreader/struct/book.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookListing extends StatelessWidget {
  final Book book;

  BookListing({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ChapterList(book: this.book),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(1, 0);
              var end = Offset.zero;
              var tween = Tween(begin: begin, end: end);
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: 52,
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
                )),
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
      ),
    );
  }
}

class BookList extends StatefulWidget {
  BookList({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hi, " + (widget.user.displayName != null ? widget.user.displayName! : widget.user.email!)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("books").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var errMsg = snapshot.error.toString();

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
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var books = snapshot.data!.docs.asMap();

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
              var bookData = books[index - 1]!.data() as Map<String, dynamic>;

              var bookName = bookData["name"];
              var chapterList = bookData["chapters"] as List<dynamic>;

              return FutureBuilder(
                future: bookData["author"].get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      child: Text("Failed to load details for book '" + bookName + "'"),
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return BookListing(
                      book: Book(
                        id: -1,
                        name: bookName,
                        author: "Loading...",
                        chapters: chapterList,
                      ),
                    );
                  }

                  var author = snapshot.data!.data() as Map<String, dynamic>;
                  return BookListing(
                    book: Book(
                      id: -1,
                      name: bookName,
                      author: author["name"],
                      chapters: chapterList,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
