import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dum/services/song_handler.dart';
import 'package:flutter/material.dart';

class SongProgress extends StatelessWidget {
  final Duration totalDuration; // 歌曲的总时长
  final SongHandler songHandler; // 用于处理歌曲操作的 SongHandler

  const SongProgress({
    super.key,
    required this.totalDuration,
    required this.songHandler,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: AudioService.position, // 监听歌曲播放的当前位置
      builder: (context, positionSnapshot) {
        // 从 stream 中获取当前播放的位置
        Duration? position = positionSnapshot.data;
        // return Text('6666');
        // 返回一个进度条部件，显示歌曲的播放进度
        return ProgressBar(
            // 设置当前进度，如果当前位置为空，则设置为零
            progress: position ?? Duration.zero,
            // 设置歌曲的总时长
            total: totalDuration,
            // 当用户拖动进度条时调用该回调
            onSeek: (position) {
              songHandler.seek(position); // 跳转到指定的位置
            },
            // 定制进度条的外观
            barHeight: 5,
            // 进度条的高度
            thumbRadius: 2.5,
            // 进度条上拇指的半径
            thumbGlowRadius: 5,
            // 拇指光晕的半径
            timeLabelLocation: TimeLabelLocation.below,
            // 时间标签的位置（在进度条下方）
            timeLabelPadding: 10,
            // 时间标签的内边距

            thumbColor: Colors.white,
            // thumbColor 滑动 小圆点的颜色
            baseBarColor: Colors.white.withOpacity(0.24),
            bufferedBarColor: Colors.white.withOpacity(0.24),

            timeLabelTextStyle: const TextStyle(color: Colors.white)); // 进度时间数字文字颜色
      },
    );
  }
}
