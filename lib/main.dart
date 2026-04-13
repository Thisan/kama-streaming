import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(KamaStreamingApp());
}

class KamaStreamingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KAMA STREAMING',
      theme: ThemeData.dark(),
      home: LoginPage(),
    );
  }
}

// ================= LOGIN =================
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final macController = TextEditingController();

  void login() {
    if (macController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerPage(mac: macController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('KAMA STREAMING', style: TextStyle(fontSize: 28)),
              SizedBox(height: 30),
              TextField(
                controller: macController,
                decoration: InputDecoration(
                  labelText: 'Digite seu MAC',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= PLAYER =================
class PlayerPage extends StatefulWidget {
  final String mac;

  PlayerPage({required this.mac});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? controller;

  final m3uUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';

  @override
  void initState() {
    super.initState();
    loadStream();
  }

  void loadStream() {
    controller = VideoPlayerController.network(m3uUrl)
      ..initialize().then((_) {
        setState(() {});
        controller!.play();
      });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KAMA STREAMING'),
      ),
      body: Center(
        child: controller != null && controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
