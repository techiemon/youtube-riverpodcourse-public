import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:testingriverpod/constants.dart';
import 'package:testingriverpod/state/auth/providers/auth_state_provider.dart';
import 'package:testingriverpod/views/constants/strings.dart';
import 'package:testingriverpod/views/login/divider_with_margins.dart';
import 'package:testingriverpod/views/login/login_view_signup_links.dart';

class LoginView extends ConsumerWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          Strings.appName,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              spacer,
              // header text
              Text(
                Strings.welcomeToAppName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const DividerWithMargins(),
              Text(
                Strings.logIntoYourAccount,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(height: 1.5),
              ),
              spacer,
              SupaSocialsAuth(
                colored: true,
                socialProviders: const [
                  SocialProviders.facebook,
                  SocialProviders.google,
                ],
                onSuccess: (session) {
                  ref.read(authStateProvider.notifier).setSession(session);
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (route) => false);
                },
                redirectUrl: kIsWeb
                    ? null
                    : 'io.supabase.youtube-supabase-riverpodcourse-public://login-callback',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      fixedSize: const Size(100, 50)),
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, '/magic_link');
                  },
                  label: const Text('Sign in with Email Link'),
                ),
              ),
              const DividerWithMargins(),
              const LoginViewSignupLinks(),
            ],
          ),
        ),
      ),
    );
  }
}
