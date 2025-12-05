
class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverPhotoUrl;
  final String bio;
  final int postCount;
  final int clubCount;
  final int kilometersRidden;

  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.coverPhotoUrl = 'https://images.unsplash.com/photo-1582752224640-1e6a1313316d?q=80&w=2070&auto=format&fit=crop', // Imagen por defecto
    this.bio = 'Añade una biografía para que otros riders te conozcan.',
    this.postCount = 0,
    this.clubCount = 0,
    this.kilometersRidden = 0,
  });
}
