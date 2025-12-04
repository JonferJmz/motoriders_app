
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/screens/club_details_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class ClubListTile extends StatelessWidget {
  final Club club;

  const ClubListTile({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: SizedBox(
          width: 50, 
          height: 50, 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              club.logoUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(club.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          club.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!club.isPublic)
              const Icon(Icons.lock, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailsScreen(club: club),
            ),
          );
        },
      ),
    );
  }
}
