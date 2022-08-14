import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furō',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromRGBO(0, 79, 67, 1),
          primary: const Color.fromRGBO(245, 230, 214, 1),
          secondaryContainer: const Color.fromRGBO(236, 133, 116, 1),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool isPlaying = false;
  AudioPlayer? audioPlayer;
  AudioCache player = AudioCache(prefix: 'assets/');
  double _progress = 0;
  Timer? timer;
  int? imageNr;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );
    setState(() {
      imageNr = Random().nextInt(9);
    });
  }

  Widget innerWidget(double val) {
    return Image.asset('assets/images/japan_$imageNr.png');
  }

  Future<void> _handleOnPressed() async {
    if (isPlaying) {
      _controller.reverse();
      audioPlayer!.pause();
      timer?.cancel();
    } else {
      _controller.forward();
      if (audioPlayer != null) {
        audioPlayer!.resume();
      } else {
        audioPlayer = await player.play('Peritune-Sakuya.mp3');
        timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => setState(() {
            if (_progress < 100) {
              _progress = _progress + 1;
            }
          }),
        );
      }
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  Future<void> _handleStopPressed() async {
    if (isPlaying) {
      _controller.reverse();
      audioPlayer!.stop();
      timer?.cancel();
    }

    setState(() {
      isPlaying = false;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        title: const Text(
          "Furō",
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: double.infinity,
            child: SleekCircularSlider(
              initialValue: _progress,
              innerWidget: innerWidget,
              appearance: CircularSliderAppearance(
                  size: 300,
                  startAngle: -90,
                  angleRange: 360,
                  customColors: CustomSliderColors(
                    trackColor: Theme.of(context).colorScheme.secondary,
                    progressBarColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    dynamicGradient: false,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle: const TextStyle(fontSize: 0),
                  ),
                  customWidths: CustomSliderWidths(
                      handlerSize: 0,
                      progressBarWidth: 8,
                      shadowWidth: 0,
                      trackWidth: 2)),
            ),
          ),
          Column(children: const [
            Text(
              "Peritune",
              style: TextStyle(fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Sakuya"),
            )
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPlaying)
                SizedBox(
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        minimumSize: const Size(100, 50),
                        shape: const CircleBorder()),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [Icon(Icons.stop)]),
                    onPressed: () => _handleStopPressed(),
                  ),
                ),
              SizedBox(
                width: 250,
                height: 60,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    minimumSize: const Size(100, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _controller,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 50,
                      ),
                      SizedBox(width: 5),
                      const Text(
                        'PLAY',
                        style: TextStyle(fontSize: 25),
                      )
                    ],
                  ),
                  onPressed: () => _handleOnPressed(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
