
class Club {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final int memberCount;
  final bool isPublic;
  final double latitude;
  final double longitude;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.memberCount,
    this.isPublic = true,
    required this.latitude,
    required this.longitude,
  });
}
