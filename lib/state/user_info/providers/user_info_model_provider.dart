import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';
import 'package:testingriverpod/state/user_info/models/user_info_model.dart';

final userInfoModelProvider =
    StreamProvider.family.autoDispose<UserInfoModel, UserId>(
  (ref, UserId userId) {
    final controller = StreamController<UserInfoModel>();

    final stream = supabase
        .from(SupabaseCollectionName.users)
        .stream(primaryKey: ['id'])
        .eq(SupabaseFieldName.userId, userId)
        .limit(1)
        .map((map) {
          final result = UserInfoModel(
            userId: map.first['id'],
            email: map.first['email'],
            displayName: map.first['display_name'],
          );
          controller.sink.add(result);
        });

    ref.onDispose(() {
      controller.close();
    });

    return controller.stream;
  },
);
