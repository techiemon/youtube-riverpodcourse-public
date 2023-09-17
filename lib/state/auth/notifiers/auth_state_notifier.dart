import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testingriverpod/state/auth/backend/authenticator.dart';
import 'package:testingriverpod/state/auth/models/auth_result.dart';
import 'package:testingriverpod/state/auth/models/auth_state.dart';
import 'package:testingriverpod/state/posts/typedefs/user_id.dart';
import 'package:testingriverpod/state/user_info/backend/user_info_storage.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = const Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  AuthStateNotifier() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> setSession(session) async {
    state = state.copiedWithIsLoading(true);

    final userId = session?.user?.id;
    if (userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      result: AuthResult.success,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> saveUserInfo({
    required UserId userId,
  }) =>
      _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
      );
}
