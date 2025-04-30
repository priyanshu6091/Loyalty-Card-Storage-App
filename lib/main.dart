import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_wallet/screens/splash_screen.dart';
import 'package:loyalty_wallet/services/auth_service.dart';
import 'package:loyalty_wallet/services/storage_service.dart';
import 'package:loyalty_wallet/services/sync_service.dart';
import 'package:loyalty_wallet/services/notification_service.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';
import 'package:loyalty_wallet/providers/card_provider.dart';
import 'package:loyalty_wallet/firebase_options.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
