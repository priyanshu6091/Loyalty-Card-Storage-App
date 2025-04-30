import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'loyalty_card.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String cardNumber;

  @HiveField(3)
  String? barcodeType; // QR, CODE_39, CODE_128, etc.

  @HiveField(4)
  DateTime? expiryDate;

  @HiveField(5)
  String? logoImagePath;

  @HiveField(6)
  int colorValue;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;
  
  @HiveField(10)
  bool isSynced;
  
  @HiveField(11)
  bool isDeleted;

  LoyaltyCard({
    String? id,
    required this.name,
    required this.cardNumber,
    this.barcodeType,
    this.expiryDate,
    this.logoImagePath,
    required this.colorValue,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cardNumber': cardNumber,
      'barcodeType': barcodeType,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'logoImagePath': logoImagePath,
      'colorValue': colorValue,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'],
      name: json['name'],
      cardNumber: json['cardNumber'],
      barcodeType: json['barcodeType'],
      expiryDate: json['expiryDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiryDate']) 
          : null,
      logoImagePath: json['logoImagePath'],
      colorValue: json['colorValue'],
      notes: json['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  LoyaltyCard copyWith({
    String? name,
    String? cardNumber,
    String? barcodeType,
    DateTime? expiryDate,
    String? logoImagePath,
    int? colorValue,
    String? notes,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return LoyaltyCard(
      id: this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      barcodeType: barcodeType ?? this.barcodeType,
      expiryDate: expiryDate ?? this.expiryDate,
      logoImagePath: logoImagePath ?? this.logoImagePath,
      colorValue: colorValue ?? this.colorValue,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool isExpired() {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool isExpiringSoon(int days) {
    if (expiryDate == null) return false;
    final threshold = DateTime.now().add(Duration(days: days));
    return expiryDate!.isBefore(threshold) && !isExpired();
  }
}
