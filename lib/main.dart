import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:testingriverpod/views/magic_link.dart';

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
    url: 'https://anygorbdsftmbebkxyaa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFueWdvcmJkc2Z0bWJlYmt4eWFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTQxODQ0NjUsImV4cCI6MjAwOTc2MDQ2NX0.hE-gVUZCjlprUMsZEASpGZuNu0LTuEtAvFZL5k2dweo',
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
      debugShowCheckedModeBanner: false,
      title: 'Testing Riverpod',
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/magic_link': (context) => const MagicLink(),
        '/home': (context) => const MainView(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const Scaffold(
            body: Center(
              child: Text(
                'Not Found',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
      // home: Consumer(
      //   builder: (context, ref, child) {
      //     // install the loading screen
      //     ref.listen<bool>(
      //       isLoadingProvider,
      //       (_, isLoading) {
      //         if (isLoading) {
      //           LoadingScreen.instance().show(
      //             context: context,
      //           );
      //         } else {
      //           LoadingScreen.instance().hide();
      //         }
      //       },
      //     );
      //     final isLoggedIn = ref.watch(isLoggedInProvider);
      //     if (isLoggedIn) {
      //       return const MainView();
      //     } else {
      //       return const LoginView();
      //     }
      //   },
      // ),
    );
  }
}
