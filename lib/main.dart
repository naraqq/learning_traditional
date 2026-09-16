import 'package:flutter/material.dart';

import 'src/screens/home_path_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/storage/progress_store.dart';

void main() {
  runApp(const MongolianHandwritingApp());
}

/// Root app for the traditional Mongolian-script handwriting practice
/// early learning edition.
class MongolianHandwritingApp extends StatelessWidget {
  const MongolianHandwritingApp({super.key, this.store});

  final ProgressStore? store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uigarjin — Mongolian Script',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: HomePathScreen(store: store ?? PreferencesProgressStore()),
    );
  }
}
