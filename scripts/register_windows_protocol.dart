// ignore_for_file: avoid_print
import 'dart:io';

/// This script registers the custom URL scheme for Windows deep linking.
/// It automatically detects the current executable path.
void main() async {
  if (!Platform.isWindows) {
    print('This script is only for Windows.');
    return;
  }

  final scheme = 'io.supabase.orbit';
  
  // Get the path of the current project directory
  final projectDir = Directory.current.path;
  
  // Try to find the executable in the build folder
  // We check both Debug and Release paths
  final possiblePaths = [
    '$projectDir\\build\\windows\\x64\\runner\\Debug\\orbit.exe',
    '$projectDir\\build\\windows\\runner\\Debug\\orbit.exe',
    '$projectDir\\build\\windows\\x64\\runner\\Release\\orbit.exe',
  ];

  String? executablePath;
  for (var path in possiblePaths) {
    if (File(path).existsSync()) {
      executablePath = path;
      break;
    }
  }

  if (executablePath == null) {
    print('Error: Could not find orbit.exe in build folder.');
    print('Please build your app first: flutter build windows');
    return;
  }

  final regKey = 'HKEY_CURRENT_USER\\Software\\Classes\\$scheme';
  final command = '$regKey\\shell\\open\\command';

  try {
    print('Registering protocol for: $executablePath');
    
    await Process.run('reg', ['add', regKey, '/ve', '/d', 'URL:Orbit Protocol', '/f']);
    await Process.run('reg', ['add', regKey, '/v', 'URL Protocol', '/d', '', '/f']);
    await Process.run('reg', ['add', command, '/ve', '/d', '"$executablePath" "%1"', '/f']);

    print('Successfully registered $scheme://');
  } catch (e) {
    print('Error: $e');
  }
}
