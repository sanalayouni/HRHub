import 'dart:convert';
import 'dart:io';

/// Persists the auth token and theme choice, mirroring the web app's use of
/// `localStorage`.
///
/// This writes to the app-private temp directory with `dart:io` rather than
/// using `shared_preferences`, because native plugins need Windows Developer
/// Mode enabled to build and it currently is not. Swapping the two `_read` /
/// `_write` helpers for a plugin later is self-contained.
class SessionStore {
  static const _fileName = 'hrhub_session.json';

  /// Held in memory so the Dio interceptor can read it synchronously.
  static String? token;
  static String themeMode = 'light';

  /// Called when the API rejects the stored token, so the UI can log out.
  static void Function()? onUnauthorized;

  static File get _file => File('${Directory.systemTemp.path}/$_fileName');

  static Future<void> load() async {
    try {
      final file = _file;
      if (!await file.exists()) return;
      final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      token = data['token'] as String?;
      themeMode = (data['themeMode'] as String?) ?? 'light';
    } catch (_) {
      // A corrupt or unreadable session file just means "logged out".
      token = null;
    }
  }

  static Future<void> _persist() async {
    try {
      await _file.writeAsString(jsonEncode({'token': token, 'themeMode': themeMode}));
    } catch (_) {
      // Persistence is a convenience; failing to write must not break the app.
    }
  }

  static Future<void> saveToken(String value) async {
    token = value;
    await _persist();
  }

  static Future<void> clearToken() async {
    token = null;
    await _persist();
  }

  static Future<void> saveThemeMode(String value) async {
    themeMode = value;
    await _persist();
  }
}
