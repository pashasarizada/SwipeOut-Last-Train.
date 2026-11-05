import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('the app is called Last Train on both platforms', () {
    expect(
      _read('ios/Runner/Info.plist'),
      matches(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>Last Train</string>'),
      ),
    );
    expect(
      _read('android/app/src/main/AndroidManifest.xml'),
      contains('android:label="Last Train"'),
    );
  });

  test('launch screens are dark, never white', () {
    final storyboard = _read('ios/Runner/Base.lproj/LaunchScreen.storyboard');
    expect(storyboard, isNot(contains('red="1" green="1" blue="1"')));
    for (final dir in ['drawable', 'drawable-v21']) {
      final xml = _read('android/app/src/main/res/$dir/launch_background.xml');
      expect(xml, isNot(contains('@android:color/white')), reason: dir);
      expect(xml, contains('@color/launch_background'), reason: dir);
    }
    expect(
      _read('android/app/src/main/res/values/colors.xml'),
      contains('#FF0B1020'),
    );
  });

  test('the Flutter logo is replaced by our own icon', () {
    final icon = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    );
    final expected = File('assets/branding/icon_1024.png');
    expect(expected.existsSync(), isTrue);
    expect(icon.readAsBytesSync(), expected.readAsBytesSync());
  });
}
