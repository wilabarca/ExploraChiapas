import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/profanity_filter.dart';
import '../../data/datasource/conversacion_remote_datasource.dart';
import '../../domain/entities/actividad_entity.dart';
import '../../domain/usecases/enviar_mensaje_usecase.dart';
import '../widgets/chat_bubble.dart';

class ChatMensaje {
  final String contenido;
  final String hora;
  final BubbleType tipo;
  final List<ActividadEntity> itinerario;

  const ChatMensaje({
    required this.contenido,
    required this.hora,
    required this.tipo,
    this.itinerario = const [],
  });
}

enum ChatStatus { idle, enviando, error }

@injectable
class ChatProvider extends ChangeNotifier {
  final EnviarMensajeUseCase _enviarMensajeUseCase;
  final ConversacionRemoteDatasource _convDatasource;

  ChatProvider(this._enviarMensajeUseCase, this._convDatasource);

  // ── Mensajes visibles ──────────────────────────────────
  final List<ChatMensaje> _mensajes = [
    ChatMensaje(
      contenido: '¡Hola! Soy tu asistente de ExploraChiapas. ¿A donde te '
          'gustaria ir? Por ejemplo:\n"Quiero ir a Suchiapa, somos 2 '
          'personas, presupuesto de \$500, tengo medio dia".',
      hora: _horaActual(),
      tipo: BubbleType.bot,
    ),
  ];
  List<ChatMensaje> get mensajes => List.unmodifiable(_mensajes);

  // ── Historial para Groq (solo rol+contenido, sin datos de UI) ──
  final List<Map<String, String>> _historialGroq = [];

  // ── Estado de conversación persistida ─────────────────
  String? _conversacionId;
  String? get conversacionId => _conversacionId;

  ChatStatus _status = ChatStatus.idle;
  ChatStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Enviar mensaje ─────────────────────────────────────
  Future<void> enviarMensaje(String texto) async {
    final textoLimpio = texto.trim();
    if (textoLimpio.isEmpty) return;

    if (ProfanityFilter.contiene(textoLimpio)) {
      _mensajes.add(ChatMensaje(
        contenido: ProfanityFilter.censurar(textoLimpio),
        hora: _horaActual(),
        tipo: BubbleType.user,
      ));
      _mensajes.add(ChatMensaje(
        contenido: 'Por favor utiliza un lenguaje apropiado para continuar.',
        hora: _horaActual(),
        tipo: BubbleType.bot,
      ));
      notifyListeners();
      return;
    }

    _mensajes.add(ChatMensaje(
      contenido: textoLimpio,
      hora: _horaActual(),
      tipo: BubbleType.user,
    ));
    _status = ChatStatus.enviando;
    _errorMessage = null;
    notifyListeners();

    // Crear conversación en backend al primer mensaje real
    await _asegurarConversacion(textoLimpio);

    final result = await _enviarMensajeUseCase(
      textoLimpio,
      historial: List.unmodifiable(_historialGroq),
    );

    result.fold(
      (failure) {
        _status = ChatStatus.error;
        _errorMessage = failure.message;
        final mensaje = failure is NetworkFailure
            ? 'Sin conexión a internet. Verifica tu red e intenta de nuevo.'
            : failure.message;
        _mensajes.add(ChatMensaje(
          contenido: mensaje,
          hora: _horaActual(),
          tipo: BubbleType.bot,
        ));
      },
      (recomendacion) {
        _status = ChatStatus.idle;
        _mensajes.add(ChatMensaje(
          contenido: recomendacion.mensaje,
          hora: _horaActual(),
          tipo: BubbleType.bot,
          itinerario: recomendacion.itinerario,
        ));
        // Acumular en historial Groq
        _historialGroq.add({'rol': 'user', 'contenido': textoLimpio});
        _historialGroq.add({'rol': 'bot', 'contenido': recomendacion.mensaje});
        // Guardar ambos mensajes en backend (no bloqueante)
        _persistirMensajes(textoLimpio, recomendacion.mensaje);
      },
    );

    notifyListeners();
  }

  // ── Nueva conversación ─────────────────────────────────
  void nuevaConversacion() {
    _mensajes.clear();
    _mensajes.add(ChatMensaje(
      contenido: '¡Hola! Soy tu asistente de ExploraChiapas. ¿A donde te '
          'gustaria ir?',
      hora: _horaActual(),
      tipo: BubbleType.bot,
    ));
    _historialGroq.clear();
    _conversacionId = null;
    _status = ChatStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Cargar conversación del historial ──────────────────
  Future<void> cargarConversacion(String conversacionId) async {
    try {
      final conv = await _convDatasource.obtener(conversacionId);
      _conversacionId = conv.id;
      _mensajes.clear();
      _historialGroq.clear();

      for (final msg in conv.mensajes) {
        final tipo = msg.rol == 'user' ? BubbleType.user : BubbleType.bot;
        _mensajes.add(ChatMensaje(
          contenido: msg.contenido,
          hora: _formatearFecha(msg.creadoEn),
          tipo: tipo,
        ));
        _historialGroq.add({'rol': msg.rol, 'contenido': msg.contenido});
      }

      notifyListeners();
    } catch (_) {
      // Si falla la carga, mantener estado actual
    }
  }

  // ── Helpers privados ───────────────────────────────────
  Future<void> _asegurarConversacion(String primerMensaje) async {
    if (_conversacionId != null) return;
    try {
      final titulo = primerMensaje.length > 60
          ? '${primerMensaje.substring(0, 57)}...'
          : primerMensaje;
      final conv = await _convDatasource.crear(titulo: titulo);
      _conversacionId = conv.id;
    } catch (_) {
      // Sin conexión al backend — el chat sigue funcionando sin persistencia
    }
  }

  Future<void> _persistirMensajes(String userMsg, String botMsg) async {
    if (_conversacionId == null) return;
    try {
      await _convDatasource.agregarMensaje(
        conversacionId: _conversacionId!,
        rol: 'user',
        contenido: userMsg,
      );
      await _convDatasource.agregarMensaje(
        conversacionId: _conversacionId!,
        rol: 'bot',
        contenido: botMsg,
      );
    } catch (_) {
      // Silencioso — el chat no debe interrumpirse por fallo de persistencia
    }
  }

  static String _horaActual() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final periodo = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $periodo';
  }

  static String _formatearFecha(DateTime fecha) {
    final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
    final m = fecha.minute.toString().padLeft(2, '0');
    final periodo = fecha.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $periodo';
  }
}
