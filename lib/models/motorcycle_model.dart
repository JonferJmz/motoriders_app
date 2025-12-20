class Motorcycle {
  final int id;
  final String nickname;
  final String brand;
  final String model;
  final int year;
  final int userId;
  final String? imageUrl;       // ✅ NUEVO
  final double purchasePrice;   // ✅ NUEVO
  final double totalInvested;   // ✅ NUEVO: Moto + Mods
  final int gasCount;           // ✅ NUEVO: Likes
  final int modsCount;          // ✅ NUEVO: Cantidad de mods

  Motorcycle({
    required this.id,
    required this.nickname,
    required this.brand,
    required this.model,
    required this.year,
    required this.userId,
    this.imageUrl,
    this.purchasePrice = 0.0,
    this.totalInvested = 0.0,
    this.gasCount = 0,
    this.modsCount = 0,
  });

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    return Motorcycle(
      id: json['id'],
      nickname: json['nickname'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      // Parseo seguro de números (a veces vienen como int, a veces double)
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      totalInvested: (json['total_invested'] ?? 0).toDouble(),
      gasCount: json['gas_count'] ?? 0,
      modsCount: json['mods_count'] ?? 0,
    );
  }
}