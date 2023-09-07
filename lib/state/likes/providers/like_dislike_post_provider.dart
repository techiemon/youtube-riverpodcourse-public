import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/likes/models/like.dart';
import 'package:testingriverpod/state/likes/models/like_dislike_request.dart';

part 'like_dislike_post_provider.g.dart';

@riverpod
Future<bool> likeDislikePost(
  LikeDislikePostRef ref, {
  required LikeDislikeRequest request,
}) async {
  final likeData =
      await supabase.from(SupabaseCollectionName.likes).select().match({
    SupabaseFieldName.postId: request.postId,
    SupabaseFieldName.userId: request.likedBy
  }).single();

  final hasLiked = likeData != null;

  if (hasLiked) {
    // delete the like
    try {
      await supabase.from(SupabaseCollectionName.likes).delete().match({
        SupabaseFieldName.postId: request.postId,
        SupabaseFieldName.userId: request.likedBy
      });

      return true;
    } catch (_) {
      return false;
    }
  } else {
    // post a Like object
    final like = Like(
      postId: request.postId,
      likedBy: request.likedBy,
      date: DateTime.now(),
    );

    try {
      await supabase.from(SupabaseCollectionName.likes).insert(like);

      return true;
    } catch (_) {
      return false;
    }
  }
}
