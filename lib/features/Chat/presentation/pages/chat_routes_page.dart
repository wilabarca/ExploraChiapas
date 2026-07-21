import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/ml_api_client.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_destino_card.dart';
import '../widgets/chat_restaurante_item.dart';
import '../widgets/chat_place_card.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';

class ChatRoutesPage extends StatefulWidget {
  const ChatRoutesPage({super.key});

  @override
  State<ChatRoutesPage> createState() => _ChatRoutesPageState();
}

class _ChatRoutesPageState extends State<ChatRoutesPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Despierta el servidor NLP en segundo plano para que la primera
    // respuesta sea más rápida (Render free-tier duerme tras 15 min).
    getIt<MlApiClient>().warmup();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final texto = _inputCtrl.text;
    if (texto.trim().isEmpty) return;

    _inputCtrl.clear();
    _scrollToBottom();

    await context.read<ChatProvider>().enviarMensaje(texto);

    _scrollToBottom();
  }

  // Separa un texto en segmentos de texto plano y bloques ```card```.
  // Devuelve widgets listos para insertarse en el ListView.
  List<Widget> _parsearConCards(String texto, String hora) {
    final widgets = <Widget>[];
    final regex   = RegExp(r'```card\s*([\s\S]*?)```');
    int lastEnd   = 0;

    for (final match in regex.allMatches(texto)) {
      final antes = texto.substring(lastEnd, match.start).trim();
      if (antes.isNotEmpty) {
        widgets.add(ChatBubble(mensaje: antes, hora: hora, tipo: BubbleType.bot));
      }

      try {
        final data = jsonDecode(match.group(1)!.trim()) as Map<String, dynamic>;
        widgets.add(ChatPlaceCard(data: data));
      } catch (_) {
        // JSON inválido: mostrar como texto normal
        widgets.add(ChatBubble(mensaje: match.group(0)!, hora: hora, tipo: BubbleType.bot));
      }

      lastEnd = match.end;
    }

    final despues = texto.substring(lastEnd).trim();
    if (despues.isNotEmpty) {
      widgets.add(ChatBubble(mensaje: despues, hora: hora, tipo: BubbleType.bot));
    }

    if (widgets.isEmpty) {
      widgets.add(ChatBubble(mensaje: texto, hora: hora, tipo: BubbleType.bot));
    }

    return widgets;
  }

  List<Widget> _construirItems(ChatProvider provider) {
    final items = <Widget>[];

    for (final mensaje in provider.mensajes) {
      if (mensaje.tipo == BubbleType.user) {
        items.add(ChatBubble(
          mensaje: mensaje.contenido,
          hora:    mensaje.hora,
          tipo:    BubbleType.user,
        ));
        continue;
      }

      // Mensaje del bot: intentar parsear cards embebidas
      final cardBlocks = _parsearConCards(mensaje.contenido, mensaje.hora);
      final tieneCards = cardBlocks.any((w) => w is ChatPlaceCard);

      items.addAll(cardBlocks);

      // Fallback: si no hay cards en el texto, renderizar itinerario separado
      if (!tieneCards) {
        for (final actividad in mensaje.itinerario) {
          if (actividad.esDestino) {
            items.add(ChatDestinoCard(
              nombre:   actividad.nombre,
              duracion: '${actividad.tiempoHoras.toStringAsFixed(0)} h',
              precio:   '\$${actividad.costoTotalGrupo.toStringAsFixed(0)} MXN',
            ));
          } else if (actividad.esRestaurante) {
            items.add(ChatRestauranteItem(
              nombre: actividad.nombre,
              tipo:   actividad.tipoComida ?? 'Restaurante',
              precio: '\$${actividad.costoEstimado.toStringAsFixed(0)} MXN pp',
            ));
          }
        }
      }
    }

    if (provider.status == ChatStatus.enviando) {
      items.add(_TypingIndicator());
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final items = _construirItems(provider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const HomeAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: items,
            ),
          ),
          ChatInput(controller: _inputCtrl, onSend: _enviarMensaje),
        ],
      ),
    );
  }
}

// Indicador de "escribiendo..."
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(delay: 0),
              const SizedBox(width: 4),
              _Dot(delay: 200),
              const SizedBox(width: 4),
              _Dot(delay: 400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.primary(context),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
