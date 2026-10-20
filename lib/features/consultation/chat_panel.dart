import '../../app/locale_controller.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/medical_record.dart';
import '../../shared/widgets/common.dart';

/// Consultation chat over REST. Polls for new messages every few seconds
/// while open; a WebSocket gateway will replace polling in the realtime phase.
class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({
    super.key,
    required this.consultationId,
    required this.myId,
    required this.otherName,
    required this.open,
  });

  final String consultationId;
  final String myId;
  final String otherName;

  /// False once the consultation is completed or cancelled (read-only).
  final bool open;

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  static const _pollEvery = Duration(seconds: 3);

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  final _ids = <String>{};
  Timer? _timer;
  bool _loading = true;
  bool _sending = false;
  bool _fetching = false;
  String? _error;

  ConsultationRepository get _repo => ref.read(consultationRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _fetch();
    if (widget.open) {
      _timer = Timer.periodic(_pollEvery, (_) => _fetch());
    }
  }

  @override
  void didUpdateWidget(ChatPanel old) {
    super.didUpdateWidget(old);
    if (old.open && !widget.open) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final after = _messages.isEmpty ? null : _messages.last.sentAt;
      final fresh = await _repo.messages(widget.consultationId, after: after);
      if (!mounted) return;
      setState(() {
        _error = null;
        _loading = false;
        _add(fresh);
      });
    } catch (e) {
      // Keep polling; show the error only if we have nothing to display.
      if (mounted && _messages.isEmpty) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    } finally {
      _fetching = false;
    }
  }

  void _add(List<ChatMessage> incoming) {
    final added = incoming.where((m) => _ids.add(m.id)).toList();
    if (added.isEmpty) return;
    _messages
      ..addAll(added)
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final sent = await _repo.send(widget.consultationId, body);
      if (!mounted) return;
      _input.clear();
      setState(() => _add([sent]));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    return Column(
      children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _messages.isEmpty
                      ? Center(
                          child: Text(
                            widget.open
                                ? l.sayHello(widget.otherName)
                                : l.noMessages,
                            style: text.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) => _Bubble(
                            message: _messages[i],
                            mine: _messages[i].senderId == widget.myId,
                          ),
                        ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: widget.open
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          onSubmitted: (_) => _send(),
                          textInputAction: TextInputAction.send,
                          maxLength: 4000,
                          buildCounter: (_, {required currentLength,
                                  required isFocused, maxLength}) =>
                              null,
                          decoration: InputDecoration(
                            hintText: l.messageHint(widget.otherName),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: l.send,
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  )
                : Text(
                    l.chatReadOnly,
                    textAlign: TextAlign.center,
                    style:
                        text.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surface,
          border: mine ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text,
                style: text.bodyMedium?.copyWith(color: mine ? Colors.white : null)),
            const SizedBox(height: 2),
            Text(
              DateFormat('h:mm a').format(message.sentAt.toLocal()),
              style: text.labelSmall?.copyWith(
                color: mine ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
