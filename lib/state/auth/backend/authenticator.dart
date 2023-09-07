import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as go_true;
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/auth/models/auth_result.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';

class Authenticator {
  const Authenticator();

  // getters

  bool get isAlreadyLoggedIn => userId != null;
  UserId? get userId => supabase.auth.currentUser?.id;
  String get displayName =>
      'TODO authenticator.dart diplayName'; // TODO: currentUser?.displayName ?? '';
  String? get email => supabase.auth.currentUser?.email;

  Future<void> logOut() async {
    await supabase.auth.signOut();
  }

  Future<AuthResult> loginWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(go_true.Provider.facebook)
          as Future<AuthResponse>;
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(go_true.Provider.google)
          as Future<AuthResponse>;
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}

class FacebookAuthProvider {
  static credential(String token) {
    // TODO: is this even needed?
  }
}

class GoogleAuthProvider {
  static credential(String token, {String? idToken, String? accessToken}) {
    // TODO: is this even needed?
  }
}
