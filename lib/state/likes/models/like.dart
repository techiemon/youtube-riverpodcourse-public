import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

@immutable
class Like extends MapView<String, String> {
  Like({
    required PostId postId,
    required UserId likedBy,
    required DateTime date,
  }) : super(
          {
            SupabaseFieldName.postId: postId,
            SupabaseFieldName.userId: likedBy,
            SupabaseFieldName.date: date.toIso8601String(),
          },
        );
}
