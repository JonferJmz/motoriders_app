
// motorcycle_model.dart

class Motorcycle {
  final String id;
  String nickname;
  String brand;
  String model;
  int year;
  int mileage;
  String imageUrl;
  List<Modification> modifications;

  Motorcycle({
    required this.id,
    required this.nickname,
    required this.brand,
    required this.model,
    required this.year,
    this.mileage = 0,
    this.imageUrl = 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=2070&auto=format&fit=crop', // Imagen por defecto
    required this.modifications,
  });
}

class Modification {
  final String title;
  final String description;
  bool isVerified;

  Modification({
    required this.title,
    required this.description,
    this.isVerified = false,
  });
}
