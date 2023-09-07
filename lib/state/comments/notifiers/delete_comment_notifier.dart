import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/comments/typedefs/comment_id.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/image_upload/typedefs/is_loading.dart';

class DeleteCommentStateNotifier extends StateNotifier<IsLoading> {
  DeleteCommentStateNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deleteComment({
    required CommentId commentId,
  }) async {
    try {
      isLoading = true;

      await supabase
          .from(SupabaseCollectionName.comments)
          .delete()
          .eq('id', commentId);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
