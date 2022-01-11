import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:engdatalogger/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "engdatalogger",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
          accentColor: Colors.white70
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  late SharedPreferences sharedPreferences;

  // Login Status check
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));  //after logout remove change to null
    }
  }

  // Function async download
  Future download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if(Platform.isAndroid){
        final baseStorage = await getExternalStorageDirectory();
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: baseStorage!.path,
          showNotification: true, // show download progress in status bar (for Android)
          openFileFromNotification: true, // click on notification to open downloaded file (for Android)
          saveInPublicStorage: true,
        );
      }
    }
  }

  // Function increment and reset _counter
  int date=07012021;
  int _counter = 0;
  void _incrementCounter() {
    _counter++;
    setState(() {
    });
  }
  void _resetCounter() {
    _counter=0;
    setState(() {
    });
  }

  ReceivePort _port = ReceivePort();
  @override
  void initState() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if(status == DownloadTaskStatus.complete){
        print("Download Complete !");
      } else if(status == DownloadTaskStatus.failed){
        print("Download Failed!");
      }
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
    checkLoginStatus();
  }

  // Function downloader callback
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  //Function main app
  @override
  Widget build(BuildContext context) {
    // var urk = 'http://192.168.1.28:8081/?filename=' + '$date' + 'datalog' + '$_counter' + '.txt';
    var urk = 'http://192.168.1.28:8081/?filename=datalog' + '$_counter' + '.txt';

    return Scaffold(
      appBar: AppBar(
        title: Text("engdatalogger", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _resetCounter();
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Download datalog!",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,)
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
          download(urk);
        },
        tooltip: 'Download',
        child: Icon(Icons.file_download, color: Colors.white,),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(),
    );
  }
}