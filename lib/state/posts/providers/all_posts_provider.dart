import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/posts/models/post.dart';

final allPostsProvider = StreamProvider.autoDispose<Iterable<Post>>(
  (ref) {
    final controller = StreamController<Iterable<Post>>();

    supabase.from(SupabaseCollectionName.posts).stream(
        primaryKey: ['post_id']).listen((List<Map<String, dynamic>> data) {
      final result = data.map((e) => Post(postId: e['post_id'], json: e));
      // final result = maps.map((map) => Post(postId: map['post_id'], json: map));
      controller.sink.add(result);
    });

    ref.onDispose(() {
      // TODO: do we need to cancel supabase streams?
      controller.close();
    });

    return controller.stream;
  },
);
