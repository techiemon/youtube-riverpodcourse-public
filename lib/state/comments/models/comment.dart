import 'package:flutter/foundation.dart' show immutable;
import 'package:testingriverpod/state/comments/typedefs/comment_id.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

@immutable
class Comment {
  final CommentId id;
  final String comment;
  final DateTime createdAt;
  final UserId fromUserId;
  final PostId onPostId;
  Comment(Map<String, dynamic> json, {required this.id})
      : comment = json[SupabaseFieldName.comment],
        createdAt = (json[SupabaseFieldName.createdAt] as Timestamp).toDate(),
        fromUserId = json[SupabaseFieldName.userId],
        onPostId = json[SupabaseFieldName.postId];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          comment == other.comment &&
          createdAt == other.createdAt &&
          fromUserId == other.fromUserId &&
          onPostId == other.onPostId;

  @override
  int get hashCode => Object.hashAll(
        [
          id,
          comment,
          createdAt,
          fromUserId,
          onPostId,
        ],
      );
}
