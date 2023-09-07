import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';

@immutable
class CommentPayload extends MapView<String, dynamic> {
  CommentPayload({
    required String fromUserId,
    required String onPostId,
    required String comment,
  }) : super(
          {
            SupabaseFieldName.userId: fromUserId,
            SupabaseFieldName.postId: onPostId,
            SupabaseFieldName.comment: comment,
            SupabaseFieldName.createdAt: DateTime.now().toIso8601String(),
          },
        );
}
