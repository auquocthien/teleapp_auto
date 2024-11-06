import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_auto_tele/config/config.dart';

class ImagesControl {
  final Map<String, int> currentSize = {'width': 402, 'height': 712};
  final Map<String, int> cropedSize = {'width': 390, 'height': 691};

  Future<String> existImagePath(int hwnd) async {
    String imagePath = '$temporarySavePath/$hwnd.png';
    File file = File(imagePath);

    if (await file.exists()) {
      return imagePath;
    } else {
      return 'Not found';
    }
  }

  Future<String> cropImage(String imagePath, int cropOffset) async {
    String newPath = '${imagePath.split('.').first}_home.png';

    try {
      if (await File(newPath).exists()) {
        return newPath;
      }

      final File imageFile = File(imagePath);
      final img.Image? originalImage =
          img.decodeImage(await imageFile.readAsBytes());

      if (originalImage == null) {
        print("Could not decode image");
      }

      int cropX = cropOffset;
      int cropY = cropOffset;
      int cropWidth = originalImage!.width - 2 * cropOffset;
      int cropHeight = originalImage.height - 2 * cropOffset;

      // Kiểm tra tính hợp lệ của vùng cắt
      if (cropWidth <= 0 || cropHeight <= 0) {
        print("Invalid crop dimensions.");
      }

      img.Image croppedImage = img.copyCrop(originalImage,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      final File outputFile = File(newPath);
      await outputFile.writeAsBytes(img.encodePng(croppedImage));

      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      print("Image cropped and saved to $newPath");

      return newPath;
    } catch (e) {
      print('images control: $e');
      return newPath;
    }
  }
}
