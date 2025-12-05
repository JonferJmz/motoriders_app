
enum ClubRole { president, captain, member, rookie }

class ClubMember {
  final String userId;
  final String userName;
  final String userAvatarUrl;
  ClubRole role;
  final DateTime joinedAt;

  ClubMember({
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    this.role = ClubRole.rookie,
    required this.joinedAt,
  });

  // Helper para obtener el nombre del rol en texto legible
  String get roleName {
    switch (role) {
      case ClubRole.president: return 'Presidente';
      case ClubRole.captain: return 'Capitán';
      case ClubRole.member: return 'Miembro';
      case ClubRole.rookie: return 'Novato';
    }
  }
}
