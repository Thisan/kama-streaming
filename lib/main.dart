import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> channels = [];
  TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedUrl();
  }

  // 🔥 CARREGAR URL SALVA
  Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedUrl = prefs.getString('m3u_url');

    if (savedUrl != null) {
      urlController.text = savedUrl;
      loadM3U();
    }
  }

  // 🔥 SALVAR URL
  Future<void> saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('m3u_url', url);
  }

  // 🔥 CARREGAR M3U
  Future<void> loadM3U() async {
    await saveUrl(urlController.text);

    final response = await http.get(Uri.parse(urlController.text));

    if (response.statusCode == 200) {
      final lines = LineSplitter.split(response.body).toList();

      List<Map<String, String>> temp = [];

      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('#EXTINF')) {
          String name = lines[i].split(',').last;
          String url = lines[i + 1];

          temp.add({"name": name, "url": url});
        }
      }

      setState(() {
        channels = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KAMA STREAMING'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'Cole a URL M3U',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: loadM3U,
                  child: Text('Carregar Lista'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(channels[index]['name']!),
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
                );
              },
            ),
          ),
        ],
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
