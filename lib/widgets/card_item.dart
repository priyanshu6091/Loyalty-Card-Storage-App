import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CardItem extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const CardItem({
    Key? key,
    required this.card,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: card.isExpired()
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Card logo or placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(card.colorValue).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: card.logoImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(card.logoImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.credit_card,
                                color: Color(card.colorValue),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.credit_card,
                            color: Color(card.colorValue),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Card details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCardNumber(card.cardNumber),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (card.expiryDate != null)
                          Text(
                            card.isExpired()
                                ? 'EXPIRED: ${_formatDate(card.expiryDate!)}'
                                : card.isExpiringSoon(30)
                                    ? 'Expires soon: ${_formatDate(card.expiryDate!)}'
                                    : 'Expires: ${_formatDate(card.expiryDate!)}',
                            style: TextStyle(
                              color: card.isExpired() || card.isExpiringSoon(30)
                                  ? Colors.red
                                  : Colors.grey,
                              fontWeight: card.isExpired() || card.isExpiringSoon(30)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Card type indicator
                  if (card.barcodeType != null)
                    Icon(
                      card.barcodeType == 'QR_CODE'
                          ? Icons.qr_code
                          : Icons.qr_code_scanner,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatCardNumber(String number) {
    if (number.length <= 8) return number;
    return '${number.substring(0, 4)}...${number.substring(number.length - 4)}';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
