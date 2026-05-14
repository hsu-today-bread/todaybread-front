import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todaybread/services/network/api_exception.dart';

class MultipartImageHelper {
  MultipartImageHelper._();

  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const Set<String> allowedMimeTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/jpg',
    'image/gif',
  };

  static Future<MultipartFile> fromXFile(XFile image) async {
    final file = File(image.path);
    final size = await file.length();
    if (size > maxFileSizeBytes) {
      throw ApiException(message: '이미지는 1장당 최대 5MB까지 등록할 수 있습니다.');
    }

    final contentType = _contentTypeOf(image);
    if (contentType == null) {
      throw ApiException(
        message: '지원하지 않는 이미지 형식입니다. JPG, PNG, WEBP, GIF 파일을 선택해주세요.',
      );
    }

    return MultipartFile.fromFile(
      image.path,
      filename: _filenameOf(image),
      contentType: contentType,
    );
  }

  static MediaType? _contentTypeOf(XFile image) {
    final mimeType = image.mimeType?.toLowerCase();
    if (mimeType != null && allowedMimeTypes.contains(mimeType)) {
      return MediaType.parse(mimeType == 'image/jpg' ? 'image/jpeg' : mimeType);
    }

    final name = _filenameOf(image).toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (name.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (name.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (name.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    return null;
  }

  static String _filenameOf(XFile image) {
    if (image.name.isNotEmpty) {
      return image.name;
    }
    return image.path.split(Platform.pathSeparator).last;
  }
}
