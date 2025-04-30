import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';
import 'package:loyalty_wallet/screens/home_screen.dart';
import 'package:loyalty_wallet/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }
  
  Future<void> _checkAuth() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Navigate based on authentication status
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.credit_card,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loyalty Wallet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
