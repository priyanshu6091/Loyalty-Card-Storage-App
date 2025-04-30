import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math';

// Import mock services instead of Firebase ones
import 'services/mock_auth_service.dart';
import 'services/mock_storage_service.dart';
import 'services/mock_sync_service.dart';
import 'services/mock_notification_service.dart';

// Available card colors
const List<Color> cardColors = [
  Colors.blue,
  Colors.purple,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.teal,
  Colors.indigo,
  Colors.pink,
];

// Barcode types
enum BarcodeType {
  qrCode,
  code128,
  barcode,
}

// Auth provider that works with mock auth service
class MockAuthProvider extends ChangeNotifier {
  final MockAuthService _authService;
  MockUser? _user;

  MockAuthProvider(this._authService) {
    // Listen for auth state changes
    _authService.authStateChanges.listen((MockUser? user) {
      _user = user;
      notifyListeners();
    });
  }

  MockUser? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn(String email, String password) async {
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      return user != null;
    } catch (e) {
      print('Sign in failed: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final user = await _authService.registerWithEmailAndPassword(email, password);
      return user != null;
    } catch (e) {
      print('Registration failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

// Card provider that works with mock storage and sync services
class MockCardProvider extends ChangeNotifier {
  final MockStorageService _storageService;
  final MockSyncService _syncService;
  final MockNotificationService _notificationService;
  
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = false;

  MockCardProvider(this._storageService, this._syncService, this._notificationService) {
    loadCards();
  }

  List<Map<String, dynamic>> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();
    
    _cards = await _storageService.getCards();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCard(Map<String, dynamic> card) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _storageService.saveCard(card);
    
    if (success) {
      _syncService.syncData();
      _notificationService.showNotification(
        title: 'Card Added',
        body: 'A new loyalty card has been added to your wallet.',
      );
      await loadCards();
    }
    
    _isLoading = false;
    notifyListeners();
    
    return success;
  }

  Future<bool> updateCard(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _storageService.updateCard(id, updates);
    
    if (success) {
      _syncService.syncData();
      await loadCards();
    }
    
    _isLoading = false;
    notifyListeners();
    
    return success;
  }

  Future<bool> deleteCard(String id) async {
    _isLoading = true;
    notifyListeners();
    
    final success = await _storageService.deleteCard(id);
    
    if (success) {
      _syncService.syncData();
      await loadCards();
    }
    
    _isLoading = false;
    notifyListeners();
    
    return success;
  }

  Future<bool> syncCards() async {
    return await _syncService.forceSyncData();
  }
}

// Main entry point - Web compatible version
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = MockStorageService();
  await storageService.init();
  
  final authService = MockAuthService();
  final syncService = MockSyncService(storageService, authService);
  final notificationService = MockNotificationService();
  await notificationService.init();
  
  runApp(MyApp(
    authService: authService,
    storageService: storageService,
    syncService: syncService,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final MockAuthService authService;
  final MockStorageService storageService;
  final MockSyncService syncService;
  final MockNotificationService notificationService;
  
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
          create: (_) => MockAuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => MockCardProvider(
            storageService,
            syncService,
            notificationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Loyalty Wallet',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MockAuthProvider>(context);
    final cardProvider = Provider.of<MockCardProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Wallet'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authProvider.signOut(),
              tooltip: 'Sign Out',
            ),
        ],
      ),
      body: Center(
        child: authProvider.isAuthenticated
            ? _buildCardList(context, cardProvider)
            : _buildLoginScreen(context, authProvider),
      ),
      floatingActionButton: authProvider.isAuthenticated
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCardScreen(cardProvider: cardProvider),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              tooltip: 'Add Card',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildLoginScreen(BuildContext context, MockAuthProvider authProvider) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Loyalty Wallet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (kIsWeb)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Web Compatible Version (No Firebase)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
            ),
          const SizedBox(height: 32),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.signIn(
                    emailController.text,
                    passwordController.text,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sign in failed')),
                    );
                  }
                },
                child: const Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await authProvider.register(
                    emailController.text,
                    passwordController.text,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration failed')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: For testing, use any email format and password ≥ 6 characters',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(BuildContext context, MockCardProvider cardProvider) {
    if (cardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (cardProvider.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No loyalty cards yet',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCardScreen(cardProvider: cardProvider),
                ),
              ),
              child: const Text('Add Your First Card'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await cardProvider.syncCards();
        await cardProvider.loadCards();
      },
      child: ListView.builder(
        itemCount: cardProvider.cards.length,
        itemBuilder: (context, index) {
          final card = cardProvider.cards[index];
          final cardColor = Color(card['color'] ?? cardColors[0].value);
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(card['companyName'] ?? 'Unnamed Card'),
              subtitle: Text(card['cardName'] ?? 'Loyalty Card'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailScreen(
                      card: card,
                      cardProvider: cardProvider,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  final MockCardProvider cardProvider;
  
  const AddCardScreen({
    Key? key,
    required this.cardProvider,
  }) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final companyNameController = TextEditingController();
  final cardNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  Color selectedColor = cardColors[0];
  BarcodeType selectedBarcodeType = BarcodeType.qrCode;
  
  @override
  void dispose() {
    companyNameController.dispose();
    cardNameController.dispose();
    cardNumberController.dispose();
    super.dispose();
  }

  // Function to simulate scanning a barcode
  void _scanBarcode() async {
    // In a real app, this would use flutter_barcode_scanner
    // Since we're in web mode, we'll simulate a scan
    setState(() {
      cardNumberController.text = '${Random().nextInt(90000) + 10000}${Random().nextInt(90000) + 10000}';
    });

    // Show a simulation dialog
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode scan simulated in web mode')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company name',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Card name',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cardNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Card Color'),
                    content: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: cardColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (selectedColor == color)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.color_lens),
              label: const Text('Pick color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (cardNumberController.text.isNotEmpty) ...[
              Text(
                'Card number: ${cardNumberController.text}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<BarcodeType>(
                value: selectedBarcodeType,
                decoration: const InputDecoration(
                  labelText: 'Barcode Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: BarcodeType.qrCode,
                    child: const Text('QR Code'),
                  ),
                  DropdownMenuItem(
                    value: BarcodeType.code128,
                    child: const Text('Code 128'),
                  ),
                  DropdownMenuItem(
                    value: BarcodeType.barcode,
                    child: const Text('Barcode (EAN-13)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedBarcodeType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Center(
                  child: BarcodeWidget(
                    barcode: selectedBarcodeType == BarcodeType.qrCode
                        ? Barcode.qrCode()
                        : selectedBarcodeType == BarcodeType.code128
                            ? Barcode.code128()
                            : Barcode.ean13(),
                    data: cardNumberController.text,
                    width: 200,
                    height: 100,
                    drawText: selectedBarcodeType != BarcodeType.qrCode,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (companyNameController.text.isNotEmpty && cardNumberController.text.isNotEmpty) {
                  widget.cardProvider.addCard({
                    'companyName': companyNameController.text,
                    'cardName': cardNameController.text.isNotEmpty
                        ? cardNameController.text
                        : '${companyNameController.text} Card',
                    'number': cardNumberController.text,
                    'color': selectedColor.value,
                    'barcodeType': selectedBarcodeType.index,
                    'createdAt': DateTime.now().toIso8601String(),
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter company name and scan a code'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Create new Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class CardDetailScreen extends StatelessWidget {
  final Map<String, dynamic> card;
  final MockCardProvider cardProvider;
  
  const CardDetailScreen({
    Key? key,
    required this.card,
    required this.cardProvider,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final color = Color(card['color'] ?? cardColors[0].value);
    final barcodeType = BarcodeType.values[card['barcodeType'] ?? 0];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            card['companyName'] ?? 'Company',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cloud_download, color: Colors.white),
                            onPressed: () {
                              // Save to wallet functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Card copied to clipboard')),
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        card['cardName'] ?? 'Loyalty Card',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: BarcodeWidget(
                            barcode: barcodeType == BarcodeType.qrCode
                                ? Barcode.qrCode()
                                : barcodeType == BarcodeType.code128
                                    ? Barcode.code128()
                                    : Barcode.ean13(),
                            data: card['number'] ?? '1234567890',
                            width: 250,
                            height: 150,
                            drawText: barcodeType != BarcodeType.qrCode,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Card'),
                    content: const Text('Are you sure you want to delete this card?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          cardProvider.deleteCard(card['id']);
                          Navigator.pop(context); // Go back to list
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              child: const Text('Delete card'),
            ),
          ),
        ],
      ),
    );
  }
} 