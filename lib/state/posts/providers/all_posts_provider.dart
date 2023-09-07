import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/posts/models/post.dart';

final allPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final controller = StreamController<Iterable<Post>>();

    final stream = supabase
        .from(SupabaseCollectionName.posts)
        .stream(primaryKey: ['id']).map((maps) {
      final result = maps.map((map) => Post(postId: map['id'], json: map));
      controller.sink.add(result);
    });

    ref.onDispose(() {
      // TODO: do we need to cancel supabase streams?
      controller.close();
    });

    return controller.stream;
  },
);
