import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/image_upload/constants/constants.dart';
import 'package:testingriverpod/state/image_upload/exceptions/could_not_build_thumbnail_exception.dart';
import 'package:testingriverpod/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:testingriverpod/state/image_upload/extensions/get_image_data_aspect_ratio.dart';
import 'package:testingriverpod/state/image_upload/models/file_type.dart';
import 'package:testingriverpod/state/image_upload/typedefs/is_loading.dart';
import 'package:testingriverpod/state/post_settings/models/post_setting.dart';
import 'package:testingriverpod/state/posts/models/post_payload.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageUploadNotifier extends StateNotifier<IsLoading> {
  ImageUploadNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<File> saveImageToTemp(Uint8List imageData, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName.jpg').create();
    await file.writeAsBytes(imageData);
    return file;
  }

  Future<bool> upload({
    required File file,
    required FileType fileType,
    required String message,
    required Map<PostSetting, bool> postSettings,
    required String userId,
  }) async {
    isLoading = true;

    late Uint8List thumbnailUint8List;
    late img.Image thumbnailImage;
    late File thumbnailFile;

    final fileName = const Uuid().v4();
    final fileExtension = file.path.split('/').last.split('.').last;

    switch (fileType) {
      case FileType.image:
        final contents = file.readAsBytesSync();
        // create a thumbnail out of the file
        final fileAsImage = img.decodeImage(contents);

        if (fileAsImage == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        }

        // create thumbnail
        thumbnailImage = img.copyResize(
          fileAsImage,
          width: Constants.imageThumbnailWidth,
        );

        final imageUint8List = img.encodeJpg(thumbnailImage);
        // Create a temporary file to save the thumbnail
        thumbnailFile = await saveImageToTemp(imageUint8List, 'thumbnail');
        thumbnailUint8List = Uint8List.fromList(imageUint8List);
        break;
      case FileType.video:
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: Constants.videoThumbnailMaxHeight,
          quality: Constants.videoThumbnailQuality,
        );
        if (thumbnailPath == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        }

        thumbnailFile = File(thumbnailPath);

        thumbnailUint8List =
            Uint8List.fromList(thumbnailFile.readAsBytesSync());
        thumbnailImage = (img.decodeImage(thumbnailUint8List) ??
            img.Image(width: 0, height: 0));

        break;
    }

    if (thumbnailImage.height == 0 || thumbnailImage.width == 0) {
      isLoading = false;
      throw const CouldNotBuildThumbnailException();
    }

    // calculate the aspect ratio
    final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

    try {
      final String thumbnailRef = await supabase.storage
          .from(SupabaseCollectionName.thumbnails)
          .upload(
            '$fileName.$fileExtension',
            thumbnailFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String originalFileRef = await supabase.storage
          .from(fileType.collectionName)
          .upload(
            '$fileName.$fileExtension',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // delete the thumbnail file
      thumbnailFile.delete();

      // upload the post itself
      final postPayload = PostPayload(
        userId: userId,
        message: message,
        thumbnailUrl: thumbnailRef,
        fileUrl: originalFileRef,
        fileType: fileType,
        fileName: fileName,
        aspectRatio: thumbnailAspectRatio,
        postSettings: postSettings,
        thumbnailStorageId: SupabaseCollectionName
            .thumbnails, // TODO: probably don't need this with supabase
        originalFileStorageId: fileType
            .collectionName, // TODO: probably don't need this with supabase
      );
      await supabase.from(SupabaseCollectionName.posts).insert(postPayload);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    } finally {
      isLoading = false;
    }
  }
}
