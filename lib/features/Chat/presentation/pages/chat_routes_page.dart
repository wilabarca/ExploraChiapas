import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_destino_card.dart';
import '../widgets/chat_restaurante_item.dart';

// Modelo simple de mensaje
class _Mensaje {
  final String contenido;
  final String hora;
  final BubbleType tipo;
  final bool esDestinoCard;
  final bool esRestauranteItem;

  const _Mensaje({
    required this.contenido,
    required this.hora,
    required this.tipo,
    this.esDestinoCard = false,
    this.esRestauranteItem = false,
  });
}

class ChatRoutesPage extends StatefulWidget {
  const ChatRoutesPage({super.key});

  @override
  State<ChatRoutesPage> createState() => _ChatRoutesPageState();
}

class _ChatRoutesPageState extends State<ChatRoutesPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  // ── Conversación ficticia inicial ────────────────────────────────────────
  final List<_Mensaje> _mensajes = [
    const _Mensaje(
      contenido:
          '¡Hola! Soy tu asistente de ExploraChiapas. ¿A dónde te gustaría ir? Por ejemplo:\n"Quiero ir a Suchiapa, somos 2 personas, presupuesto de \$500, tengo medio día".',
      hora: '10:02 AM',
      tipo: BubbleType.bot,
    ),
    const _Mensaje(
      contenido:
          'Busco algo natural cerca de Tuxtla, tal vez unas cascadas para esta tarde.',
      hora: '10:03 AM',
      tipo: BubbleType.user,
    ),
    const _Mensaje(
      contenido:
          '¡Excelente elección! Para una escapada rápida y refrescante, te recomiendo visitar las Cascadas de Agua Azul. Aquí tienes los detalles:',
      hora: '10:03 AM',
      tipo: BubbleType.bot,
    ),
    const _Mensaje(
      contenido: '',
      hora: '',
      tipo: BubbleType.bot,
      esDestinoCard: true,
    ),
    const _Mensaje(
      contenido: '',
      hora: '',
      tipo: BubbleType.bot,
      esRestauranteItem: true,
    ),
  ];

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
    final texto = _inputCtrl.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensajes.add(_Mensaje(
        contenido: texto,
        hora: _horaActual(),
        tipo: BubbleType.user,
      ));
      _isTyping = true;
    });

    _inputCtrl.clear();
    _scrollToBottom();

    // Simula respuesta del bot
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _mensajes.add(_Mensaje(
        contenido:
            'Entendido. Buscando opciones disponibles para ti en Chiapas...',
        hora: _horaActual(),
        tipo: BubbleType.bot,
      ));
    });

    _scrollToBottom();
  }

  String _horaActual() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final periodo = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $periodo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Image.asset(
              'assets/images/ExploraChiapas Logo.png',
              height: 26,
            ),
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
                  placeholder: (_, __) => const Icon(
                    Icons.person,
                    color: Color(0xFF2E7D32),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.person,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _mensajes.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Indicador de escritura
                if (_isTyping && index == _mensajes.length) {
                  return _TypingIndicator();
                }

                final msg = _mensajes[index];

                // Card de destino ficticia
                if (msg.esDestinoCard) {
                  return ChatDestinoCard(
                    nombre: 'Cascadas de Agua Azul',
                    duracion: '3-4 hours',
                    precio: '\$80 MXN',
                    calificacion: 4.8,
                    imageUrl:
                        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
                  );
                }

                // Item de restaurante ficticio
                if (msg.esRestauranteItem) {
                  return ChatRestauranteItem(
                    nombre: 'Restaurante El Taray',
                    tipo: 'Comida Regional',
                    precio: '\$150 MXN pp',
                    imageUrl:
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80',
                  );
                }

                return ChatBubble(
                  mensaje: msg.contenido,
                  hora: msg.hora,
                  tipo: msg.tipo,
                );
              },
            ),
          ),

          // Input
          ChatInput(
            controller: _inputCtrl,
            onSend: _enviarMensaje,
          ),
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
            color: Colors.white,
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

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
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
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
        decoration: const BoxDecoration(
          color: Color(0xFF2E7D32),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}