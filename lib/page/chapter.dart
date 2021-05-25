import 'package:booklocker/struct/book.dart';
import 'package:booklocker/struct/chapter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';
import "package:booklocker/api.dart";

class ChapterView extends StatefulWidget {
  final Book book;
  final Chapter chapter;

  ChapterView({Key? key, required this.book, required this.chapter}) : super(key: key);

  @override
  _ChapterViewState createState() => _ChapterViewState();
}

class _ChapterViewState extends State<ChapterView> {
  Future<Chapter> fetchChapter() async {
    final url = API_ENDPOINT + "/chapter?book=" + widget.book.id.toString() + "&chapter=" + widget.chapter.number.toString();
    final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 2));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return new Chapter.fromJson(jsonResponse);
    } else {
      throw Exception("Failed to load chapter");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.name),
      ),
      body: FutureBuilder<Chapter>(
        future: fetchChapter(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            var errMsg = snapshot.error.toString();
            if (snapshot.error is TimeoutException) {
              errMsg = "Couldn't connect to the server";
            }

            return SingleChildScrollView(
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
                          "Error: " + errMsg,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        Container(height: 10),
                        Text(snapshot.stackTrace.toString()),
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

          Chapter chapter = snapshot.data!;
          List<Paragraph> paragraphs = chapter.contents!;

          final sidePadding = 10.0;

          return ListView.builder(
            itemCount: paragraphs.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: EdgeInsets.fromLTRB(sidePadding, 15, sidePadding, 2),
                  child: Text(
                    chapter.name,
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
                    widget.book.name + " Chapter " + chapter.number.toString(),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );
              }

              List<TextSpan> textSpans = [];
              var paragraph = paragraphs[index - 2];

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
                padding: EdgeInsets.fromLTRB(sidePadding, 3, sidePadding, 3),
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
        },
      ),
    );
  }
}