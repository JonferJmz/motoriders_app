
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/models/rank_model.dart';

// Modelo simple para un miembro del club, lo movemos aquí para que sea accesible globalmente.
class ClubMember {
  final String id;
  final String name;
  final String avatarUrl;
  String rank; // Cambiado a no final para poder modificarlo

  ClubMember({required this.id, required this.name, required this.avatarUrl, required this.rank});
}

class ClubService {

  // Simula una base de datos de miembros por club
  final Map<String, List<ClubMember>> _clubMembers = {
    'club1': [
      ClubMember(id: 'user1', name: 'jonfer119', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80', rank: 'Presidente'),
      ClubMember(id: 'user2', name: 'Andrea GP', avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', rank: 'Capitán de Ruta'),
      ClubMember(id: 'user3', name: 'Carlos_MX', avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=60', rank: 'Miembro'),
    ],
     'club2': [
      ClubMember(id: 'user4', name: 'RiderX', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=60', rank: 'Líder del Fango'),
    ]
  };

  final List<Club> _myClubs = [
    Club(
      id: 'club1',
      name: 'Club de Motos GDL',
      description: 'Rodadas y eventos en la ZMG.',
      logoUrl: 'https://picsum.photos/seed/clubgdl/200/200',
      memberCount: 128,
      latitude: 20.6736,
      longitude: -103.344,
    ),
    Club(
      id: 'club2',
      name: 'Enduro Cross Jalisco',
      description: 'Solo para amantes del lodo y la terracería.',
      logoUrl: 'https://picsum.photos/seed/enduro/200/200',
      memberCount: 42,
      isPublic: false,
      latitude: 20.6599,
      longitude: -103.3496,
    ),
  ];

  final Map<String, List<Rank>> _clubRanks = {
    'club1': [
      Rank(id: 'r1', name: 'Presidente', color: Colors.amber, canBan: true, canEditClubInfo: true, canInvite: true, canKick: true),
      Rank(id: 'r2', name: 'Capitán de Ruta', color: Colors.blue, canInvite: true),
      Rank(id: 'r3', name: 'Miembro'),
    ],
  };

  Future<List<Club>> getMyClubs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _myClubs;
  }

  Future<void> createClub(String name, String description, bool isPublic) async {
    await Future.delayed(const Duration(seconds: 1));
    String clubId = 'club${_myClubs.length + 1}';
    final newClub = Club(
      id: clubId,
      name: name,
      description: description,
      isPublic: isPublic,
      logoUrl: 'https://picsum.photos/seed/${name.replaceAll(' ', '')}/200/200', 
      memberCount: 1, 
      latitude: 20.6730, 
      longitude: -103.3500,
    );
    _myClubs.add(newClub);
    _clubRanks[clubId] = [];
     _clubMembers[clubId] = [ClubMember(id: 'user-creator', name: 'jonfer119', avatarUrl: '', rank: 'Presidente')];
  }

  Future<List<Rank>> getRanksForClub(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _clubRanks[clubId] ?? [];
  }

  Future<void> addRankToClub(String clubId, Rank newRank) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _clubRanks[clubId]?.add(newRank);
  }

  Future<void> updateRankInClub(String clubId, Rank updatedRank) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ranks = _clubRanks[clubId];
    if (ranks != null) {
      final index = ranks.indexWhere((r) => r.id == updatedRank.id);
      if (index != -1) {
        ranks[index] = updatedRank;
      }
    }
  }

  Future<void> deleteRankFromClub(String clubId, String rankId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _clubRanks[clubId]?.removeWhere((rank) => rank.id == rankId);
  }

  Future<List<ClubMember>> getMembersForClub(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _clubMembers[clubId] ?? [];
  }

  Future<void> updateMemberRank(String clubId, String memberId, String newRank) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final members = _clubMembers[clubId];
    final member = members?.firstWhere((m) => m.id == memberId);
    if (member != null) {
      member.rank = newRank;
    }
  }

  Future<void> kickMember(String clubId, String memberId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _clubMembers[clubId]?.removeWhere((m) => m.id == memberId);
  }
}
