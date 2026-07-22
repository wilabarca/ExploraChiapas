import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasource/conversacion_remote_datasource.dart';
import '../providers/chat_provider.dart';

class HistorialChatPage extends StatefulWidget {
  const HistorialChatPage({super.key});

  @override
  State<HistorialChatPage> createState() => _HistorialChatPageState();
}

class _HistorialChatPageState extends State<HistorialChatPage> {
  late Future<List<ConversacionModel>> _futureConversaciones;

  late final ConversacionRemoteDatasource _ds;

  @override
  void initState() {
    super.initState();
    _ds = getIt<ConversacionRemoteDatasource>();
    _cargar();
  }

  void _cargar() {
    setState(() {
      _futureConversaciones = _ds.listar();
    });
  }

  Future<void> _eliminar(String id) async {
    try {
      await _ds.eliminar(id);
      _cargar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la conversación')),
        );
      }
    }
  }

  void _abrirConversacion(String id) {
    Navigator.pop(context); // cerrar historial
    context.read<ChatProvider>().cargarConversacion(id);
  }

  void _nuevaConversacion() {
    Navigator.pop(context);
    context.read<ChatProvider>().nuevaConversacion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        title: Text(
          'Historial de chats',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        actions: [
          TextButton.icon(
            onPressed: _nuevaConversacion,
            icon: Icon(Icons.add, color: AppColors.primary(context), size: 20),
            label: Text(
              'Nuevo chat',
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ConversacionModel>>(
        future: _futureConversaciones,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary(context),
              ),
            );
          }
          if (snap.hasError) {
            return _ErrorView(onRetry: _cargar);
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return _EmptyView(onNuevo: _nuevaConversacion);
          }
          return RefreshIndicator(
            onRefresh: () async => _cargar(),
            color: AppColors.primary(context),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lista.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.border(context),
                indent: 72,
              ),
              itemBuilder: (context, i) {
                final conv = lista[i];
                return _ConversacionTile(
                  conversacion: conv,
                  onTap: () => _abrirConversacion(conv.id),
                  onDelete: () => _eliminar(conv.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConversacionTile extends StatelessWidget {
  final ConversacionModel conversacion;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversacionTile({
    required this.conversacion,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = _formatFecha(conversacion.actualizadoEn);
    return Dismissible(
      key: Key(conversacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error(context),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.onError(context),
          size: 24,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary(context).withValues(alpha: 0.12),
          child: Icon(
            Icons.chat_bubble_outline,
            color: AppColors.primary(context),
            size: 20,
          ),
        ),
        title: Text(
          conversacion.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          fecha,
          style: TextStyle(color: AppColors.textHint(context), fontSize: 12),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textHint(context),
          size: 20,
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final diff = now.difference(fecha);
    if (diff.inDays == 0) {
      final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
      final m = fecha.minute.toString().padLeft(2, '0');
      final p = fecha.hour < 12 ? 'AM' : 'PM';
      return 'Hoy $h:$m $p';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onNuevo;
  const _EmptyView({required this.onNuevo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textHint(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes conversaciones guardadas',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onNuevo,
            icon: const Icon(Icons.add),
            label: const Text('Iniciar chat nuevo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: AppColors.onPrimary(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 48, color: AppColors.textHint(context)),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar el historial',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Reintentar',
              style: TextStyle(color: AppColors.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
