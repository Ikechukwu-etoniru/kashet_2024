import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class CloudinaryHelper {
  static const _folder = 'kasheto';
  static final cloudinary = Cloudinary(
      '633481269226496', '5TCgN26fHgfDPuehbjTuNN43b2U', 'ictnetworld');

  static Future<CloudinaryResponse> sendImage(
      {required String filePath, required String fileName}) async {
    final response = await cloudinary.uploadFile(
      filePath: filePath,
      resourceType: CloudinaryResourceType.image,
      folder: _folder,
      fileName: fileName,
    );
    return response;
  }
}
