import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openreader/struct/book.dart';
import 'package:openreader/struct/chapter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'chapter.dart';

class ChapterListScreen extends StatelessWidget {
  final Book book;

  ChapterListScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.book.name),
      ),
      body: _ChapterList(book: this.book),
    );
  }
}

class _ChapterList extends StatefulWidget {
  final Book book;

  _ChapterList({Key? key, required this.book}) : super(key: key);

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<_ChapterList> {
  late ScrollController _scrollController;
  late List<Chapter> _chapters;

  bool _currentlyFetching = true;
  bool _outOfChapters = false;

  Object? _fetchError;
  DocumentSnapshot? _lastVisibleChapter;

  Future<List<Chapter>> _fetchChapters() async {
    Query query = widget.book.ref.collection("chapters").orderBy("number").limit(10);
    if (_lastVisibleChapter != null) query = query.startAfterDocument(_lastVisibleChapter!);

    QuerySnapshot snapshot = await query.get();
    List<Chapter> newChapters = [];

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      newChapters.add(Chapter(
        reference: doc.reference,
        number: doc.get("number"),
        name: doc.get("name"),
      ));
    }

    if (snapshot.docs.length == 0) {
      print("Out of chapters!");
      if (mounted) this.setState(() {
        _outOfChapters = true;
      });
    } else {
      if (mounted) this.setState(() {
        _lastVisibleChapter = snapshot.docs[snapshot.docs.length - 1];
      });
    }

    return newChapters;
  }

  void _fetchMoreChapters() {
    setState(() {
      _currentlyFetching = true;
    });
    print("Fetching chapters...");
    _fetchChapters().then((newBooks) {
      if (mounted) setState(() {
        _currentlyFetching = false;
        _chapters.addAll(newBooks);
      });
    }).catchError((error) {
      if (mounted) setState(() {
        _currentlyFetching = false;
        _fetchError = error;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_onScroll);
    _chapters = [];

    _fetchMoreChapters();
  }

  void _onScroll() {
    if (!_currentlyFetching && _fetchError == null && !_outOfChapters && _scrollController.position.extentAfter < 500) {
      print("Fetching more chapters...");
      _fetchMoreChapters();
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
                    "Failed to fetch chapter list!",
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
    else if (_chapters.length == 0)
      return Center(
        child: CircularProgressIndicator(),
      );

    return ListView.separated(
        controller: _scrollController,
        itemCount: _chapters.length + 2,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.black,
            height: 2,
          );
        },
        itemBuilder: (context, index) {
          if (index < 1 || index > _chapters.length) return Container();
          return _ChapterListing(
            book: widget.book,
            chapter: _chapters[index - 1],
          );
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChapterListing extends StatelessWidget {
  final Book book;
  final Chapter chapter;

  _ChapterListing({Key? key, required this.book, required this.chapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ChapterViewScreen(
              book: this.book,
              chapter: this.chapter,
            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chapter " + this.chapter.number.toString(),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Container(height: 5),
            Text(
              this.chapter.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
