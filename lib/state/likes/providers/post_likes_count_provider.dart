import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/post_id.dart';

final postLikesCountProvider = StreamProvider.family.autoDispose<int, PostId>(
  (
    ref,
    PostId postId,
  ) {
    final controller = StreamController<int>.broadcast();

    controller.onListen = () {
      controller.sink.add(0);
    };

    final stream = supabase
        .from(SupabaseCollectionName.likes)
        .stream(primaryKey: ['id'])
        .eq(SupabaseFieldName.postId, postId)
        .map((maps) {
          controller.sink.add(maps.length);
        });

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);
