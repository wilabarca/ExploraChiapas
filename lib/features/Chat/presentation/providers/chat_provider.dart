import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
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

  ChatProvider(this._enviarMensajeUseCase);

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

  ChatStatus _status = ChatStatus.idle;
  ChatStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> enviarMensaje(String texto) async {
    final textoLimpio = texto.trim();
    if (textoLimpio.isEmpty) return;

    _mensajes.add(ChatMensaje(
      contenido: textoLimpio,
      hora: _horaActual(),
      tipo: BubbleType.user,
    ));
    _status = ChatStatus.enviando;
    _errorMessage = null;
    notifyListeners();

    final result = await _enviarMensajeUseCase(textoLimpio);

    result.fold(
      (failure) {
        _status = ChatStatus.error;
        _errorMessage = failure.message;
        _mensajes.add(ChatMensaje(
          contenido: 'No pude generar tu itinerario (${failure.message}). '
              'Intenta de nuevo.',
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
      },
    );

    notifyListeners();
  }

  static String _horaActual() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final periodo = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $periodo';
  }
}
