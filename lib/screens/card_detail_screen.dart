import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/providers/card_provider.dart';
import 'package:loyalty_wallet/screens/edit_card_screen.dart';

class CardDetailScreen extends StatelessWidget {
  final String cardId;
  
  const CardDetailScreen({
    Key? key,
    required this.cardId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final cardProvider = Provider.of<CardProvider>(context, listen: false);
              final card = await cardProvider.getCard(cardId);
              
              if (card != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCardScreen(card: card),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
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
                        final cardProvider = Provider.of<CardProvider>(context, listen: false);
                        cardProvider.deleteCard(cardId);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to home
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<LoyaltyCard?>(
        future: Provider.of<CardProvider>(context, listen: false).getCard(cardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Card not found'));
          }
          
          final card = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card header with logo and name
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(card.colorValue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (card.logoImagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(card.logoImagePath!),
                            width: 60,
                            height: 60,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.credit_card,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (card.expiryDate != null)
                              Text(
                                'Expires: ${card.expiryDate!.day}/${card.expiryDate!.month}/${card.expiryDate!.year}',
                                style: TextStyle(
                                  color: card.isExpired()
                                      ? Colors.red
                                      : Colors.white,
                                  fontWeight: card.isExpired()
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Barcode section
                if (card.barcodeType != null)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          BarcodeWidget(
                            barcode: _getBarcodeType(card.barcodeType!),
                            data: card.cardNumber,
                            width: double.infinity,
                            height: 100,
                            drawText: false,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card.cardNumber,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: card.cardNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Number'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Card Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card.cardNumber,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: card.cardNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Number'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Notes section
                if (card.notes != null && card.notes!.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(card.notes!),
                        ],
                      ),
                    ),
                  ),
                
                // Date information
                const SizedBox(height: 24),
                Text(
                  'Added on: ${_formatDate(card.createdAt)}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (card.updatedAt != card.createdAt)
                  Text(
                    'Last updated: ${_formatDate(card.updatedAt)}',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Barcode _getBarcodeType(String type) {
    switch (type) {
      case 'QR_CODE':
        return Barcode.qrCode();
      case 'CODE_39':
        return Barcode.code39();
      case 'EAN_13':
        return Barcode.ean13();
      case 'EAN_8':
        return Barcode.ean8();
      case 'CODE_128':
      default:
        return Barcode.code128();
    }
  }
}
