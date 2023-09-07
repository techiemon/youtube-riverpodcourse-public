import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/comments/extensions/comment_sorting_by_request.dart';
import 'package:testingriverpod/state/comments/models/comment.dart';
import 'package:testingriverpod/state/comments/models/post_comments_request.dart';
import 'package:testingriverpod/state/comments/models/post_with_comments.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/models/post.dart';

final specificPostWithCommentsProvider = StreamProvider.family
    .autoDispose<PostWithComments, RequestForPostAndComments>((
  ref,
  RequestForPostAndComments request,
) {
  final controller = StreamController<PostWithComments>();

  Post? post;
  Iterable<Comment>? comments;

  void notify() {
    final localPost = post;
    if (localPost == null) {
      return;
    }

    final outputComments = (comments ?? []).applySortingFrom(request);

    final result = PostWithComments(
      post: localPost,
      comments: outputComments,
    );
    controller.sink.add(result);
  }

  // watch changes to the post
  final postsQuery = supabase
      .from(SupabaseCollectionName.posts)
      .stream(primaryKey: ['id'])
      .eq(SupabaseFieldName.id, request.postId)
      .limit(1)
      .map((map) {
        if (map.first['id'] == null) {
          post = null;
          comments = null;
          notify();
          return;
        }
        post = Post(
          postId: map.first['id'],
          json: map.first,
        );
        notify();
      });

  // watch changes to the comments
  final stream = supabase
      .from(SupabaseCollectionName.comments)
      .stream(primaryKey: ['id'])
      .eq(SupabaseFieldName.postId, request.postId)
      .order(SupabaseFieldName.createdAt, ascending: false)
      .limit(request.limit ?? 1000)
      .map((maps) {
        comments = maps.map((map) => Comment(id: map['id'], map));
        notify();
      });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
