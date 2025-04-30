import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Main entry point - No Firebase version
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Running Firebase-free version for web compatibility');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loyalty Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Wallet'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Loyalty Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (kIsWeb)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Note: Firebase features are disabled in web mode due to compatibility issues.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality here
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Info'),
                    content: const Text('Using simplified version without Firebase.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
} 