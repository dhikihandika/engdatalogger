import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';

void main() async {
  // final FTPConnect _ftpConnect = new FTPConnect("speedtest.tele2.net",
  //     user: "anonymous", pass: "anonymous", debug: true);
  final FTPConnect _ftpConnect = new FTPConnect("ftp://192.168.1.28/", debug: true);

  ///an auxiliary function that manage showed log to UI
  Future<void> _log(String log) async {
    print(log);
    await Future.delayed(Duration(seconds: 1));
  }

  ///mock a file for the demonstration example
  Future<File> _fileMock({fileName = 'FlutterTest.txt', content = ''}) async {
    final Directory directory = Directory('/test')..createSync(recursive: true);
    final File file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  Future<void> _downloadStepByStep() async {
    try {
      await _log('Connecting to FTP ...');
      await _ftpConnect.connect();
      await _log('Downloading ...');
      String fileName = '../512KB.zip';

      //here we just prepare a file as a path for the downloaded file
      File downloadedFile = await _fileMock(fileName: 'downloadStepByStep.txt');
      await _ftpConnect.downloadFile(fileName, downloadedFile);
      await _log('file downloaded path: ${downloadedFile.path}');
      await _ftpConnect.disconnect();
    } catch (e) {
      await _log('Downloading FAILED: ${e.toString()}');
    }
  }

  await _downloadStepByStep();
}