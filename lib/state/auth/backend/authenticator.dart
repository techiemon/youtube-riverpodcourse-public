import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

class Authenticator {
  const Authenticator();

  // getters
  UserId? get userId => supabase.auth.currentUser?.id;
  bool get isAlreadyLoggedIn => userId != null;

  String get displayName =>
      'TODO authenticator.dart diplayName'; // TODO: currentUser?.displayName ?? '';
  String? get email => supabase.auth.currentUser?.email;

  Future<void> logOut() async {
    Supabase.instance.client.auth.signOut();
  }
}
