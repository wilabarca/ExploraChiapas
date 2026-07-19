import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negocio.dart';
import '../../domain/usecases/obtener_negocio.dart';
import '../../../../core/di/injector.dart';
import '../widgets/negocio_card.dart';
import './negocio_datalle_page.dart';

class NegocioListaPage extends StatefulWidget {
  final String tipoNegocioId;
  final String tituloTipo;

  const NegocioListaPage({
    super.key,
    required this.tipoNegocioId,
    required this.tituloTipo,
  });

  @override
  State<NegocioListaPage> createState() => _NegocioListaPageState();
}

class _NegocioListaPageState extends State<NegocioListaPage> {
  final _obtenerNegocios = getIt<ObtenerNegocios>();
  final _busquedaCtrl = TextEditingController();

  late Future<List<Negocio>> _future;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar({String? busqueda}) {
    setState(() {
      _future =
          _obtenerNegocios(
            tipoNegocioId: widget.tipoNegocioId,
            busqueda: busqueda,
          ).then(
            (either) => either.fold(
              (failure) => throw Exception(failure.message),
              (negocios) => negocios,
            ),
          );
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery: ancho de pantalla para adaptar el layout.
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      // ── Header consistente con el resto de la app ─────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.tituloTipo,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _busquedaCtrl,
              onSubmitted: (value) => _cargar(busqueda: value),
              decoration: InputDecoration(
                hintText: 'Buscar ${widget.tituloTipo.toLowerCase()}...',
                hintStyle: TextStyle(color: AppColors.textHint(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.primary(context)),
                filled: true,
                fillColor: AppColors.background(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Negocio>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary(context)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No se pudo cargar la información.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary(context)),
                      ),
                    ),
                  );
                }

                final negocios = snapshot.data ?? [];

                if (negocios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin resultados por ahora',
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  );
                }

                // Tablet: GridView 2 columnas. Móvil: lista vertical.
                if (isTablet) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 2.6,
                        ),
                    itemCount: negocios.length,
                    itemBuilder: (context, i) => NegocioCard(
                      negocio: negocios[i],
                      onTap: () => _irADetalle(negocios[i].id),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: negocios.length,
                  itemBuilder: (context, i) => NegocioCard(
                    negocio: negocios[i],
                    onTap: () => _irADetalle(negocios[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _irADetalle(String negocioId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NegocioDetallePage(negocioId: negocioId),
      ),
    );
  }
}
