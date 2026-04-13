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
      home: HomePage(),
    );
  }
}

// ================= HOME IPTV =================
class HomePage extends StatelessWidget {
  final List<Map<String, String>> channels = [
    {
      "name": "Globo",
      "url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    },
    {
      "name": "ESPN",
      "url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    },
    {
      "name": "Discovery",
      "url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    },
    {
      "name": "Cartoon",
      "url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KAMA STREAMING'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.live_tv, size: 30),
              title: Text(channels[index]['name']!),
              trailing: Icon(Icons.play_arrow),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerPage(
                      url: channels[index]['url']!,
                      name: channels[index]['name']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ================= PLAYER =================
class PlayerPage extends StatefulWidget {
  final String url;
  final String name;

  PlayerPage({required this.url, required this.name});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.network(widget.url)
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
        title: Text(widget.name),
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
