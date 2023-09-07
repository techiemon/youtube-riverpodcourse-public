import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/comments/models/comment.dart';
import 'package:testingriverpod/state/comments/models/post_comments_request.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';

final postCommentsProvider = StreamProvider.family
    .autoDispose<Iterable<Comment>, RequestForPostAndComments>((
  ref,
  RequestForPostAndComments request,
) {
  final controller = StreamController<Iterable<Comment>>();

  final stream = supabase
      .from(SupabaseCollectionName.comments)
      .stream(primaryKey: ['id'])
      .eq(SupabaseFieldName.postId, request.postId)
      .map((maps) {
        final result = maps.map((map) => Comment(id: map['id'], map));
        controller.sink.add(result);
      });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
