import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      home: FadingTextAnimation(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
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
  // 1. Controller to manage the pages and a variable to track the current page.
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  bool _isVisible = true;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    // 2. Add a listener to update the app bar title when the page changes.
    _pageController.addListener(() {
      // Use page.round() to get the closest page index during a swipe.
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != _currentPageIndex) {
        setState(() {
          _currentPageIndex = currentPage;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }

  @override
  void dispose() {
    // 3. Don't forget to dispose of the controller to prevent memory leaks!
    _pageController.dispose();
    super.dispose();
  }

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _changeTextColor(Color newColor) {
    setState(() {
      _textColor = newColor;
    });
  }

  void openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select a Color"),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var color in [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FloatingActionButton(
                      backgroundColor: color,
                      onPressed: () {
                        _changeTextColor(color);
                        Navigator.of(context).pop();
                      },
                      shape: const CircleBorder(),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static final WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty.resolveWith<Icon>((Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return const Icon(Icons.sunny);
    }
    return const Icon(Icons.mode_night);
  });

  // 4. Helper method to build a single animation page. This avoids repeating code.
  Widget _buildAnimationPage({required Duration duration, required String text}) {
    return Center(
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: duration,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, color: _textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 5. App bar title now dynamically updates based on the current page.
        title: Text('Animation: Page ${_currentPageIndex + 1}'),
        actions: [
          Switch(
            thumbIcon: thumbIcon,
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: openDialog,
            child: const Icon(Icons.palette),
          ),
          const SizedBox(width: 20),
        ],
      ),
      // 6. The body is now a PageView, which makes its children swipeable.
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          // Page 1: Original animation with a 1-second duration.
          _buildAnimationPage(
            duration: const Duration(seconds: 1),
            text: 'Hello, Flutter!\n(1s Fade)',
          ),
          // Page 2: Slower animation with a 3-second duration.
          _buildAnimationPage(
            duration: const Duration(seconds: 3),
            text: 'Slower Fade!\n(3s Fade)',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

