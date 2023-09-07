import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/posts/models/post.dart';
import 'package:testingriverpod/state/posts/typedefs/search_term.dart';

final postsBySearchTermProvider =
    StreamProvider.family.autoDispose<Iterable<Post>, SearchTerm>(
  (ref, SearchTerm searchTerm) {
    final controller = StreamController<Iterable<Post>>();

    final stream = supabase
        .from(SupabaseCollectionName.posts)
        .stream(primaryKey: ['id']).map((maps) {
      final result = maps.map((map) => Post(postId: map['id'], json: map));

      //TODO: Should be able to move this to the stream query as a greater than filter
      final posts = result.where((post) {
        return post.message.toLowerCase().contains(
              searchTerm.toLowerCase(),
            );
      });
      controller.sink.add(posts);
    });

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);
