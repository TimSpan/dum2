import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

// 异步函数，用于获取歌曲的封面图片
Future<Uri?> getSongArt({
  required int id,
  required ArtworkType type,
  required int quality,
  required int size,
}) async {
  try {
    // 创建 OnAudioQuery 实例，用于查询封面图片
    final OnAudioQuery onAudioQuery = OnAudioQuery();

    // 查询指定歌曲的封面图片数据
    final Uint8List? data = await onAudioQuery.queryArtwork(
      id,
      type,
      quality: quality,
      format: ArtworkFormat.JPEG, // 使用 JPEG 格式
      size: size, // 指定图片大小
    );

    // 用于存储封面图片 Uri 的变量
    Uri? art;

    // 检查封面图片数据是否不为空
    if (data != null) {
      // 创建临时目录，用于存储封面图片文件
      final Directory tempDir = Directory.systemTemp;

      // 在临时目录中创建文件，以歌曲的 id 作为文件名
      final File file = File("${tempDir.path}/$id.jpg");

      // 将封面图片数据写入文件
      await file.writeAsBytes(data);

      // 将封面图片文件的 Uri 赋值给 art 变量
      art = file.uri;

      // 这里假设你已经有了封面图片的网络地址
      // 可以替换成实际的网络图片 URL，或者直接使用接口返回的地址
      // final String imageUrl =
      //     "https://p1.music.126.net/TzPRPDuPmZ2mXGhKG4fzKA==/109951170134422007.jpg";
      //
      // // 直接返回网络地址作为 Uri
      // art = Uri.parse(imageUrl);
    }

    // 返回封面图片的 Uri
    return art;
  } catch (e) {
    // 处理查询过程中发生的任何错误
    debugPrint('获取歌曲封面图片时出错: $e');
    return null; // 如果出错，返回 null
  }
}
