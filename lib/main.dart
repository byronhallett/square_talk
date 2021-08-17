import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: Colors.lime,
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

class Palette {
  static const Color screenColor = Color(0xffD1DFC2);
  static const Color screenTextColor = Color(0xff041421);
  static const Color bodyColor = Color.fromRGBO(0x48, 0x4b, 0x54, 1.0);
  static const Color buttonColor = Color(0xff86898E);
  static const Color buttonTextColor = Color(0xffEDEDF1);
  static const Color calcModelColor = Color(0xffA5943F);
}

class Style {
  static TextStyle textStyle =
  GoogleFonts.basic(color: Palette.buttonTextColor);
  static TextStyle brandStyle = textStyle.copyWith(fontSize: 28);
  static TextStyle buttonTextStyle = textStyle.copyWith(fontSize: 32);
  static TextStyle modelStyle =
  textStyle.copyWith(color: Palette.calcModelColor, fontSize: 20);
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    primary: Palette.buttonColor,
    padding: const EdgeInsets.all(30),
    textStyle: Style.modelStyle,
    shadowColor: Colors.black,
    elevation: 100,
  );
  static TextStyle screenTextStyle = const TextStyle(
      fontSize: 28, fontFamily: "Segment", color: Palette.screenTextColor);
}

class _MyHomePageState extends State<MyHomePage> {
  final Random _rand = Random(DateTime
      .now()
      .millisecondsSinceEpoch);

  String _buttonText = "RECORD";
  String _screenText = "TAP RECORD :)";
  bool _listening = false;
  Color _qrColor = Palette.screenTextColor;
  stt.SpeechToText speech = stt.SpeechToText();
  String _sentence = "";

  @override
  void initState() {
    super.initState();
    speech.initialize(onStatus: statusListener, onError: errorListener);
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
  }

  void _recordButtonTapped() {
    dev.log("tapped");
    if (!_listening) {
      _startRecord();
    } else {
      _stopRecord();
    }
  }

  void statusListener(String status) {
    setState(() {
      _listening = status == 'listening';
      _buttonText = _listening ? "STOP" : "RECORD";
      _screenText = _listening ? "QR CODE: RECORDING" : "QR READY";
    });
  }

  void errorListener(SpeechRecognitionError err) {}

  void resultListener(SpeechRecognitionResult res) {
    var top = res.alternates[0].recognizedWords;
    setState(() {
      _sentence = top;
    });
  }

  //
  // Future<void> vibrate() async {
  //   bool has = await Vibration.hasVibrator() ?? false;
  //   bool amp = await Vibration.hasAmplitudeControl() ?? false;
  //   if (has) {
  //     if (amp) {
  //       Vibration.vibrate(amplitude: 64, duration: 300);
  //     } else {
  //       Vibration.vibrate(duration: 300);
  //     }
  //   }
  // }

  Future<void> _startRecord() async {
    if (speech.isAvailable) {
      speech.listen(
          onResult: resultListener, pauseFor: const Duration(seconds: 10));
      // vibrate();
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
      backgroundColor: Palette.bodyColor,
      body: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // BODY TEXT AREA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NONSENSE CORP", style: Style.brandStyle),
                  Text("AI REAL-TIME SPEECH-TO-QR", style: Style.textStyle),
                  Text("TRANSLATION COMPUTER SYSTEM", style: Style.textStyle),
                ],
              ),
              Text("QR-83 PLUS", style: Style.modelStyle),
            ],
          ),
          // SCREEN AREA
          Container(
            color: Palette.screenColor,
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _screenText,
                    style: Style.screenTextStyle,
                  ),
                ),
                const Divider(
                  color: Palette.screenTextColor,
                  indent: 0.0,
                  thickness: 2.0,
                ),
                TextButton(
                  onPressed: _tappedQR,
                  child: QrImage(
                    data: _sentence,
                    version: QrVersions.auto,
                    foregroundColor: _qrColor,
                    backgroundColor: Palette.screenColor,
                    padding: const EdgeInsets.all(10),
                    // size: 300,
                  ),
                ),
              ],
            ),
          ),
          // BUTTON AREA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: Style.buttonStyle,
                  onPressed: () {},
                  child: Text("SHARE", style: Style.buttonTextStyle),
                ),
              ),

              Container(
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: Style.buttonStyle,
                  onPressed: _recordButtonTapped,
                  onLongPress: _recordButtonTapped,
                  child: Text(_buttonText, style: Style.buttonTextStyle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
