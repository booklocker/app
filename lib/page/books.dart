import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:openreader/icons/font_awesome_icons.dart';
import 'package:openreader/page/chapters.dart';
import 'package:openreader/page/login.dart';
import 'package:openreader/server/auth.dart';
import 'package:openreader/struct/book.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openreader/widget/buttons.dart';

enum MainMenuItems { logOut }

class BookListScreen extends StatelessWidget {
  BookListScreen({Key? key, required this.user}) : super(key: key);

  final User user;

  void _logOut(BuildContext context) async {
    await Authentication.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => new LoginScreen(),
      ),
    );
  }

  void _openMenu(context) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Menu"),
            children: [
              SimpleDialogOption(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text("Log Out"),
                ),
                onPressed: () => _logOut(context),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 3,
                  center: Alignment.topRight,
                  colors: [Colors.red.withOpacity(0.5), Colors.blue.withOpacity(0.5)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Voltpaper",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(height: 2),
                      Text(
                        "Your Bookshelf",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    child: GradientButton(
                      onPressed: () => _openMenu(context),
                      borderRadius: 50,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        primary: Colors.black,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      colors: [Colors.redAccent.withOpacity(0.3), Colors.red.withOpacity(0.3)],
                      child: Icon(FontAwesome.ellipsis_h_regular),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              height: 1,
              color: Colors.black,
            ),
            Expanded(
              child: Container(
                color: Colors.grey.withOpacity(0.4),
                child: BookList(user: user),
              ),
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
  late ScrollController _scrollController;
  late List<Book> _books;

  bool _currentlyFetching = true;
  bool _outOfBooks = false;

  Object? _fetchError;
  DocumentSnapshot? _lastVisibleBook;

  Future<List<Book>> _fetchBooks() async {
    final completer = Completer<List<Book>>();
    var query = FirebaseFirestore.instance.collection("books").orderBy("name").limit(10);
    if (_lastVisibleBook != null) query = query.startAfterDocument(_lastVisibleBook!);

    query.snapshots().listen((snapshot) async {
      List<Book> newBooks = [];

      for (var bookDoc in snapshot.docs) {
        var bookData = bookDoc.data();
        String bookName = bookData["name"];

        DocumentSnapshot authorData = await bookData["author"].get();
        String authorName = authorData["name"];

        newBooks.add(Book(
          id: bookDoc.id,
          name: bookName,
          author: authorName,
          chapters: [],
        ));
      }

      if (snapshot.docs.length == 0) {
        print("Out of books!");
        this.setState(() {
          _outOfBooks = true;
        });
      } else {
        this.setState(() {
          _lastVisibleBook = snapshot.docs[snapshot.docs.length - 1];
        });
      }

      completer.complete(newBooks);
    });

    return completer.future;
  }

  void _fetchMoreBooks() {
    setState(() {
      _currentlyFetching = true;
    });
    print("Fetching books...");
    _fetchBooks().then((newBooks) {
      setState(() {
        _currentlyFetching = false;
        _books.addAll(newBooks);
      });
    }).catchError((error) {
      setState(() {
        _currentlyFetching = false;
        _fetchError = error;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_onScroll);
    _books = [];

    _fetchMoreBooks();
  }

  void _onScroll() {
    if (!_currentlyFetching && _fetchError == null && !_outOfBooks && _scrollController.position.extentAfter < 500) {
      _fetchMoreBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchError != null)
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
                  Text("Error: " + _fetchError.toString()),
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
    else if (_books.length == 0)
      return Center(
        child: CircularProgressIndicator(),
      );

    return ListView.builder(
      controller: _scrollController,
      itemCount: _books.length + 2,
      itemBuilder: (context, index) {
        if (index < 1 || index > _books.length) return Container();
        return BookListing(
          book: _books[index - 1],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class BookListing extends StatelessWidget {
  final Book book;

  BookListing({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: GradientButton(
        colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.05)],
        borderRadius: 10,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          primary: Colors.black,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
