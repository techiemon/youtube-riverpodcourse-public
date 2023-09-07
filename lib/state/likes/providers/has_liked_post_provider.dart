import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/auth/providers/user_id_provider.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';

final hasLikedPostProvider = StreamProvider.family.autoDispose<bool, PostId>(
  (
    ref,
    PostId postId,
  ) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return Stream<bool>.value(false);
    }

    final controller = StreamController<bool>();

    supabase
        .from(SupabaseCollectionName.likes)
        .select()
        .match({
          SupabaseFieldName.postId: postId,
          SupabaseFieldName.userId: userId
        })
        .single()
        .then((value) {
          if (value != null) {
            controller.add(true);
          } else {
            controller.add(false);
          }
        });

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);
