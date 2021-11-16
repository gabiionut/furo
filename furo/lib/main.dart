import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromRGBO(0, 79, 67, 1),
          primary: const Color.fromRGBO(245, 230, 214, 1),
          secondaryVariant: const Color.fromRGBO(236, 133, 116, 1),
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _handleOnPressed() async {
    if (isPlaying) {
      _controller.reverse();
      audioPlayer!.pause();
    } else {
      _controller.forward();
      if (audioPlayer != null) {
        audioPlayer!.resume();
      } else {
        audioPlayer = await player.play('Peritune-Sakuya.mp3');
      }
    }

    setState(() {
      isPlaying = !isPlaying;
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
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
                shape: const CircleBorder(),
                minimumSize: const Size(200, 200),
              ),
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _controller,
                color: Theme.of(context).colorScheme.secondary,
                size: 150,
              ),
              onPressed: () => _handleOnPressed(),
            ),
          ),
          Column(children: const [
            SizedBox(height: 25),
          ]),
        ],
      ),
    );
  }
}
