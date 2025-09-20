import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  void _toggleTheme() {
    setState(() {
      _darkMode = !_darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: _darkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green))
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: MyHomePage(toggleTheme: _toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.toggleTheme});
  final VoidCallback toggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _initialImage = true;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _loadState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
      _initialImage = prefs.getBool('imageState') ?? true;
    });
  }

  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', _counter);
    await prefs.setBool('imageState', _initialImage);
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveState();
  }

  void _toggleImage() {
    _controller.reverse().then((_) {
      setState(() {
        _initialImage = !_initialImage;
      });
      _controller.forward();
      _saveState();
    });
  }

  void _resetApp() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Confirm Reset',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Do you really want to reset the app?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        _counter = 0;
        _initialImage = true;
      });
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Application"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text("Increment"),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _animation,
              child: Image.asset(
                _initialImage ? 'assets/image1.png' : 'assets/image2.png',
                height: 300,
                width: 350,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleImage,
              child: const Text("Toggle Image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.toggleTheme,
              child: const Text("Toggle Theme"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
              ),
              child: const Text("Reset"),
            ),
          ],
        ),
      ),
    );
  }
}
