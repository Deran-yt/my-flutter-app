import 'package:flutter/material.dart';
import 'login_page.dart';
import 'user_repository.dart';

void main() {
  runApp(const NoteShareApp());
}

class NoteShareApp extends StatelessWidget {
  const NoteShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: UserRepository.instance,
      builder: (context, _) {
        final isDark = UserRepository.instance.darkMode;
        return MaterialApp(
          title: 'NoteShare',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.deepPurple,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const LoginPage(),
        );
      },
    );
  }
}
