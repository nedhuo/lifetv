import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:chewie/chewie.dart';
import 'providers/player_provider.dart';

class PlayerControls extends ConsumerStatefulWidget {
  final String videoId;

  const PlayerControls({
    super.key,
    required this.videoId,
  });

  @override
  ConsumerState<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends ConsumerState<PlayerControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _handleTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 顶部控制栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopControlBar(videoId: widget.videoId),
              ),
              // 底部控制栏
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomControlBar(videoId: widget.videoId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopControlBar extends ConsumerWidget {
  final String videoId;

  const _TopControlBar({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 16),
          // 视频标题
          Expanded(
            child: Text(
              '视频标题', // TODO: 从 provider 获取视频标题
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 更多选项按钮
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: 显示更多选项菜单
            },
          ),
        ],
      ),
    );
  }
}

class _BottomControlBar extends ConsumerWidget {
  final String videoId;

  const _BottomControlBar({required this.videoId});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : '';
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          playerState.when(
            data: (controller) {
              if (controller.isPlaying) {
                final duration = controller.videoPlayerController.value.duration ?? Duration.zero;
                final position = controller.videoPlayerController.value.position;
                return Row(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    Expanded(
                      child: Slider(
                        value: position.inSeconds.toDouble(),
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          ref.read(playerControllerProvider.notifier).seekTo(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 8),
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {
                  // TODO: 上一集
                },
              ),
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  ref.read(playerControllerProvider.notifier).seekRelative(
                    const Duration(seconds: -10),
                  );
                },
              ),
              IconButton(
                iconSize: 48.w,
                icon: Icon(
                  playerState.when(
                    data: (controller) =>
                        controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    loading: () => Icons.play_arrow,
                    error: (_, __) => Icons.play_arrow,
                  ),
                  color: Colors.white,
                ),
                onPressed: () {
                  ref.read(playerControllerProvider.notifier).togglePlay();
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  ref.read(playerControllerProvider.notifier).seekRelative(
                    const Duration(seconds: 10),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  // TODO: 下一集
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}