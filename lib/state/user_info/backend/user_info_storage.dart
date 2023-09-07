import 'package:flutter/foundation.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/constants/supabase_collection_name.dart';
import 'package:testingriverpod/state/constants/supabase_field_name.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';
import 'package:testingriverpod/state/user_info/models/user_info_payload.dart';

@immutable
class UserInfoStorage {
  const UserInfoStorage();
  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      // first check if we have this user's info from before
      final userInfo = await supabase
          .from(
            SupabaseCollectionName.users,
          )
          .select()
          .match({
        SupabaseFieldName.userId: userId,
      }).single();

      if (userInfo != null) {
        // we already have this user's profile, save the new data instead
        await supabase.from(SupabaseCollectionName.users).update({
          SupabaseFieldName.displayName: displayName,
          SupabaseFieldName.email: email ?? '',
        }).match({
          SupabaseFieldName.userId: userId,
        });
        return true;
      }

      final payload = UserInfoPayload(
        userId: userId,
        displayName: displayName,
        email: email,
      );
      await supabase
          .from(
            SupabaseCollectionName.users,
          )
          .insert(payload);
      return true;
    } catch (_) {
      return false;
    }
  }
}
