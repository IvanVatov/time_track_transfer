import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ResponseLog {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    final File file = File('$path/responses/$fileName.txt');
    if (!file.existsSync()) {
      file.create(recursive: true);
    }
    return file;
  }

  static Future<void> writeToFile(String fileName, String data) async {
    File file = await _getFile(fileName);

    file.writeAsString(data);
  }
}
