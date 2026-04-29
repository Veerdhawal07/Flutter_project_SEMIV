class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String ownerName;
  final String category;
  final String area;
  final String address;
  final String phone;
  final String whatsapp;
  final String? logoUrl;
  final String? bannerUrl;
  final String openingTime;
  final String closingTime;
  final bool hasHomeDelivery;
  final String description;
  final bool isOpen;
  final double rating;
  final int totalRatings;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.ownerName,
    required this.category,
    required this.area,
    required this.address,
    required this.phone,
    required this.whatsapp,
    this.logoUrl,
    this.bannerUrl,
    required this.openingTime,
    required this.closingTime,
    required this.hasHomeDelivery,
    required this.description,
    this.isOpen = true,
    this.rating = 0.0,
    this.totalRatings = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'ownerName': ownerName,
      'category': category,
      'area': area,
      'address': address,
      'phone': phone,
      'whatsapp': whatsapp,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'hasHomeDelivery': hasHomeDelivery,
      'description': description,
      'isOpen': isOpen,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map, String id) {
    return ShopModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      ownerName: map['ownerName'] ?? '',
      category: map['category'] ?? '',
      area: map['area'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      logoUrl: map['logoUrl'],
      bannerUrl: map['bannerUrl'],
      openingTime: map['openingTime'] ?? '',
      closingTime: map['closingTime'] ?? '',
      hasHomeDelivery: map['hasHomeDelivery'] ?? false,
      description: map['description'] ?? '',
      isOpen: map['isOpen'] ?? true,
      rating: map['rating']?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] ?? 0,
    );
  }
}

class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final double price;
  final double discount;
  final double quantity;
  final String unit;
  final bool isAvailable;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    required this.price,
    this.discount = 0.0,
    required this.quantity,
    required this.unit,
    this.isAvailable = true,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'category': category,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'unit': unit,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      shopId: map['shopId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }
}
