import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const ProfileAvatar({super.key, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFFD8F5D8),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Icon(
                  Icons.person,
                  size: 52,
                  color: Color(0xFF2E7D32),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 52,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
