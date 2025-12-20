
import 'package:flutter/material.dart';

class Rank {
  String id;
  String name;
  Color color;
  // Futuro: Icon icon;

  // Permisos
  bool canInvite;
  bool canKick;
  bool canBan;
  bool canEditClubInfo;

  Rank({
    required this.id,
    required this.name,
    this.color = Colors.grey,
    this.canInvite = false,
    this.canKick = false,
    this.canBan = false,
    this.canEditClubInfo = false,
  });
}
