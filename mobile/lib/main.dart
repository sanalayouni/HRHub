import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/session_store.dart';
import 'providers/auth_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'widgets/app_backdrop.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the token and theme choice before the first frame so we don't
  // flash the login screen at an already-signed-in user.
  await SessionStore.load();
  runApp(const ProviderScope(child: HrHubApp()));
}

class HrHubApp extends ConsumerWidget {
  const HrHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HRHub',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: ref.watch(routerProvider),
      // The gradient backdrop sits behind every route, like the web `body`.
      builder: (context, child) => AppBackdrop(child: child ?? const SizedBox.shrink()),
    );
  }
}
