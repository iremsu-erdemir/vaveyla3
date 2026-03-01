class MenuItemModel {
  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    this.isAvailable = true,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final int price;
  final String imagePath;
  final bool isAvailable;
  final bool isFeatured;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _parseInt(json['price']),
      imagePath: json['imagePath']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true || json['isAvailable'] == 1,
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imagePath': imagePath,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    int? price,
    String? imagePath,
    bool? isAvailable,
    bool? isFeatured,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
