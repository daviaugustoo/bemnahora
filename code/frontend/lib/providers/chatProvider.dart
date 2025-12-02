import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

import '../services/env.dart';

class ChatMessageVM {
  final String id;
  final String pedidoId;
  final String remetenteId;
  final String remetenteTipo;
  final String texto;
  final DateTime enviadoEmUtc;

  ChatMessageVM(
    this.id,
    this.pedidoId,
    this.remetenteId,
    this.remetenteTipo,
    this.texto,
    this.enviadoEmUtc,
  );
}

class ChatProvider extends ChangeNotifier {
  HubConnection? _hub;
  final List<ChatMessageVM> _messages = [];
  String? _currentPedidoId;
  String? _authToken;
  bool _isStarting = false;

  List<ChatMessageVM> get messages => List.unmodifiable(_messages);

  Future<void> connect(String pedidoId, String token) async {
    final previousPedido = _currentPedidoId;
    _currentPedidoId = pedidoId;
    _authToken = token;

    if (_hub == null) {
      _hub = HubConnectionBuilder()
          .withUrl(
            '${Env.apiBaseUrl.replaceFirst('/api', '')}/hubs/chat',
            HttpConnectionOptions(
              accessTokenFactory: () async => _authToken ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      _registerHubHandlers();
    }

    await _ensureConnected();
    await _joinPedido(pedidoId);

    final shouldClear = previousPedido == null || previousPedido != pedidoId;
    await _loadHistorico(pedidoId, clearBeforeLoad: shouldClear);
  }

  Future<void> send(
    String pedidoId,
    String remetenteId,
    String remetenteTipo,
    String texto,
  ) async {
    if (_hub == null) {
      throw Exception('Conexão do chat não foi iniciada.');
    }

    await _ensureConnected();

    if (_currentPedidoId != pedidoId) {
      await _joinPedido(pedidoId);
      _currentPedidoId = pedidoId;
    }

    try {
      await _hub!.invoke(
        'SendMessage',
        args: [pedidoId, remetenteId, remetenteTipo, texto],
      );
    } catch (e) {
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _hub?.stop();
    } finally {
      _hub = null;
      _currentPedidoId = null;
      _authToken = null;
      _messages.clear();
      notifyListeners();
    }
  }

  Future<void> _ensureConnected() async {
    if (_hub == null) {
      throw Exception('Conexão do chat não foi iniciada.');
    }

    while (_isStarting) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (_hub!.state == HubConnectionState.connected) {
      return;
    }

    try {
      _isStarting = true;
      await _hub!.start();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Falha ao iniciar conexão com o chat: $e');
      }
      await _resetConnection();
      throw Exception('Falha ao conectar ao chat: $e');
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _joinPedido(String pedidoId) async {
    if (_hub == null) {
      throw Exception('Conexão do chat não foi iniciada.');
    }

    try {
      await _hub!.invoke('JoinPedido', args: [pedidoId]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao entrar no pedido $pedidoId: $e');
      }
      throw Exception('Falha ao entrar na sala do pedido: $e');
    }
  }

  Future<void> _loadHistorico(
    String pedidoId, {
    bool clearBeforeLoad = true,
  }) async {
    if (_hub == null) return;

    try {
      final history = await _hub!.invoke('GetHistorico', args: [pedidoId, 50]);

      if (clearBeforeLoad) {
        _messages.clear();
      }

      if (history is List) {
        for (final item in history) {
          final vm = _parseMessage(item);
          if (vm != null) {
            _messages.add(vm);
          }
        }
        if (history.isNotEmpty || clearBeforeLoad) {
          notifyListeners();
        }
      } else if (clearBeforeLoad) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Falha ao carregar histórico do pedido $pedidoId: $e');
      }
      if (clearBeforeLoad) {
        notifyListeners();
      }
    }
  }

  ChatMessageVM? _parseMessage(dynamic data) {
    if (data == null || data is! Map) return null;

    final map = Map<String, dynamic>.from(data as Map);
    final sentAtRaw = map['enviadoEmUtc']?.toString();

    DateTime sentAt;
    try {
      sentAt = (sentAtRaw != null && sentAtRaw.isNotEmpty)
          ? DateTime.parse(sentAtRaw)
          : DateTime.now().toUtc();
    } catch (_) {
      sentAt = DateTime.now().toUtc();
    }

    return ChatMessageVM(
      map['id']?.toString() ?? '',
      map['pedidoId']?.toString() ?? '',
      map['remetenteId']?.toString() ?? '',
      map['remetenteTipo']?.toString() ?? '',
      map['texto']?.toString() ?? '',
      sentAt,
    );
  }

  void _registerHubHandlers() {
    if (_hub == null) return;

    _hub!.on('ReceiveMessage', (args) {
      if (args == null || args.isEmpty) return;
      final message = _parseMessage(args.first);
      if (message == null) return;

      if (_currentPedidoId != null && message.pedidoId != _currentPedidoId) {
        return;
      }

      _messages.add(message);
      notifyListeners();
    });

    _hub!.onreconnected((_) async {
      if (_currentPedidoId != null) {
        try {
          await _joinPedido(_currentPedidoId!);
          await _loadHistorico(_currentPedidoId!, clearBeforeLoad: false);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Erro ao reinserir na sala após reconexão: $e');
          }
        }
      }
    });

    _hub!.onclose((error) {
      if (error != null && kDebugMode) {
        debugPrint('Conexão com ChatHub encerrada: $error');
      }
    });
  }

  Future<void> _resetConnection() async {
    try {
      await _hub?.stop();
    } catch (_) {}
    _hub = null;
  }
}
