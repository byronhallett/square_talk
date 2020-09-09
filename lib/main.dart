import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _buttonText = "Listen";
  bool _listening = false;
  Color _qrColor = Colors.black;
  Random _rand = Random(DateTime.now().millisecondsSinceEpoch);
  stt.SpeechToText speech = stt.SpeechToText();
  String _sentence = "";

  @override
  void initState() {
    super.initState();
    speech.initialize(onStatus: statusListener, onError: errorListener);
  }

  void _buttonTapped() {
    if (!_listening) {
      _startRecord();
    } else {
      _stopRecord();
    }
  }

  void statusListener(String status) {
    dev.log(status);
    setState(() {
      _listening = status == 'listening';
      _buttonText = _listening ? "Shhhhh!" : "Listen";
    });
  }

  void errorListener(SpeechRecognitionError err) {}

  void resultListener(SpeechRecognitionResult res) {
    var top = res.alternates[0].recognizedWords;
    setState(() {
      _sentence = top;
    });
  }

  Future<void> _startRecord() async {
    if (speech.isAvailable) {
      speech.listen(onResult: resultListener, pauseFor: Duration(seconds: 5));
    }
  }

  void _stopRecord() {
    speech.stop();
  }

  void _tappedQR() {
    setState(() {
      _qrColor = Color.fromARGB(
          255, _rand.nextInt(255), _rand.nextInt(255), _rand.nextInt(255));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onPressed: _tappedQR,
              child: QrImage(
                data: _sentence,
                version: QrVersions.auto,
                foregroundColor: _qrColor,
                padding: EdgeInsets.all(20),
                // size: 300,
              ),
            ),
            FlatButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: _buttonTapped,
              child: Text(
                _buttonText,
                textScaleFactor: 1.5,
              ),
              padding: EdgeInsets.all(30),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }
}
