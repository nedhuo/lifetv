import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/video.dart';
import 'video_card.dart';

class VideoGridView extends StatelessWidget {
  final List<Video> videos;

  const VideoGridView({
    super.key,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(MediaQuery.of(context).size.width),
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoCard(video: video);
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    if (width < 1500) return 4;
    return 5;
  }
}

class VideoItem {
  final String id;
  final String title;
  final String coverUrl;
  final Duration duration;

  const VideoItem({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.duration,
  });
}