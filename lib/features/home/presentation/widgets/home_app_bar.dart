import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Image.asset('assets/images/ExploraChiapas Logo.png', height: 26),
          const SizedBox(width: 8),
          const Text(
            'ExploraChiapas',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFD8F5D8),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://i.pravatar.cc/150?img=12',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Icon(Icons.person, color: Color(0xFF2E7D32)),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.person, color: Color(0xFF2E7D32)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}