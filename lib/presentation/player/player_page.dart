import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_player_widget.dart';
import 'player_controls.dart';

class PlayerPage extends ConsumerStatefulWidget {
  final String videoId;

  const PlayerPage({
    super.key,
    required this.videoId,
  });

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  @override
  void initState() {
    super.initState();
    // 设置全屏和横屏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 恢复系统UI和屏幕方向
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 视频播放器
            Center(
              child: VideoPlayerWidget(
                videoId: widget.videoId,
              ),
            ),
            // 播放控制器
            Positioned.fill(
              child: PlayerControls(
                videoId: widget.videoId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}