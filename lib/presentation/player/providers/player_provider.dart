import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

part 'player_provider.g.dart';

@riverpod
class PlayerController extends _$PlayerController {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ChewieController? get chewieController => _chewieController;

  @override
  FutureOr<ChewieController> build() {
    ref.onDispose(() {
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
    });
    throw UnimplementedError();
  }

  Future<void> initialize(String url) async {
    state = const AsyncLoading();
    
    try {
      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      state = AsyncData(_chewieController!);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void togglePlay() {
    if (_videoPlayerController == null || _chewieController == null) return;
    if (_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    } else {
      _videoPlayerController!.play();
    }
    state = AsyncData(_chewieController!);
  }

  void seekTo(Duration position) {
    if (_videoPlayerController == null || _chewieController == null) return;
    _videoPlayerController!.seekTo(position);
    state = AsyncData(_chewieController!);
  }

  void seekRelative(Duration offset) {
    if (_videoPlayerController == null || _chewieController == null) return;
    final currentPosition = _videoPlayerController!.value.position;
    final duration = _videoPlayerController!.value.duration;
    final newPosition = currentPosition + offset;
    
    if (newPosition < Duration.zero) {
      seekTo(Duration.zero);
    } else if (newPosition > duration) {
      seekTo(duration);
    } else {
      seekTo(newPosition);
    }
  }
}