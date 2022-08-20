import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:duration_picker/duration_picker.dart';
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
          secondaryContainer: const Color.fromRGBO(0, 79, 67, 1),
          primaryContainer: const Color.fromRGBO(245, 230, 214, 1),
          primary: Colors.black,
          secondary: const Color.fromRGBO(236, 133, 116, 1),
        ),
        buttonBarTheme: const ButtonBarThemeData(
          buttonTextTheme: ButtonTextTheme.accent,
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
  bool isMuted = false;
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
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Image.asset('assets/images/japan_$imageNr.png'),
    );
  }

  Future<void> _handleOnPressed() async {
    if (isPlaying) {
      _controller.reverse();
      audioPlayer!.pause();
      timer?.cancel();
    } else {
      if (audioPlayer != null) {
        _controller.forward();
        audioPlayer!.resume();
      } else {
        var resultingDuration = await showDurationPicker(
          context: context,
          initialTime: const Duration(minutes: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
        );

        if (resultingDuration == Duration.zero || resultingDuration == null) {
          return;
        }
        _controller.forward();
        audioPlayer = await player.play('Peritune-Sakuya.mp3');
        timer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => setState(() {
            if (_progress < 100) {
              _progress = _progress + (1 / (resultingDuration.inSeconds / 100));
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
      audioPlayer = null;
      _progress = 0;
    });
  }

  Future<void> _handleMutePressed() async {
    if (isMuted) {
      audioPlayer!.setVolume(1);
    } else {
      audioPlayer!.setVolume(0);
    }

    setState(() {
      isMuted = !isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.secondaryContainer,
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
                    trackColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    progressBarColor: Theme.of(context).colorScheme.secondary,
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
              if (audioPlayer != null)
                SizedBox(
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size(100, 50),
                        shape: const CircleBorder()),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          )
                        ]),
                    onPressed: () => _handleStopPressed(),
                  ),
                ),
              Flexible(
                child: SizedBox(
                  width: audioPlayer == null ? 250 : double.infinity,
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
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
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          size: 50,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'PLAY',
                          style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                        )
                      ],
                    ),
                    onPressed: () => _handleOnPressed(),
                  ),
                ),
              ),
              if (audioPlayer != null)
                SizedBox(
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        minimumSize: const Size(100, 50),
                        shape: const CircleBorder()),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isMuted ? Icons.volume_up : Icons.volume_off,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          )
                        ]),
                    onPressed: () => _handleMutePressed(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
