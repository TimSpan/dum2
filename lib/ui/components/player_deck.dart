import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dum/services/song_handler.dart';
import 'package:dum/ui/components/play_pause_button.dart';
import 'package:dum/ui/components/song_progress.dart';
import 'package:flutter/material.dart';
// import 'package:on_audio_query/on_audio_query.dart';

class PlayerDeck extends StatelessWidget {
  final SongHandler songHandler;
  final Function onTap;
  final bool isLast;

  // PlayerDeck 类的构造函数
  const PlayerDeck({
    super.key,
    required this.songHandler,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 StreamBuilder 来根据 mediaItem 流的变化动态构建 UI
    return StreamBuilder<MediaItem?>(
      stream: songHandler.mediaItem.stream,
      builder: (context, snapshot) {
        MediaItem? playingSong = snapshot.data;
        // 如果没有正在播放的歌曲，返回一个空的 widget
        return playingSong == null
            ? const SizedBox.shrink()
            : _buildCard(context, playingSong);
      },
    );
  }

  // 构建主卡片 widget
  Widget _buildCard(BuildContext context, MediaItem playingSong) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: isLast ? 0 : null, // 如果是最后一项，卡片不显示阴影
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // 如果不是最后一项，显示专辑封面
          if (!isLast) _buildArtwork(playingSong),
          // 如果不是最后一项，覆盖专辑封面上一个半透明的容器
          if (!isLast) _buildArtworkOverlay(),
          // 构建卡片的内容部分
          _buildContent(context, playingSong),
        ],
      ),
    );
  }

  // 构建专辑封面 widget
  // 构建专辑封面 widget
  Widget _buildArtwork(MediaItem playingSong) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 专辑封面图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // 圆角裁剪
            child: CachedNetworkImage(
              imageUrl: playingSong.artUri.toString(),
              placeholder: (context, url) => const Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline),
              fit: BoxFit.cover,
              // 确保图片铺满容器
              width: double.infinity,
              // 确保宽度填满父容器
              height: double.infinity, // 确保高度填满父容器
            ),
          ),
          // 半透明遮罩层
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), // 和图片保持一致
              color: Colors.black.withOpacity(0.3), // 半透明黑色遮罩层
            ),
          ),
        ],
      ),
    );
  }

  // 构建专辑封面的覆盖层
  Widget _buildArtworkOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.black.withOpacity(0.5), // 半透明黑色背景
        ),
      ),
    );
  }

  // 构建卡片的主要内容部分
  Widget _buildContent(BuildContext context, MediaItem playingSong) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 构建标题部分
        _buildTitle(context, playingSong),
        // 构建歌曲进度部分
        _buildProgress(playingSong.duration!),
      ],
    );
  }

  // 构建标题部分
  Widget _buildTitle(BuildContext context, MediaItem playingSong) {
    return ListTile(
      onTap: () {
        // 处理点击标题的事件
        int index = songHandler.queue.value.indexOf(playingSong);
        onTap(index); // 点击时执行传入的回调
      },
      tileColor: isLast ? Colors.transparent : null,
      // tileColor: Colors.white,

      // 如果是最后一项，背景透明
      leading: isLast
          ? null
          : DecoratedBox(
              // 标题部分的前置 widget，显示专辑封面
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                // color: Colors.white
                color: isLast
                    ? Colors.transparent
                    : Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  height: 45,
                  width: 45,
                  // 将 Uri 转换为 String
                  imageUrl: playingSong.artUri.toString(),
                  placeholder: (context, url) => const Icon(Icons.image),
                  // 可以使用占位符
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error_outline),

                  // 图片淡入效果
                  fit: BoxFit.cover, // 图片填充方式
                ),
              )),
      title: Text(
        isLast ? "" : playingSong.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // 防止文本溢出
        style: const TextStyle(
          color: Colors.white, // 显式设置标题文字为白色
          // fontSize: 16.0, // 可以根据需要调整字体大小
        ),
      ),
      subtitle: playingSong.artist == null
          ? null
          : Text(isLast ? "" : playingSong.artist!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white)),
      trailing: isLast
          ? null
          : SizedBox(
              height: 50,
              width: 50,
              child: _buildTrailingWidget(context, playingSong),
            ),
    );
  }

  // 构建尾部 widget，包括播放进度和播放/暂停按钮
  Widget _buildTrailingWidget(BuildContext context, MediaItem playingSong) {
    return Stack(
      children: [
        StreamBuilder<Duration>(
          stream: AudioService.position, // 监听音频播放进度
          builder: (context, durationSnapshot) {
            if (durationSnapshot.hasData) {
              // 根据音频播放进度计算歌曲进度
              double progress = durationSnapshot.data!.inMilliseconds /
                  playingSong.duration!.inMilliseconds;
              return Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  strokeWidth: 3,
                  backgroundColor: isLast
                      ? Colors.transparent
                      : Theme.of(context).hoverColor,
                  value: progress, // 显示当前进度
                ),
              );
            }
            return const SizedBox.shrink(); // 如果没有进度数据，返回空 widget
          },
        ),
        Center(
          // 播放/暂停按钮
          child: PlayPauseButton(
            size: 30,
            songHandler: songHandler,
          ),
        ),
      ],
    );
  }

  // 构建歌曲进度部分
  Widget _buildProgress(Duration totalDuration) {
    return ListTile(
      title: isLast
          ? null
          : SongProgress(
              // 使用 SongProgress widget 显示进度条
              totalDuration: totalDuration,
              songHandler: songHandler),
    );
  }
}
