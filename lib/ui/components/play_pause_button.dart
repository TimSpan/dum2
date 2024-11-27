import 'package:audio_service/audio_service.dart';
import 'package:dum/services/song_handler.dart';
import 'package:flutter/material.dart';

// PlayPauseButton 类负责显示播放/暂停按钮
class PlayPauseButton extends StatelessWidget {
  // 控制播放的 SongHandler 实例
  final SongHandler songHandler;

  // 按钮的大小
  final double size;

  // 构造函数，初始化 PlayPauseButton
  const PlayPauseButton({
    super.key,
    required this.size,
    required this.songHandler,
  });

  // 构建方法，用于创建 widget
  @override
  Widget build(BuildContext context) {
    // StreamBuilder 监听播放状态的变化
    return StreamBuilder<PlaybackState>(
      stream: songHandler.playbackState.stream,
      builder: (context, snapshot) {
        // 检查 snapshot 中是否有数据
        if (snapshot.hasData) {
          // 从播放状态中获取当前的播放状态
          bool playing = snapshot.data!.playing;

          // 返回一个 IconButton，按下时切换播放/暂停
          return IconButton(
            onPressed: () {
              // 根据当前播放状态切换播放/暂停
              if (playing) {
                songHandler.pause();
              } else {
                songHandler.play();
              }
            },
            // 根据播放状态显示播放或暂停的图标
            icon: playing
                ? Icon(Icons.pause_rounded, size: size)
                : Icon(Icons.play_arrow_rounded, size: size),
          );
        } else {
          // 如果 snapshot 中没有数据，返回一个空的 SizedBox
          return const SizedBox.shrink();
        }
      },
    );
  }
}
