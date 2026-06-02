import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'http_client.dart';
import 'api_config.dart';

/// 图片上传服务
/// 支持相册选择、拍照、多图上传
class ImageUploadService {
  ImageUploadService._();
  static final ImageUploadService instance = ImageUploadService._();

  final ImagePicker _picker = ImagePicker();
  final HttpClient _httpClient = HttpClient.instance;

  /// 从相册选择图片
  Future<SelectedImage?> pickFromGallery({
    int maxWidth = 1024,
    int maxHeight = 1024,
    double imageQuality = 0.9,
  }) async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: (imageQuality * 100).toInt(),
      );

      if (xFile == null) return null;

      return SelectedImage(
        path: xFile.path,
        name: xFile.name,
        size: await File(xFile.path).length(),
      );
    } catch (e) {
      print('[ImageUpload] 选择图片失败: $e');
      return null;
    }
  }

  /// 拍照
  Future<SelectedImage?> takePhoto({
    int maxWidth = 1024,
    int maxHeight = 1024,
    double imageQuality = 0.9,
  }) async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: (imageQuality * 100).toInt(),
      );

      if (xFile == null) return null;

      return SelectedImage(
        path: xFile.path,
        name: xFile.name,
        size: await File(xFile.path).length(),
      );
    } catch (e) {
      print('[ImageUpload] 拍照失败: $e');
      return null;
    }
  }

  /// 选择多张图片
  Future<List<SelectedImage>> pickMultipleFromGallery({
    int maxCount = 9,
    int maxWidth = 1024,
    int maxHeight = 1024,
    double imageQuality = 0.9,
  }) async {
    try {
      final xFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: (imageQuality * 100).toInt(),
      );

      final images = <SelectedImage>[];
      for (final xFile in xFiles.take(maxCount)) {
        images.add(SelectedImage(
          path: xFile.path,
          name: xFile.name,
          size: await File(xFile.path).length(),
        ));
      }

      return images;
    } catch (e) {
      print('[ImageUpload] 选择多图失败: $e');
      return [];
    }
  }

  /// 上传图片到 CDN
  Future<UploadResult> uploadImage({
    required String filePath,
    String uploadType = 'design_reference',
  }) async {
    try {
      final response = await _httpClient.upload(
        '/upload',
        baseUrl: ApiConfig.cdnBaseUrl,
        filePath: filePath,
        extraFields: {
          'upload_type': uploadType,
          'client': 'ai_nails_app',
        },
      );

      if (response.isSuccess && response.dataAsMap.isNotEmpty) {
        return UploadResult(
          success: true,
          url: response.dataAsMap['url'] as String? ?? '',
          thumbnailUrl: response.dataAsMap['thumbnail_url'] as String?,
        );
      }
    } catch (e) {
      print('[ImageUpload] 上传失败: $e');
    }

    // 上传失败返回本地路径
    return UploadResult(
      success: false,
      url: filePath,
      errorMessage: '上传失败，使用本地文件',
    );
  }

  /// 批量上传
  Future<List<UploadResult>> uploadMultiple({
    required List<String> filePaths,
    String uploadType = 'community_post',
  }) async {
    final results = <UploadResult>[];
    for (final path in filePaths) {
      final result = await uploadImage(
        filePath: path,
        uploadType: uploadType,
      );
      results.add(result);
    }
    return results;
  }
}

/// 选择的图片
class SelectedImage {
  final String path;
  final String name;
  final int size;

  const SelectedImage({
    required this.path,
    required this.name,
    required this.size,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// 上传结果
class UploadResult {
  final bool success;
  final String url;
  final String? thumbnailUrl;
  final String? errorMessage;

  const UploadResult({
    required this.success,
    required this.url,
    this.thumbnailUrl,
    this.errorMessage,
  });
}
