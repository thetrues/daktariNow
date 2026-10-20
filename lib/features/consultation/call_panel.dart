import '../../app/locale_controller.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/consultation.dart';
import '../../shared/widgets/avatar.dart';

enum _CallState { idle, connecting, connected, ended }

/// Voice/video call for a consultation, over LiveKit. The API only issues a
/// room token to the two participants once the doctor has started.
class CallPanel extends ConsumerStatefulWidget {
  const CallPanel({
    super.key,
    required this.consultationId,
    required this.type,
    required this.remoteName,
    required this.localName,
    required this.inProgress,
  });

  final String consultationId;
  final ConsultationType type;
  final String remoteName;
  final String localName;

  /// Joining is only possible once the doctor has started the consultation.
  final bool inProgress;

  @override
  ConsumerState<CallPanel> createState() => _CallPanelState();
}

class _CallPanelState extends ConsumerState<CallPanel> {
  Room? _room;
  EventsListener<RoomEvent>? _events;
  _CallState _state = _CallState.idle;
  String? _error;
  final _started = Stopwatch();
  Timer? _ticker;

  bool get _isVideo => widget.type == ConsultationType.video;

  @override
  void dispose() {
    _ticker?.cancel();
    _leave(silent: true);
    super.dispose();
  }

  Future<void> _join() async {
    setState(() {
      _state = _CallState.connecting;
      _error = null;
    });
    try {
      final creds = await ref
          .read(consultationRepositoryProvider)
          .callToken(widget.consultationId);
      final room = Room(
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );
      _room = room;
      room.addListener(_onRoomChanged);
      _events = room.createListener()
        ..on<RoomDisconnectedEvent>((_) {
          if (mounted && _state != _CallState.ended) {
            setState(() => _state = _CallState.ended);
          }
        });

      await room.connect(creds.url, creds.token);
      // Browsers block audio until a user gesture; the Join tap counts.
      if (!room.canPlaybackAudio) await room.startAudio();

      var micBlocked = false;
      var cameraBlocked = false;
      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
      } catch (_) {
        micBlocked = true;
      }
      if (creds.video) {
        try {
          await room.localParticipant?.setCameraEnabled(true);
        } catch (_) {
          cameraBlocked = true;
        }
      }
      _started
        ..reset()
        ..start();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      if (!mounted) return;
      final l = context.l10n;
      setState(() {
        _state = _CallState.connected;
        _error = switch ((micBlocked, cameraBlocked)) {
          (true, true) => l.allowMicCamera,
          (true, false) => l.allowMic,
          (false, true) => l.allowCamera,
          _ => null,
        };
      });
    } catch (e) {
      await _leave(silent: true);
      if (!mounted) return;
      setState(() {
        _state = _CallState.idle;
        _error = e is ApiException ? e.message : context.l10n.callConnectFailed;
      });
    }
  }

  void _onRoomChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _leave({bool silent = false}) async {
    _ticker?.cancel();
    _started.stop();
    final room = _room;
    _room = null;
    await _events?.dispose();
    _events = null;
    if (room != null) {
      room.removeListener(_onRoomChanged);
      await room.disconnect();
      await room.dispose();
    }
    if (!silent && mounted) setState(() => _state = _CallState.ended);
  }

  Future<void> _toggleMic() async {
    final p = _room?.localParticipant;
    if (p == null) return;
    try {
      await p.setMicrophoneEnabled(!p.isMicrophoneEnabled());
      setState(() => _error = null);
    } catch (_) {
      setState(() => _error = context.l10n.micBlocked);
    }
  }

  Future<void> _toggleCam() async {
    final p = _room?.localParticipant;
    if (p == null) return;
    try {
      await p.setCameraEnabled(!p.isCameraEnabled());
      setState(() => _error = null);
    } catch (_) {
      setState(() => _error = context.l10n.cameraBlocked);
    }
  }

  VideoTrack? _videoOf(Participant? p) {
    if (p == null) return null;
    for (final pub in p.videoTrackPublications) {
      final track = pub.track;
      if (track is VideoTrack && !pub.muted) return track;
    }
    return null;
  }

  String get _elapsed {
    final s = _started.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final room = _room;
    final remote = room?.remoteParticipants.values.firstOrNull;
    final remoteVideo = _videoOf(remote);
    final localVideo = _videoOf(room?.localParticipant);
    final connected = _state == _CallState.connected;
    final l = context.l10n;

    final status = switch (_state) {
      _CallState.idle =>
        widget.inProgress ? l.callReady : l.callOpensWhenStarted,
      _CallState.connecting => l.connecting,
      _CallState.connected => remote == null
          ? l.waitingToJoin(widget.remoteName, _elapsed)
          : remote.isSpeaking
              ? l.callSpeaking(_elapsed)
              : l.callConnected(_elapsed),
      _CallState.ended => l.callEnded,
    };

    // 16:9 is too short on phones for the avatar, status, banner and
    // controls, so keep a sensible minimum height.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final height = _isVideo
            ? (w * 9 / 16).clamp(320.0, 520.0)
            : (w * 6 / 16).clamp(240.0, 300.0);
        return SizedBox(
          height: height,
          child: _buildCall(
            context,
            text,
            room,
            remote,
            remoteVideo,
            localVideo,
            connected,
            status,
          ),
        );
      },
    );
  }

  Widget _buildCall(
    BuildContext context,
    TextTheme text,
    Room? room,
    RemoteParticipant? remote,
    VideoTrack? remoteVideo,
    VideoTrack? localVideo,
    bool connected,
    String status,
  ) {
    final l = context.l10n;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF15302E),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (remoteVideo != null)
            VideoTrackRenderer(remoteVideo, fit: VideoViewFit.cover)
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: remote?.isSpeaking ?? false
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Avatar.fromName(
                      widget.remoteName,
                      size: _isVideo ? 84 : 64,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.remoteName,
                    style: text.titleSmall?.copyWith(color: Colors.white),
                  ),
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          if (remoteVideo != null)
            Positioned(
              left: 14,
              top: 12,
              child: Text(
                status,
                style: text.labelMedium?.copyWith(color: Colors.white),
              ),
            ),
          if (_isVideo && connected)
            Positioned(
              right: 12,
              top: 12,
              width: 120,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: const Color(0xFF244744),
                  child: localVideo != null
                      ? VideoTrackRenderer(localVideo, fit: VideoViewFit.cover)
                      : const Icon(
                          Icons.videocam_off_rounded,
                          color: Colors.white54,
                        ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 72,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!, style: text.bodySmall),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!connected)
                  FilledButton.icon(
                    onPressed:
                        widget.inProgress && _state != _CallState.connecting
                        ? _join
                        : null,
                    icon: _state == _CallState.connecting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(widget.type.icon),
                    label: Text(
                      _state == _CallState.ended ? l.rejoinCall : l.joinCall,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(150, 44),
                    ),
                  )
                else ...[
                  _control(
                    room?.localParticipant?.isMicrophoneEnabled() ?? false
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    l.microphone,
                    _toggleMic,
                  ),
                  if (_isVideo)
                    _control(
                      room?.localParticipant?.isCameraEnabled() ?? false
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      l.camera,
                      _toggleCam,
                    ),
                  _control(
                    Icons.call_end_rounded,
                    l.leaveCall,
                    _leave,
                    color: AppColors.danger,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _control(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: color ?? Colors.white24,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
      ),
    );
  }
}
