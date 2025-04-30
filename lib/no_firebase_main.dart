import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loyalty Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
                  'Running in web mode - Firebase features disabled',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show loyalty cards (would typically connect to Firebase)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Info'),
                    content: const Text('Firebase features are currently disabled.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('View Loyalty Cards'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new loyalty card (would typically use Firebase)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase features are disabled in this build'),
            ),
          );
        },
        tooltip: 'Add Loyalty Card',
        child: const Icon(Icons.add),
      ),
    );
  }
} 