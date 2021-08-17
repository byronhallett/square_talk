import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fullscreen/fullscreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Calc',
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
      home: const MyHomePage(title: 'QR Calc'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _rand = Random(DateTime.now().millisecondsSinceEpoch);

  String _buttonText = "Listen";
  bool _listening = false;
  Color _qrColor = Colors.black;
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
      speech.listen(onResult: resultListener, pauseFor: const Duration(seconds: 5));
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
                padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(30),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }
}
