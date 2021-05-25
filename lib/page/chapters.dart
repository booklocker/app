import 'package:booklocker/struct/book.dart';
import 'package:booklocker/struct/chapter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';
import "package:booklocker/api.dart";

import 'chapter.dart';

class ChapterListing extends StatelessWidget {
  final Book book;
  final Chapter chapter;

  ChapterListing({Key? key, required this.book, required this.chapter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ChapterView(
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
    );
  }
}

class ChapterList extends StatefulWidget {
  final Book book;

  ChapterList({Key? key, required this.book}) : super(key: key);

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  Future<List<Chapter>> fetchChapters() async {
    final response = await http.get(Uri.parse(API_ENDPOINT + "/chapters?book=" + widget.book.id.toString())).timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((chapter) => new Chapter.fromJson(chapter)).toList();
    } else {
      throw Exception("Failed to load book list");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
      ),
      body: FutureBuilder<List<Chapter>>(
        future: fetchChapters(),
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
                          "Failed to fetch chapter list!",
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

          List<Chapter> chapters = snapshot.data!;

          return ListView.separated(
            itemCount: chapters.length + 2,
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black,
                height: 2,
              );
            },
            itemBuilder: (context, index) {
              if (index < 1 || index > chapters.length) return Container();
              return ChapterListing(
                book: widget.book,
                chapter: chapters[index - 1],
              );
            },
          );
        },
      ),
    );
  }
}
