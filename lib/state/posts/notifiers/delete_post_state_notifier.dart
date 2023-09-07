import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:testingriverpod/state/image_upload/typedefs/is_loading.dart';
import 'package:testingriverpod/state/posts/models/post.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';

class DeletePostStateNotifier extends StateNotifier<IsLoading> {
  DeletePostStateNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deletePost({
    required Post post,
  }) async {
    try {
      isLoading = true;

      // delete the post's thumbnail
      await supabase.storage.from(SupabaseCollectionName.thumbnails).remove([
        '${post.userId}/${post.thumbnailStorageId}',
      ]);

      // delete the post's original file (video or image)
      await supabase.storage.from(post.fileType.collectionName).remove([
        '${post.userId}/${post.originalFileStorageId}',
      ]);

      // delete all comments associated with this post

      await _deleteAllDocuments(
        inCollection: SupabaseCollectionName.comments,
        postId: post.postId,
      );

      // delete all likes associated with this post

      await _deleteAllDocuments(
        inCollection: SupabaseCollectionName.likes,
        postId: post.postId,
      );

      // finally delete the post itself
      await supabase.from(SupabaseCollectionName.posts).delete().match({
        SupabaseFieldName.id: post.postId,
      });

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _deleteAllDocuments({
    required PostId postId,
    required String inCollection,
  }) {
    return supabase.from(inCollection).delete().match({
      SupabaseFieldName.postId: postId,
    });

    // TODO: delete all comments associated with this post
    // TODO: delete all likes files etc associated with this post
  }
}
