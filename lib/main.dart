import 'dart:async';
import 'dart:convert';
//import 'dart:html';
//import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:quiz/quiz.dart';
import 'package:html/parser.dart';

//import 'package:flutter/src/widgets/text.dart';
//import 'package:html/dom.dart';
//JSONDECODE CONVERTS JSON STRING TO MAP
//JSON ENCODE DOES THE REVERSE
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Quiz App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

int correct, attempt, wrong;
//Color c;
//

class _HomeState extends State<Home> {
  //var r;
  var watch = Stopwatch();
  //Color c;
  Quiz quiz;
  List<Results> results;
  Future<void> getQuestion() async {
    //var res = await http.get("https://opentdb.com/api.php?amount=20");
    var res =
        await http.get(Uri.parse("https://opentdb.com/api.php?amount=20"));
    //var res = utf8.decode(base64.decode(res1));

    // if (res.statusCode == 200) {
    //   print("hello1");
    //   //return Album.fromJson(jsonDecode(response.body));
    // } else {
    //   print(res.statusCode);
    //   throw Exception('Failed to load album');
    //   //print(res.statusCode);
    //   print("hello10");
    // }
    //  print(res.body);

    var decRes = jsonDecode(res.body);
    print(decRes);
    // //print("hello");
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
    //c = Colors.black;
    // return results;
  }

  void start() {
    watch.start();
  }

  void stop() {
    watch.stop();
  }

  void reset() {
    watch.reset();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    correct = 0;
    attempt = 0;
    wrong = 0;
    start();
    //f = 0;
    //getQuestion();
  }

  Future<void> f1() {
    //getQuestion();
    setState(() {});
    return getQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Knowledge Quiz"),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.near_me,
              size: 30,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return score();
                  });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getQuestion(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text("lets go");
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return errordata(snapshot);
              }
              return questionList();
            // Container(
            //   child: Text("Data arrived"),
            // );
          }
          return null;
          //return Text("");
        },
      ),
    );
  }

  ListView questionList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0.0,
          child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parseHtmlString(results[index].question),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FittedBox(
                    child: Row(
                      children: [
                        FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(parseHtmlString(results[index].category)),
                          onSelected: (bool) {},
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        FilterChip(
                          backgroundColor: Colors.grey[100],
                          label:
                              Text(parseHtmlString(results[index].difficulty)),
                          onSelected: (bool) {},
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(parseHtmlString(
                  results[index].type.startsWith("m") ? "M" : "B")),
            ),
            children: results[index].allAnswers.map((x) {
              return AnsweWid(index: index, m: x, results: results);
            }).toList(),
          ),
        );
      },
    );
  }

  Dialog score() {
    var r = watch.elapsed.inSeconds;
    var sec = r % 60;
    var min = r / 60;
    String title1 = "Number of correct are : $correct";

    String title2 = "Number of attempted are : $attempt";
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        height: 300,
        child: Column(
          children: [
            Expanded(
                child: Container(
                    color: Colors.white70,
                    child: Icon(
                      Icons.done_sharp,
                      size: 60,
                      color: Colors.green,
                    ))),
            Expanded(
              child: Container(
                color: Colors.blueAccent,
                child: SizedBox.expand(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(title2,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            ((watch.elapsed.inSeconds) ~/ 60) < 10 &&
                                    ((watch.elapsed.inSeconds) % 60) < 10
                                ? "Time taken (mm::ss) : " +
                                    "0" +
                                    ((watch.elapsed.inSeconds) ~/ 60)
                                        .toString() +
                                    ":0" +
                                    ((watch.elapsed.inSeconds) % 60).toString()
                                : (((watch.elapsed.inSeconds) ~/ 60) < 10
                                    ? "Time taken (mm::ss) : " +
                                        "0" +
                                        ((watch.elapsed.inSeconds) ~/ 60)
                                            .toString() +
                                        ":" +
                                        ((watch.elapsed.inSeconds) % 60)
                                            .toString()
                                    : (((watch.elapsed.inSeconds) % 60) < 10
                                        ? "Time taken (mm::ss) : " +
                                            ((watch.elapsed.inSeconds) ~/ 60)
                                                .toString() +
                                            ":0" +
                                            ((watch.elapsed.inSeconds) % 60)
                                                .toString()
                                        : "Time taken (mm::ss) : " +
                                            ((watch.elapsed.inSeconds) ~/ 60)
                                                .toString() +
                                            ":" +
                                            ((watch.elapsed.inSeconds) % 60)
                                                .toString())),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.teal),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    print("h1");
                                    print(watch.elapsed.inSeconds);
                                    // r = watch.elapsed.inSeconds;
                                    reset();
                                    // f = 1;
                                    setState(() {
                                      correct = 0;
                                      wrong = 0;
                                      attempt = 0;
                                      // setState(() {
                                      // });
                                    });
                                  },
                                  child: Text("okay")),
                            ])
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  Padding errordata(AsyncSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: ${snapshot.error}"),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              getQuestion();

              setState(() {});
            },
            child: Text("Try Again"),
          ),
          Text("Try again"),
        ],
      ),
    );
  }
}

class AnsweWid extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;
  AnsweWid({this.index, this.m, this.results});
  @override
  _AnsweWidState createState() => _AnsweWidState();
}

class _AnsweWidState extends State<AnsweWid> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.m == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
            correct = correct + 1;
            attempt = attempt + 1;
          } else {
            c = Colors.red;
            attempt = attempt + 1;
            wrong = wrong + 1;
          }
        });
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
