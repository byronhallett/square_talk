import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';


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
  static const Color equalsButtonColor = Color(0xffD89D61);
}

class Style {
  static TextStyle textStyle =
  GoogleFonts.basic(color: Palette.buttonTextColor);
  static TextStyle brandStyle = textStyle.copyWith(fontSize: 28);
  static TextStyle buttonTextStyle = textStyle.copyWith(fontSize: 28);
  static TextStyle modelStyle =
  textStyle.copyWith(color: Palette.calcModelColor, fontSize: 20);
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    primary: Palette.buttonColor,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 0),
    shadowColor: Colors.black,
    elevation: 3,
  );
  static ButtonStyle equalsButtonStyle = buttonStyle.copyWith(
      backgroundColor: MaterialStateColor.resolveWith(
              (states) => Palette.equalsButtonColor));
  static ButtonStyle equalsButtonActiveStyle = buttonStyle.copyWith(
      backgroundColor: MaterialStateColor.resolveWith(
              (states) => Palette.equalsButtonColor.withOpacity(0.5)));
  static TextStyle screenTextStyle = const TextStyle(
      fontSize: 28, fontFamily: "Segment", color: Palette.screenTextColor);
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final Random _rand = Random(DateTime
      .now()
      .millisecondsSinceEpoch);
  final stt.SpeechToText speech = stt.SpeechToText();
  final ScreenshotController _screenshotController = ScreenshotController();

  String _screenText = "TAP RECORD :)";
  bool _listening = false;
  Color _qrColor = Palette.screenTextColor;
  String _sentence = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    speech.initialize(onStatus: statusListener, onError: errorListener);
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void _recordButtonTapped() {
    if (!_listening) {
      _startRecord();
    }
  }

  void _stopButtonTapped() {
    if (_listening) {
      _stopRecord();
    }
  }

  void statusListener(String status) {
    setState(() {
      _listening = status == 'listening';
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

  Future<void> _startRecord() async {
    if (speech.isAvailable) {
      speech.listen(
          onResult: resultListener, pauseFor: const Duration(seconds: 10));
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

  // IMAGE CAPTURE (SAVE FEATURE)
  Future<void> _saveQR() async {
    await _screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory(); // path_provider plugin
        final imagePath = await File('${directory.path}/image.png').create(); // dart:io
        await imagePath.writeAsBytes(image);
        await Share.shareFiles([imagePath.path]); // share plugin
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
      backgroundColor: Palette.bodyColor,
      body: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // TITLE TEXT AREA
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
          ),
          // SCREEN AREA
          Container(
            decoration: const BoxDecoration(
                color: Palette.screenColor,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
                GestureDetector(
                  onTap: _tappedQR,
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
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: Style.buttonStyle,
                    onPressed: _saveQR,
                    child: Text("SAVE", style: Style.buttonTextStyle),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    style: _listening ? Style.equalsButtonActiveStyle : Style
                        .equalsButtonStyle,
                    onPressed: _recordButtonTapped,
                    onLongPress: _recordButtonTapped,
                    child: Text("RECORD", style: Style.buttonTextStyle),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: Style.buttonStyle,
                    onPressed: _stopButtonTapped,
                    child: Text("STOP", style: Style.buttonTextStyle),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
