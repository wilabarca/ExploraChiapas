import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import 'mapa_ruta_page.dart';
import 'alternativas_menos_concurridas_page.dart';
import '../../../favoritos/domain/entities/favorito.dart';
import '../../../favoritos/presentation/providers/favoritos_provider.dart';
import '../../../../core/utils/uuid_utils.dart';
import '../../domain/usecases/get_ubicacion_destino_usecase.dart';
import '../../../resena/domain/entities/DestinoResenaEntity.dart';
import '../../../resena/presentation/pages/escribir_resena_page.dart';
import '../../../resena/presentation/providers/ResenasProvider.dart';
import '../../../resena/presentation/widgets/resena_card.dart';
import '../../../resena/presentation/widgets/star_rating.dart';

class LugarDetailPage extends StatefulWidget {
  final String id;
  final String nombre;
  final String categoria;
  final double calificacion;
  final String imageUrl;
  final String? descripcion;
  final int totalResenas;
  final double? lat;
  final double? lng;

  final String? targetType;
  final String? categoryId;
  final String? locationId;
  final bool isSaturated;

  const LugarDetailPage({
    super.key,
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.calificacion,
    required this.imageUrl,
    required this.targetType,
    this.descripcion,
    this.totalResenas = 0,
    this.lat,
    this.lng,
    this.categoryId,
    this.locationId,
    this.isSaturated = false,
  });

  @override
  State<LugarDetailPage> createState() => _LugarDetailPageState();
}

class _LugarDetailPageState extends State<LugarDetailPage>
    with TickerProviderStateMixin {
  bool get _esResenable => widget.targetType != null && esUuidValido(widget.id);

  // ── Animaciones de entrada ────────────────────────────────────────────────
  late final AnimationController _entryCtrl;
  late final Animation<double> _headerAnim;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _infoSlide;
  late final Animation<double> _infoFade;
  late final Animation<Offset> _reviewsSlide;
  late final Animation<double> _reviewsFade;

  // ── Estado ────────────────────────────────────────────────────────────────
  bool _ubicandoLugar = false;
  bool _favPresionado = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    ));
    _contentFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.70, curve: Curves.easeOut),
    );

    _infoSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
    ));
    _infoFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
    );

    _reviewsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    ));
    _reviewsFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _entryCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_esResenable) {
        context.read<ResenasProvider>().cargarResenas(
          targetType: widget.targetType!,
          targetId: widget.id,
        );
      }
      final favProvider = context.read<FavoritosProvider>();
      if (favProvider.status == FavoritosStatus.idle) {
        favProvider.cargarFavoritos();
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Lógica de negocio (sin cambios) ──────────────────────────────────────

  void _irAEscribirResena() {
    if (!_esResenable) return;
    final destino = DestinoResenaEntity(
      id: widget.id,
      nombre: widget.nombre,
      ubicacion: widget.categoria,
      imageUrl: widget.imageUrl,
      calificacion: widget.calificacion,
      totalResenas: widget.totalResenas,
      tipo: widget.categoria,
      targetType: widget.targetType!,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EscribirResenaPage(destino: destino)),
    );
  }

  bool get _tieneAlternativasDisponibles =>
      widget.isSaturated &&
      widget.categoryId != null &&
      esUuidValido(widget.id);

  void _verAlternativas() {
    if (!_tieneAlternativasDisponibles) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlternativasMenosConcurridasPage(
          destinoId: widget.id,
          destinoNombre: widget.nombre,
          categoryId: widget.categoryId!,
          destinoLocationId: widget.locationId,
        ),
      ),
    );
  }

  bool get _tieneCoords => widget.lat != null && widget.lng != null;
  bool get _tieneLocationId =>
      widget.locationId != null && widget.locationId!.trim().isNotEmpty;
  bool get _puedeIrAlLugar => _tieneCoords || _tieneLocationId;

  Future<void> _irAlLugar() async {
    if (_ubicandoLugar) return;
    if (_tieneCoords) {
      _abrirMapaRuta(widget.lat!, widget.lng!);
      return;
    }
    if (!_tieneLocationId) return;
    setState(() => _ubicandoLugar = true);
    final result =
        await getIt<GetUbicacionDestinoUseCase>()(id: widget.locationId!);
    if (!mounted) return;
    setState(() => _ubicandoLugar = false);
    result.fold(
      (_) => _mostrarError(
          'No se pudo obtener la ubicación de este lugar. Intenta de nuevo.'),
      (ubicacion) {
        if (!ubicacion.tieneCoordenadasValidas) {
          _mostrarError('Este lugar todavía no tiene coordenadas registradas.');
          return;
        }
        _abrirMapaRuta(ubicacion.latitude, ubicacion.longitude);
      },
    );
  }

  void _abrirMapaRuta(double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapaRutaPage(nombre: widget.nombre, destLat: lat, destLng: lng),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.40;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ── Contenido principal ──────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Imagen hero
                SliverToBoxAdapter(child: _buildHero(imageH)),

                // Tarjeta de contenido
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -28),
                    child: SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: _buildContentCard(isDark),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Botones flotantes (back + favorito) ──────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FloatButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      Consumer<FavoritosProvider>(
                        builder: (context, favProvider, _) {
                          final esFav = favProvider.esFavorito(
                            FavoritoTargetType.destination,
                            widget.id,
                          );
                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _favPresionado = true),
                            onTapUp: (_) =>
                                setState(() => _favPresionado = false),
                            onTapCancel: () =>
                                setState(() => _favPresionado = false),
                            onTap: () => favProvider.toggleFavorito(
                              targetType: FavoritoTargetType.destination,
                              targetId: widget.id,
                            ),
                            child: AnimatedScale(
                              scale: _favPresionado ? 0.85 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: _FloatButton(
                                icon: esFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                iconColor:
                                    esFav ? Colors.red : Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Barra inferior de acciones ────────────────────────────────────
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ── Hero con imagen + gradiente + nombre ──────────────────────────────────

  Widget _buildHero(double imageH) {
    return FadeTransition(
      opacity: _headerAnim,
      child: SizedBox(
        height: imageH,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen
            _ImageCarousel(imageUrls: [widget.imageUrl]),

            // Gradiente inferior → funde con el contenido
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Nombre + categoría en la parte baja de la imagen
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.categoria.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tarjeta blanca con todo el contenido ─────────────────────────────────

  Widget _buildContentCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle decorativo
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating + reseñas
                SlideTransition(
                  position: _infoSlide,
                  child: FadeTransition(
                    opacity: _infoFade,
                    child: _buildRatingRow(),
                  ),
                ),

                // Banner saturación
                if (_tieneAlternativasDisponibles) ...[
                  const SizedBox(height: 16),
                  SlideTransition(
                    position: _infoSlide,
                    child: FadeTransition(
                      opacity: _infoFade,
                      child: _BannerAlternativas(
                          onVerAlternativas: _verAlternativas),
                    ),
                  ),
                ],

                // Descripción
                if (widget.descripcion != null &&
                    widget.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _infoSlide,
                    child: FadeTransition(
                      opacity: _infoFade,
                      child: _buildDescripcion(),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Divider(color: AppColors.borderSubtle(context)),
                const SizedBox(height: 20),

                // Sección reseñas
                SlideTransition(
                  position: _reviewsSlide,
                  child: FadeTransition(
                    opacity: _reviewsFade,
                    child: _buildResenasSection(),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fila de rating ────────────────────────────────────────────────────────

  Widget _buildRatingRow() {
    return Row(
      children: [
        StarRating(
          rating: widget.calificacion,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          widget.calificacion.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '(${widget.totalResenas} reseñas)',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        if (_esResenable)
          GestureDetector(
            onTap: _irAEscribirResena,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 14,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Reseñar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Descripción ───────────────────────────────────────────────────────────

  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Acerca de este lugar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle(context),
            ),
          ),
          child: Text(
            widget.descripcion!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }

  // ── Sección de reseñas ────────────────────────────────────────────────────

  Widget _buildResenasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_outline_rounded,
              size: 18,
              color: AppColors.primary(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Reseñas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (!_esResenable)
          _EmptyState(
            icon: Icons.rate_review_outlined,
            mensaje: 'Este lugar aún no admite reseñas.',
          )
        else
          Consumer<ResenasProvider>(
            builder: (context, provider, _) {
              if (provider.status == ResenasStatus.loading) {
                return const _ResenasLoadingSkeleton();
              }
              if (provider.resenas.isEmpty) {
                return _EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  mensaje: '¡Sé el primero en dejar una reseña!',
                  accion: 'Escribir reseña',
                  onAccion: _irAEscribirResena,
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < provider.resenas.length; i++)
                    _AnimatedResenaCard(
                      resena: ResenaCard(resena: provider.resenas[i]),
                      delay: Duration(milliseconds: 80 * i),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  // ── Barra de acciones inferior ────────────────────────────────────────────

  Widget _buildBottomBar() {
    final irBtn = _ActionButton(
      label: _ubicandoLugar ? 'Ubicando...' : 'Ir al lugar',
      icon: _ubicandoLugar
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.near_me_rounded, color: Colors.white, size: 20),
      color: const Color(0xFF1565C0),
      onTap: _ubicandoLugar ? null : _irAlLugar,
    );

    final resenaBtn = _ActionButton(
      label: 'Dejar reseña',
      icon: const Icon(Icons.rate_review_rounded, color: Colors.white, size: 20),
      color: AppColors.primary(context),
      onTap: _irAEscribirResena,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_puedeIrAlLugar) ...[
              Expanded(child: irBtn),
              if (_esResenable) const SizedBox(width: 12),
            ],
            if (_esResenable) Expanded(child: resenaBtn),
          ],
        ),
      ),
    );
  }
}

// ── Botón flotante (back / favorito) ─────────────────────────────────────────

class _FloatButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _FloatButton({required this.icon, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: 19,
        ),
      ),
    );
  }
}

// ── Botón de acción inferior ──────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) {
        setState(() => _presionado = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.onTap == null
                ? widget.color.withValues(alpha: 0.5)
                : widget.color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.onTap == null
                ? null
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reseña con animación de entrada ──────────────────────────────────────────

class _AnimatedResenaCard extends StatefulWidget {
  final Widget resena;
  final Duration delay;

  const _AnimatedResenaCard({required this.resena, required this.delay});

  @override
  State<_AnimatedResenaCard> createState() => _AnimatedResenaCardState();
}

class _AnimatedResenaCardState extends State<_AnimatedResenaCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: widget.resena),
      ),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String mensaje;
  final String? accion;
  final VoidCallback? onAccion;

  const _EmptyState({
    required this.icon,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle(context)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textHint(context)),
          const SizedBox(height: 10),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAccion,
              child: Text(
                accion!,
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Skeleton de carga de reseñas ──────────────────────────────────────────────

class _ResenasLoadingSkeleton extends StatefulWidget {
  const _ResenasLoadingSkeleton();

  @override
  State<_ResenasLoadingSkeleton> createState() =>
      _ResenasLoadingSkeletonState();
}

class _ResenasLoadingSkeletonState extends State<_ResenasLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_anim),
      child: Column(
        children: List.generate(
          2,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Carrusel de imágenes del header ──────────────────────────────────────────

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _pageCtrl = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagenes =
        widget.imageUrls.where((url) => url.trim().isNotEmpty).toList();

    if (imagenes.isEmpty) {
      return Container(
        color: AppColors.primaryContainer(context),
        child: Center(
          child: Icon(
            Icons.landscape_outlined,
            size: 56,
            color: AppColors.primary(context).withValues(alpha: 0.4),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: imagenes.length,
          onPageChanged: (i) => setState(() => _pagina = i),
          itemBuilder: (_, i) => Image.network(
            imagenes[i],
            fit: BoxFit.cover,
            loadingBuilder: (_, child, prog) {
              if (prog == null) return child;
              return Container(
                color: AppColors.primaryContainer(context),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.primaryContainer(context)),
          ),
        ),
        if (imagenes.length > 1)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagenes.length, (i) {
                final activo = i == _pagina;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: activo ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: activo
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ── Banner de destino saturado ────────────────────────────────────────────────

class _BannerAlternativas extends StatefulWidget {
  final VoidCallback onVerAlternativas;
  const _BannerAlternativas({required this.onVerAlternativas});

  @override
  State<_BannerAlternativas> createState() => _BannerAlternativasState();
}

class _BannerAlternativasState extends State<_BannerAlternativas> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) {
        setState(() => _presionado = false);
        widget.onVerAlternativas();
      },
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedScale(
        scale: _presionado ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups_outlined,
                    color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lugar muy concurrido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver alternativas menos concurridas',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }
}
