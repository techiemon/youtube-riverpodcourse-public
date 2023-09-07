import 'dart:io' show File;
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<bool> upload({
    required File file,
    required FileType fileType,
    required String message,
    required Map<PostSetting, bool> postSettings,
    required String userId,
  }) async {
    isLoading = true;

    late Uint8List thumbnailUint8List;

    switch (fileType) {
      case FileType.image:
        // create a thumbnail out of the file
        final fileAsImage = img.decodeImage(file.readAsBytesSync());
        if (fileAsImage == null) {
          isLoading = false;
          return false;
        }
        // create thumbnail
        final thumbnail = img.copyResize(
          fileAsImage,
          width: Constants.imageThumbnailWidth,
        );
        final thumbnailData = img.encodeJpg(thumbnail);
        thumbnailUint8List = Uint8List.fromList(thumbnailData);
        break;
      case FileType.video:
        final thumb = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: Constants.videoThumbnailMaxHeight,
          quality: Constants.videoThumbnailQuality,
        );
        if (thumb == null) {
          isLoading = false;
          throw const CouldNotBuildThumbnailException();
        } else {
          thumbnailUint8List = thumb;
        }
        break;
    }

    // calculate the aspect ratio

    final thumbnailAspectRatio = await thumbnailUint8List.getAspectRatio();

    // calculate references

    final fileName = const Uuid().v4();

    try {
      final String thumbnailRef = await supabase.storage
          .from(SupabaseCollectionName.thumbnails)
          .upload(
            SupabaseCollectionName.thumbnails,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String originalFileRef = await supabase.storage
          .from(fileType.collectionName)
          .upload(
            SupabaseCollectionName.thumbnails,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

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
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
