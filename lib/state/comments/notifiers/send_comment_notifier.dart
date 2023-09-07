import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/comments/models/comment_payload.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/image_upload/typedefs/is_loading.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

class SendCommentNotifier extends StateNotifier<IsLoading> {
  SendCommentNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> sendComment({
    required UserId fromUserId,
    required PostId onPostId,
    required String comment,
  }) async {
    isLoading = true;
    final payload = CommentPayload(
      fromUserId: fromUserId,
      onPostId: onPostId,
      comment: comment,
    );
    try {
      await supabase.from(SupabaseCollectionName.comments).insert(payload);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
