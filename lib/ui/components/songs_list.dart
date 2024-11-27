import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'package:dum/services/song_handler.dart';
import 'package:dum/ui/components/player_deck.dart';
import 'package:dum/ui/components/song_item.dart';
import 'package:dum/utils/formatted_title.dart';

// SongsList 类用于显示歌曲列表
class SongsList extends StatelessWidget {
  final List<MediaItem> songs; // 存储歌曲列表
  final SongHandler songHandler; // 用于处理歌曲操作的 SongHandler
  final AutoScrollController autoScrollController; // 控制自动滚动的控制器

  // SongsList 构造函数
  const SongsList({
    super.key,
    required this.songs,
    required this.songHandler,
    required this.autoScrollController,
  });

  @override
  Widget build(BuildContext context) {
    // 如果没有歌曲，显示消息提示
    return songs.isEmpty
        ? const Center(
      child: Text("You Have No Taste!!!"), // 没有歌曲时显示的文本
    )
        : ListView.builder(
      // 构建一个可滚动的歌曲列表
      controller: autoScrollController,
      physics: const BouncingScrollPhysics(), // 设置弹性滚动效果
      itemCount: songs.length, // 列表项的数量
      itemBuilder: (context, index) {
        MediaItem song = songs[index]; // 获取当前索引的歌曲

        // 根据播放状态构建 SongItem
        return StreamBuilder<MediaItem?>(
          stream: songHandler.mediaItem.stream, // 监听当前播放的歌曲
          builder: (context, snapshot) {
            MediaItem? playingSong = snapshot.data; // 获取当前正在播放的歌曲

            // 如果当前是最后一首歌，使用不同的显示方式
            return index == (songs.length - 1)
                ? _buildLastSongItem(song, playingSong) // 最后一首歌的特殊展示
                : AutoScrollTag(
              // 使用 AutoScrollTag 来实现自动滚动功能
              key: ValueKey(index),
              controller: autoScrollController,
              index: index,
              child:
              _buildRegularSongItem(song, playingSong), // 常规歌曲项
            );
          },
        );
      },
    );
  }

  // 构建最后一首歌的项，包含一个控制面板（PlayerDeck）
  Widget _buildLastSongItem(MediaItem song, MediaItem? playingSong) {
    return Column(
      children: [
        // 显示最后一首歌的 SongItem
        SongItem(
          id: int.parse(song.displayDescription!),
          isPlaying: song == playingSong,
          // 如果这首歌正在播放，设置为 true
          title: formattedTitle(song.title),
          // 格式化歌曲标题
          artist: song.artist,
          // 歌手名称
          onSongTap: () async {
            await songHandler.skipToQueueItem(songs.length - 1); // 跳到队列中的最后一首歌
          },
          art: song.artUri, // 获取歌曲封面
        ),
        // 显示播放器控制面板
        PlayerDeck(
          songHandler: songHandler,
          isLast: true, // 标记这是最后一首歌
          onTap: () {}, // 为空的回调函数
        ),
      ],
    );
  }

  // 构建常规歌曲项
  // Widget _buildRegularSongItem(MediaItem song, MediaItem? playingSong) {
  //   return SongItem(
  //     id: int.parse(song.displayDescription!),
  //     isPlaying: song == playingSong,
  //     // 判断歌曲是否正在播放
  //     title: formattedTitle(song.title),
  //     // 格式化歌曲标题
  //     artist: song.artist,
  //     // 歌手名称
  //     onSongTap: () async {
  //       await songHandler.skipToQueueItem(songs.indexOf(song)); // 跳到队列中的当前歌曲
  //     },
  //     art: song.artUri, // 获取歌曲封面
  //   );
  // }
  Widget _buildRegularSongItem(MediaItem song, MediaItem? playingSong) {
    print("song_______________$song");

    // return SongItem(
    //   id: 31231,
    //   // 提供默认值，避免 null
    //   isPlaying: false,
    //   title: "kevin",
    //   // 如果 title 为 null，使用默认标题
    //   artist: '未知歌手',
    //   // 如果 artist 为 null，使用默认歌手名称
    //   onSongTap: () async {
    //     await songHandler.skipToQueueItem(songs.indexOf(song)); // 跳到队列中的当前歌曲
    //   },
    //   art: song.artUri,
    // );
    return SongItem(
      id: int.parse(song.displayDescription ?? '0'),
      // 提供默认值，避免 null
      isPlaying: song == playingSong,
      title: formattedTitle(song.title ?? '未知标题'),
      // 如果 title 为 null，使用默认标题
      artist: song.artist ?? '未知歌手',
      // 如果 artist 为 null，使用默认歌手名称
      onSongTap: () async {
        await songHandler.skipToQueueItem(songs.indexOf(song)); // 跳到队列中的当前歌曲
      },
      art: song.artUri,
    );
  }
}
