import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_auto_tele/config/config.dart';

class ImagesControl {
  final Map<String, int> currentSize = {'width': 402, 'height': 712};
  final Map<String, int> croppedSize = {'width': 390, 'height': 691};

  /// Kiểm tra xem file ảnh có tồn tại không và trả về đường dẫn ảnh nếu tồn tại.
  Future<String> existImagePath(int hwnd) async {
    final String imagePath = '$temporarySavePath/$hwnd.png';
    return await File(imagePath).exists() ? imagePath : 'Not found';
  }

  /// Cắt ảnh từ [imagePath] với phần cropOffset, trả về đường dẫn ảnh mới.
  Future<String> cropImage(String imagePath, int cropOffset,
      {bool isHome = true}) async {
    final String newPath = '${imagePath.split('.').first}_home.png';

    try {
      if (isHome && await File(newPath).exists()) return newPath;

      final img.Image? originalImage = await _loadImage(imagePath);
      if (originalImage == null) throw Exception("Could not decode image");

      final img.Image croppedImage = _performCrop(originalImage, cropOffset);

      // Lưu ảnh vào newPath nếu isHome là true, ngược lại trả về imagePath
      if (isHome) {
        await File(newPath).writeAsBytes(img.encodePng(croppedImage));
        print("Image cropped and saved to $newPath");
        return newPath;
      } else {
        await File(imagePath).writeAsBytes(img.encodePng(croppedImage));
        print("Image cropped and saved to original path: $imagePath");
        return imagePath;
      }
    } catch (e) {
      print('Error in cropImage: $e');
      return isHome ? newPath : imagePath;
    }
  }

  /// Lấy danh sách đường dẫn các ảnh theo `hwnd`.
  Future<List<String>> getImageListByHwnd(int hwnd) async {
    List<String> imagePathList = [];

    try {
      final Directory dir = Directory(temporarySavePath);
      if (await dir.exists()) {
        imagePathList = dir
            .listSync()
            .where((file) => file.path.contains(hwnd.toString()))
            .map((file) => file.path)
            .toList();
      }
    } catch (e) {
      print('Error in getImageListByHwnd: $e');
    }

    return imagePathList;
  }

  /// Đổi tên ảnh từ [defaultPath] với số đếm [count], trả về đường dẫn mới.
  Future<String> renameImage(int count, int hwnd) async {
    // Tạo đường dẫn file mới
    String defaultPath = '$temporarySavePath/$hwnd.png';
    final String newPath = '$temporarySavePath/${hwnd}_screen_$count.png';

    // Đảm bảo defaultPath là đường dẫn đầy đủ
    final File originalFile = File(defaultPath);
    try {
      // Kiểm tra xem file gốc có tồn tại hay không
      if (await originalFile.exists()) {
        print("Original file exists at $defaultPath");

        // Sao chép file sang newPath
        await originalFile.copy(newPath);
        print("File copied to $newPath");
      } else {
        print("Error: File not found at $defaultPath");
      }
    } catch (e) {
      print('Error in renameImage: $e');
    }

    return newPath;
  }

  /// Tải ảnh từ đường dẫn và trả về đối tượng `img.Image`.
  Future<img.Image?> _loadImage(String imagePath) async {
    try {
      return img.decodeImage(await File(imagePath).readAsBytes());
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  /// Cắt ảnh với [cropOffset] và trả về ảnh đã cắt.
  img.Image _performCrop(img.Image originalImage, int cropOffset) {
    final int cropWidth = originalImage.width - 2 * cropOffset;
    final int cropHeight = originalImage.height - 2 * cropOffset;

    if (cropWidth <= 0 || cropHeight <= 0) {
      throw Exception("Invalid crop dimensions.");
    }

    return img.copyCrop(originalImage,
        x: cropOffset, y: cropOffset, width: cropWidth, height: cropHeight);
  }

  Future<void> deleteImage(dynamic target) async {
    try {
      String path;
      if (target is int) {
        path = '$temporarySavePath/$target.png';
      } else if (target is String) {
        path = target;
      } else {
        throw ArgumentError('Target phải là int hoặc String.');
      }

      File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('deleteImage: $e');
    }
  }
}
