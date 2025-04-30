import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/providers/auth_provider.dart';
import 'package:loyalty_wallet/providers/card_provider.dart';
import 'package:loyalty_wallet/screens/add_card_screen.dart';
import 'package:loyalty_wallet/screens/card_detail_screen.dart';
import 'package:loyalty_wallet/screens/login_screen.dart';
import 'package:loyalty_wallet/screens/settings_screen.dart';
import 'package:loyalty_wallet/widgets/card_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    List<LoyaltyCard> filteredCards = cardProvider.searchCards(_searchQuery);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => cardProvider.refreshCards(),
              child: cardProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCards.isEmpty
                      ? const Center(child: Text('No loyalty cards found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];
                            return CardItem(
                              card: card,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CardDetailScreen(cardId: card.id),
                                  ),
                                );
                              },
                              onDelete: () => cardProvider.deleteCard(card.id),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
