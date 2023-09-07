import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? displayName,
    required String? email,
  }) : super(
          {
            SupabaseFieldName.userId: userId,
            SupabaseFieldName.displayName: displayName ?? '',
            SupabaseFieldName.email: email ?? '',
          },
        );
}
