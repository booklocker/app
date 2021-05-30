import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openreader/struct/book.dart';
import 'package:openreader/struct/chapter.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChapterViewScreen extends StatelessWidget {
  final Book book;
  final Chapter chapter;

  ChapterViewScreen({Key? key, required this.book, required this.chapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.chapter.name),
      ),
      body: _ChapterView(book: this.book, chapter: this.chapter),
    );
  }
}

class _ChapterView extends StatefulWidget {
  final Book book;
  final Chapter chapter;

  _ChapterView({Key? key, required this.book, required this.chapter}) : super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<_ChapterView> {
  late List<Paragraph> _paragraphs;
  Object? _fetchError;

  Future<List<Paragraph>> _fetchParagraphs() async {
    var doc = await widget.chapter.reference.collection("contents").doc("paragraphs").get();
    List<Paragraph> newParagraphs = [];

    for (var paragraph in doc.get("paragraphs")) {
      newParagraphs.add(Paragraph.fromJson(paragraph["contents"]));
    }

    return newParagraphs;
  }

  @override
  void initState() {
    super.initState();

    _paragraphs = [];
    _fetchParagraphs().then((paragraphs) {
      if (mounted) setState(() {
        _paragraphs = paragraphs;
      });
    }).catchError((err) {
      if (mounted) setState(() {
        _fetchError = err;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchError != null) return SingleChildScrollView(
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
                  "Failed to fetch chapter!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(height: 10),
                Text(
                  "Error: " + _fetchError!.toString(),
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                Container(height: 10),
                Text(_fetchError is FirebaseException ? (_fetchError! as FirebaseException).stackTrace.toString() : "No Stacktrace Found"),
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
    ); else if (_paragraphs.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final sidePadding = 10.0;

    return ListView.builder(
      itemCount: _paragraphs.length + 3,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: EdgeInsets.fromLTRB(sidePadding, 15, sidePadding, 2),
            child: Text(
              widget.chapter.name,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (index == 1) {
          return Container(
            padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 15),
            child: Text(
              widget.book.name + " Chapter " + widget.chapter.number.toString(),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          );
        } else if (index == _paragraphs.length + 2) {
          return Container(height: 40);
        }

        List<TextSpan> textSpans = [];
        var paragraph = _paragraphs[index - 2];

        for (var text in paragraph.textSnippets) {
          if (text.style == null) {
            textSpans.add(TextSpan(text: text.text));
            continue;
          }

          var style = text.style!;
          textSpans.add(TextSpan(
            text: text.text,
            style: TextStyle(
              fontStyle: style.contains("italic") ? FontStyle.italic : FontStyle.normal,
              fontWeight: style.contains("bold") ? FontWeight.bold : FontWeight.normal,
            ),
          ));
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 5),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
              children: textSpans,
            ),
          ),
        );
      },
    );
  }
}
