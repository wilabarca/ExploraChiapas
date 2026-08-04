import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/resena_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../utils/resena_display_utils.dart';

/// Avatar de autor de reseña, reutilizable en cualquier tarjeta de
/// reseñas (`ResenaCard`, `ResenaFeedCard`, futuras). `GET /reviews`
/// ahora devuelve `userName`/`userImageUrl` embebidos (antes solo daba
/// `userId`) — se usan cuando el backend los trae, con el círculo de
/// iniciales por color como respaldo para reseñas antiguas o si el
/// backend no tuviera esos campos para ese usuario en particular.
class ResenaAvatar extends StatelessWidget {
  final Resena resena;
  final double radius;

  const ResenaAvatar({super.key, required this.resena, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final miId = context.watch<AuthProvider>().usuario?.id;
    final esMia = miId != null && miId == resena.userId;
    final color = ResenaDisplayUtils.colorPorUsuario(resena.userId);

    var fotoUrl = resena.userImageUrl;
    if ((fotoUrl == null || fotoUrl.isEmpty) && esMia) {
      // Respaldo: si por algún motivo el backend no trae la foto en esta
      // reseña puntual pero sí sabemos que es la propia, se usa la del
      // perfil actual (misma fuente que Home/Perfil).
      final perfil = context.watch<ProfileProvider>().perfil;
      if (perfil != null && perfil.ImgUrl.isNotEmpty) {
        fotoUrl = perfil.ImgUrl;
      }
    }

    final textoIniciales =
        resena.userName != null && resena.userName!.isNotEmpty
        ? ResenaDisplayUtils.inicialesDeNombre(resena.userName!)
        : ResenaDisplayUtils.iniciales(resena.userId);

    final iniciales = Text(
      textoIniciales,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: radius * 0.65,
      ),
    );

    if (fotoUrl == null || fotoUrl.isEmpty) {
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
