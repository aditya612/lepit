// import 'package:flutter/material.dart';
// import 'package:lepit/user_media.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Lepit',
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: UserMedia(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lepit/utils/word_pair.dart';
import 'package:three_words/three_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Three Words Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _words = Words();
  int _numberOfWords = 5;
  List<String> wordsList = [];

  @override
  Widget build(BuildContext context) {
    wordsList = _words.randomWords(number: _numberOfWords);
    return Scaffold(
      appBar: AppBar(
        title: Text('Three Words Demo Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Number of words:  $_numberOfWords'),
              Slider(
                value: _numberOfWords.toDouble(),
                min: 3,
                max: 19,
                onChanged: (double value) {
                  setState(() {
                    _numberOfWords = value.floor();
                  });
                },
              ),
              Text(RandomWordPair().words),
              for (var w in RandomWordPair().wordPair) Text(w.toString()),
              Text('Random words :'),
              for (var i = 0; i < _numberOfWords; i++) ...{
                Text(wordsList[i] + " ")
              }
            ],
          ),
        ),
      ),
    );
  }
}
