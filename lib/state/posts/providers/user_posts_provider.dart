import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/auth/providers/user_id_provider.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/models/post.dart';

final userPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final userId = ref.watch(userIdProvider);

    final controller = StreamController<Iterable<Post>>();

    controller.onListen = () {
      controller.sink.add([]);
    };

    final stream = supabase
        .from(SupabaseCollectionName.posts)
        .stream(primaryKey: ['id'])
        .eq(SupabaseFieldName.userId, userId)
        .map((maps) {
          final posts = maps.map((map) => Post(postId: map['id'], json: map));
          controller.sink.add(posts);
        });

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);
