import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../utils/resena_display_utils.dart';

/// Avatar de autor de reseña, reutilizable en cualquier tarjeta de
/// reseñas (`ResenaCard`, `ResenaFeedCard`, futuras). Centraliza la
/// única regla real disponible hoy: la API de reseñas solo devuelve
/// `userId` — nunca nombre ni foto de quien la escribió (confirmado en
/// el backend: `reviews` no hace JOIN contra `usuario`, y no existe un
/// `GET /users/{id}` público para resolverlo del lado del cliente).
///
/// Por eso el alcance real de "mostrar la foto de perfil en las
/// reseñas" es: cuando la reseña es del usuario que la está viendo
/// (`esMia`), se usa su propia foto ya disponible vía [ProfileProvider]
/// (la misma que se ve en el Home/Perfil). Para reseñas de otros
/// usuarios se mantiene el círculo de iniciales por color — no se
/// inventa ni se simula una foto ajena.
class ResenaAvatar extends StatelessWidget {
  final String userId;
  final double radius;

  const ResenaAvatar({super.key, required this.userId, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().usuario?.id;
    final esMia = miId != null && miId == userId;
    final color = ResenaDisplayUtils.colorPorUsuario(userId);

    String? fotoUrl;
    if (esMia) {
      final perfil = context.watch<ProfileProvider>().perfil;
      if (perfil != null && perfil.ImgUrl.isNotEmpty) {
        fotoUrl = perfil.ImgUrl;
      }
    }

    final iniciales = Text(
      ResenaDisplayUtils.iniciales(userId),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.65,
      ),
    );

    if (fotoUrl == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.15),
        child: iniciales,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: fotoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => Center(child: iniciales),
          errorWidget: (_, __, ___) => Center(child: iniciales),
        ),
      ),
    );
  }
}
