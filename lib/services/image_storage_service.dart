import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  Future<String> saveImage(File source, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(p.join(directory.path, 'geodiario_images'));
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final extension = p.extension(source.path).isEmpty
        ? '.jpg'
        : p.extension(source.path);
    final destination = File(p.join(imagesDirectory.path, '$id$extension'));
    await source.copy(destination.path);
    return destination.path;
  }

  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
