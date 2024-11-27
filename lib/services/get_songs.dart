import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:dum/services/request_song_permission.dart';
import 'package:dum/services/song_to_media_item.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// 异步函数，用于获取表示歌曲的 MediaItem 列表
Future<List<MediaItem>> getSongs() async {
  try {

    // 确保必要的权限已被授予
    await requestSongPermission();

    // 用于存储 MediaItem（表示歌曲）的列表
    final List<MediaItem> songs = [];

    // 创建 OnAudioQuery 实例，用于查询歌曲信息
    final OnAudioQuery onAudioQuery = OnAudioQuery();

    // 使用 OnAudioQuery 查询设备上的歌曲信息
    final List<SongModel> songModels = await onAudioQuery.querySongs();
    // 打印查询到的歌曲模型信息
    print("songModels________________$jsonEncode(songModels)");

    // 将每个 SongModel 转换为 MediaItem，并添加到歌曲列表中
    for (final SongModel songModel in songModels) {
      final MediaItem song = await songToMediaItem(songModel);
      songs.add(song);
      // 打印歌曲的标题、艺术家和 ID
      print("Song Title:${song} ${song.title}, Artist: ${song.artist}, ID: ${song.id}, artUri: ${song.artUri}");
      // 打印歌曲标题
      // print("Song Title:${song}");
    }

    // 返回歌曲列表
    return songs;
  } catch (e) {
    // 处理查询过程中发生的任何错误
    debugPrint('获取歌曲时出错: $e');
    return []; // 如果出错，返回一个空列表
  }
}
