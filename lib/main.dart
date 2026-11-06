import 'package:flutter/material.dart';

import 'app_theme_controller.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = AppThemeController();
  await themeController.load();

  runApp(MotoLoanApp(themeController: themeController));
}

class MotoLoanApp extends StatelessWidget {
  const MotoLoanApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'MotoLoan',
          debugShowCheckedModeBanner: false,

          theme: buildAppTheme(
            brightness: Brightness.light,
            accent: themeController.accentColor,
          ),

          darkTheme: buildAppTheme(
            brightness: Brightness.dark,
            accent: themeController.accentColor,
          ),

          themeMode: themeController.themeMode,

          home: HomeScreen(themeController: themeController),
        );
      },
    );
  }
}
