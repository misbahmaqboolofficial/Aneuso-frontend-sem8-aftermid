import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Global test setup — allow Google Fonts network fetch in widget tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = true;
  await testMain();
}
