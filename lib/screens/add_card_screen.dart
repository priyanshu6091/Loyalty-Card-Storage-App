import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loyalty_wallet/models/loyalty_card.dart';
import 'package:loyalty_wallet/providers/card_provider.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _notesController = TextEditingController();
  String? _barcodeType = 'CODE_128';
  DateTime? _expiryDate;
  File? _logoImage;
  int _colorValue = Colors.blue.value;
  bool _isLoading = false;
  
  final List<String> _barcodeTypes = [
    'QR_CODE',
    'CODE_128',
    'CODE_39',
    'EAN_13',
    'EAN_8',
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _scanBarcode() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      
      if (barcodeScanRes != '-1') {
        setState(() {
          _cardNumberController.text = barcodeScanRes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan barcode: $e')),
      );
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      
      if (image != null) {
        setState(() {
          _logoImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }
  
  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }
  
  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      
      String? logoPath;
      if (_logoImage != null) {
        logoPath = await cardProvider.saveCardImage(_logoImage!, 'new_card');
      }
      
      final card = LoyaltyCard(
        name: _nameController.text.trim(),
        cardNumber: _cardNumberController.text.trim(),
        barcodeType: _barcodeType,
        expiryDate: _expiryDate,
        logoImagePath: logoPath,
        colorValue: _colorValue,
        notes: _notesController.text.trim(),
      );
      
      await cardProvider.addCard(card);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card logo/image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(_colorValue).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _logoImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _logoImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_membership),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name for the card';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Card number with scan button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Card Number *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the card number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _scanBarcode,
                            child: const Icon(Icons.qr_code_scanner),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Barcode type
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Barcode Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      value: _barcodeType,
                      items: _barcodeTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.replaceAll('_', ' ')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _barcodeType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Expiry date
                    GestureDetector(
                      onTap: _selectExpiryDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: _expiryDate == null
                                ? ''
                                : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card color
                    Row(
                      children: [
                        const Text('Card Color: '),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Select Color'),
                                content: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _colorButton(Colors.red.value),
                                      _colorButton(Colors.pink.value),
                                      _colorButton(Colors.purple.value),
                                      _colorButton(Colors.deepPurple.value),
                                      _colorButton(Colors.indigo.value),
                                      _colorButton(Colors.blue.value),
                                      _colorButton(Colors.lightBlue.value),
                                      _colorButton(Colors.cyan.value),
                                      _colorButton(Colors.teal.value),
                                      _colorButton(Colors.green.value),
                                      _colorButton(Colors.lightGreen.value),
                                      _colorButton(Colors.orange.value),
                                      _colorButton(Colors.deepOrange.value),
                                      _colorButton(Colors.brown.value),
                                      _colorButton(Colors.grey.value),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(_colorValue),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _saveCard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Card'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _colorButton(int colorValue) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _colorValue = colorValue;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(colorValue),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _colorValue == colorValue ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
