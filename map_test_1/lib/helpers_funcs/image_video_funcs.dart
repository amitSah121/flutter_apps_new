import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:http/http.dart' as http;
import 'package:map_test_1/helpers_funcs/file_funcs_user_dir.dart';
import 'package:video_compress/video_compress.dart';
import 'dart:ui' as ui;

Future<double> getImageAspectRatio(String imagePath) async {
  try {
    // Load the image file as bytes
    final file = await getFile(imagePath);
    if (!await file.exists()) {
      // throw Exception("File not found at $imagePath");
      return 1.0;
    }
    final bytes = await file.readAsBytes();

    // Decode the image using dart:ui
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Calculate the aspect ratio
    return image.width / image.height;
  } catch (e) {
    print("Error getting aspect ratio: $e");
    return 1.0; // Return null if there is an error
  }
}

Future<String> captureImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  if(image == null) return "none";
  final targetPath = "${await localPath}/media/images/live_${image.path.split("/").last}";

  final Directory userPicturesDir = await getUserDirectory(dir:"images");
  final String userImagePath = "${userPicturesDir.path}/${image.path.split("/").last}";
  // print(userImagePath);
  try{

    final File originalImage = File(image.path);
    await originalImage.copy(userImagePath); // copy image to user dir

    var compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 60, // Adjust compression quality (0-100)
    );

    if (compressedImage != null) {
      return compressedImage.path ?? "none";
    } else {
      return "none";
    }
  }catch(e){
    return "none";
  }

}

Future<String> captureVideo() async {
  final ImagePicker picker = ImagePicker();

  final XFile? video = await picker.pickVideo(source: ImageSource.camera);
  if (video == null) return "none";

  final targetPath = "${await localPath}/media/videos/live_${video.path.split("/").last}";

  final Directory userPicturesDir = await getUserDirectory(dir:"videos");
  final String userVideoPath = "${userPicturesDir.path}/${video.path.split("/").last}";

  try {

    final File originalVideo = File(video.path);
    await originalVideo.copy(userVideoPath); // copy image to user dir

    MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality, // Adjust quality level
      deleteOrigin: false, 
    );

    if (compressedVideo != null && compressedVideo.path != null) {
      final compressedFile = File(compressedVideo.path!);
      await getFile(targetPath);

      // Copy the compressed file to the target location
      await compressedFile.copy(targetPath);

      return targetPath;
    } else {
      return "none";
    }
  } catch (e) {
    print("Video compression error: $e");
    return "none";
  }
}


Future<String> compressImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if(image == null) return "none";
  final targetPath = "${await localPath}/media/images/${image.path.split("/").last}";

  try{
    var compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 60, // Adjust compression quality (0-100)
    );

    if (compressedImage != null) {
      return compressedImage.path ?? "none";
    } else {
      return "none";
    }
  }catch(e){
    return "none";
  }

  // return targetPath;
}

Future<String> compressVideo() async {
  final ImagePicker picker = ImagePicker();

  final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
  if (video == null) return "none";

  final targetPath = "${await localPath}/media/videos/${video.path.split("/").last}";

  try {
    MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality, // Adjust quality level
      deleteOrigin: false, 
    );

    if (compressedVideo != null && compressedVideo.path != null) {
      final compressedFile = File(compressedVideo.path!);
      await getFile(targetPath);

      // Copy the compressed file to the target location
      await compressedFile.copy(targetPath);

      return targetPath;
    } else {
      return "none";
    }
  } catch (e) {
    print("Video compression error: $e");
    return "none";
  }
}

Future<String?> getMimeType(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    if (response.headers.containsKey('content-type')) {
      return response.headers['content-type'];
    }
  } catch (e) {
    print('Error fetching MIME type: $e');
  }
  return null;
}

Future<bool> isFileImage(String url) async {
  final mimeType = await getMimeType(url);
  return mimeType != null && mimeType.startsWith('image/');
}

Future<bool> isFileVideo(String url) async {
  final mimeType = await getMimeType(url);
  return mimeType != null && mimeType.startsWith('video/');
}

bool isImageUrl(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  final extension = url.split('.').last.toLowerCase();
  return imageExtensions.contains(extension);
}

bool isVideoUrl(String url) {
  final videoExtensions = ['mp4', 'mov', 'avi', 'wmv', 'flv', 'mkv'];
  final extension = url.split('.').last.toLowerCase();
  return videoExtensions.contains(extension);
}


Future<String> checkUrlType(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    
    // Check if the URL is valid and accessible
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      
      if (contentType != null) {
        if (contentType.startsWith('image/')) {
          return 'Valid Image';
        } else if (contentType.startsWith('video/')) {
          return 'Valid Video';
        } else {
          return 'Valid URL but not an image or video';
        }
      }
    }
    return 'Invalid or Inaccessible URL';
  } catch (e) {
    return 'Error: $e';
  }
}

/// Combined check: file extension and MIME type validation.
Future<String> validateUrl(String url) async {
  // Quick extension check
  if (isImageUrl(url)) {
    return 'Possibly an Image (extension)';
  } else if (isVideoUrl(url)) {
    return 'Possibly a Video (extension)';
  }

  // MIME type validation
  return await checkUrlType(url);
}