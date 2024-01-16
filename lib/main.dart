import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PolyculeClient());
}

class PolyculeClient extends StatelessWidget {
  const PolyculeClient({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: 'Sono',
            colorScheme: lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.light,
                ),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Sono',
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.dark,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meow !'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
