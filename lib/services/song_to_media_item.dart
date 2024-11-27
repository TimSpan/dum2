import 'package:audio_service/audio_service.dart';
import 'package:dum/services/get_song_art.dart';
import 'package:dum/utils/formatted_title.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// 将 SongModel 转换为 MediaItem
Future<MediaItem> songToMediaItem(SongModel song) async {
  try {
    // 获取歌曲的封面图片
    final Uri? art = await getSongArt(
      id: song.id,
      type: ArtworkType.AUDIO,
      quality: 100,
      size: 300,
    );

    // 创建并返回一个 MediaItem
    return MediaItem(
      // 使用歌曲的 URI 作为 MediaItem 的 ID
      id: song.uri.toString(),

      // 设置获取到的封面图片 URI
      artUri: art,

      // 使用提供的格式化标题工具函数格式化歌曲标题
      title: formattedTitle(song.title).trim(),

      // 设置艺术家、时长和显示的描述
      artist: song.artist,
      duration: Duration(milliseconds: song.duration!),
      displayDescription: song.id.toString(),
    );
  } catch (e) {
    // 处理过程中发生的任何错误
    debugPrint('将 SongModel 转换为 MediaItem 时出错: $e');
    // 如果发生错误，返回一个默认或空的 MediaItem
    return const MediaItem(id: '', title: 'Error', artist: 'Unknown');
  }
}
