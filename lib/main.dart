import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:loyalty_wallet/screens/splash_screen.dart';
import 'package:loyalty_wallet/services/auth_service.dart';
import 'package:loyalty_wallet/services/storage_service.dart';
import 'package:loyalty_wallet/services/sync_service.dart';
import 'package:loyalty_wallet/services/notification_service.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';
import 'package:loyalty_wallet/providers/card_provider.dart';
import 'package:loyalty_wallet/firebase_options.dart';

// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with conditional web support
  await initializeFirebase();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final authService = AuthService();
  final syncService = SyncService(storageService, authService);
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(MyApp(
    authService: authService,
    storageService: storageService,
    syncService: syncService,
    notificationService: notificationService,
  ));
}

// Initialize Firebase with platform-specific handling
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue app without Firebase if initialization fails
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final StorageService storageService;
  final SyncService syncService;
  final NotificationService notificationService;
  
  const MyApp({
    Key? key,
    required this.authService,
    required this.storageService,
    required this.syncService,
    required this.notificationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CardProvider?>(
          create: (_) => CardProvider(
            storageService,
            syncService,
            notificationService,
          ),
          update: (_, authProvider, previous) {
            if (authProvider.isAuthenticated) {
              return previous ?? CardProvider(
                storageService,
                syncService,
                notificationService,
              );
            }
            return null;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Loyalty Wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
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
                  'Note: Some Firebase features are limited in web mode due to compatibility issues.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                // Add functionality here
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
