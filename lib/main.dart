import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. Convert MyApp to a StatefulWidget to manage the theme state.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 2. The theme state now lives here.
  ThemeMode _themeMode = ThemeMode.light;

  // 3. This function will be passed to the child widget to change the state.
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 4. The MaterialApp now uses the state variable.
      themeMode: _themeMode,
      home: FadingTextAnimation(
        // 5. Pass the current theme state and the toggle function down to the child.
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  // 6. Add fields to accept the state and callback from the parent.
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const FadingTextAnimation({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation> {
  bool _isVisible = true;
  // 7. The local _isDark state is no longer needed. We will use the values passed from MyApp.

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  // This can remain the same.
  static WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty.resolveWith<Icon>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.sunny);
      }
      return const Icon(Icons.mode_night);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Text Animation'),
        actions: [
          Switch(
            thumbIcon: thumbIcon,
            // 8. Use the `isDarkMode` value passed from the parent widget.
            value: widget.isDarkMode,
            // 9. When the switch is changed, call the function passed from the parent widget.
            onChanged: widget.onThemeChanged,
          ),
          const SizedBox(width: 80)
        ],
      ),
      body: Center(
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(seconds: 1),
          child: const Text(
            'Hello, Flutter!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}