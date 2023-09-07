import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:testingriverpod/state/auth/providers/is_logged_in_provider.dart';

import 'state/providers/is_loading_provider.dart';
import 'views/components/loading/loading_screen.dart';
import 'views/login/login_view.dart';
import 'views/main/main_view.dart';

class EnvironmentConfig {
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANNON_KEY',
      defaultValue: 'SUPABASE_ANNON_KEY');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: EnvironmentConfig.supabaseUrl,
    anonKey: EnvironmentConfig.supabaseAnonKey,
  );
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // calculate widget to show
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        indicatorColor: Colors.blueGrey,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: Consumer(
        builder: (context, ref, child) {
          // install the loading screen
          ref.listen<bool>(
            isLoadingProvider,
            (_, isLoading) {
              if (isLoading) {
                LoadingScreen.instance().show(
                  context: context,
                );
              } else {
                LoadingScreen.instance().hide();
              }
            },
          );
          final isLoggedIn = ref.watch(isLoggedInProvider);
          if (isLoggedIn) {
            return const MainView();
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
