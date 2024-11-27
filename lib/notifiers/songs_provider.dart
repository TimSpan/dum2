import 'package:audio_service/audio_service.dart';
import 'package:dum/services/get_songs.dart';
import 'package:dum/services/song_handler.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // 用于处理 JSON 数据
import 'package:http/http.dart' as http; // http 请求依赖

// 定义一个使用 ChangeNotifier 来管理歌曲的类
class SongsProvider extends ChangeNotifier {
  // 私有变量，用于存储歌曲列表
  List<MediaItem> _songs = [];
  List<MediaItem> _songsCopy = [];

  // 获取器，用于访问歌曲列表
  List<MediaItem> get songs => _songs;

  // 私有变量，用于跟踪加载状态
  bool _isLoading = true;

  // 获取器，用于访问加载状态
  bool get isLoading => _isLoading;

  // 定义 API 接口 URL
  final String _apiUrl =
      "https://api.csm.sayqz.com/playlist/track/all?id=6716276773&offset=0&limit=5";

// 异步方法，用于加载歌曲
  Future<void> loadSongs(SongHandler songHandler) async {
    try {
      // 使用 getSongs 函数获取歌曲列表
      _songs = await getSongs();

      // 用加载的歌曲初始化歌曲处理器
      await songHandler.initSongs(songs: _songs);

      // 更新加载状态，标记为加载完成
      _isLoading = false;

      // 通知监听器状态发生了变化
      notifyListeners();
    } catch (e) {
      // 处理加载过程中发生的任何错误
      debugPrint('加载歌曲时出错: $e');
      // 根据需求，这里也可以将 _isLoading 设置为 false
    }
  }
// Future<void> loadSongs(SongHandler songHandler) async {
//   try {
//     // 发起 GET 请求获取数据
//     _songsCopy = await getSongs();
//     print("_songs_copy_____________$_songsCopy");
//     final response = await http.get(Uri.parse(_apiUrl));
//
//     // 检查响应是否成功
//     if (response.statusCode == 200) {
//       // 解析 JSON 数据
//       final data = json.decode(response.body);
//
//       // 验证返回数据格式是否包含 `result`
//       if (data['songs'] != null) {
//         // 将接口返回的歌曲列表转换为 `MediaItem` 列表
//         _songs = (data['songs'] as List).map((item) {
//           return MediaItem(
//             id: item['id'].toString(),
//             title: item['al']?['name'] ?? "未知标题",
//             album: item['al']?['name'] ?? "未知专辑",
//             artist: item['ar'] != null && item['ar'].isNotEmpty
//                 ? item['ar'][0]['name'] // 从 ar 数组中取第一个艺术家名称
//                 : "未知艺术家",
//             // 接口数据中无艺术家字段
//             genre: "推荐",
//             // 自定义设置类型为推荐
//             duration: Duration(milliseconds: item['dt'] ?? 0),
//             artUri: Uri.parse(item['al']?['picUrl']),
//             // dt 字段表示时长（毫秒）
//             //   artUri: Uri.parse(item['al']?['picUrl'] ??
//             //       'https://p1.music.126.net/TzPRPDuPmZ2mXGhKG4fzKA==/109951170134422007.jpg'),
//           );
//         }).toList();
//
//         // 打印 _songs 内容
//         print("歌曲列表: $_songs");
//         // 初始化歌曲处理器
//         await songHandler.initSongs(songs: _songs);
//       } else {
//         throw Exception("接口返回数据格式错误");
//       }
//     } else {
//       throw Exception("HTTP 请求失败，状态码: ${response.statusCode}");
//     }
//
//     // 更新加载状态，标记为加载完成
//     _isLoading = false;
//
//     // 通知监听器状态发生了变化
//     notifyListeners();
//   } catch (e) {
//     // 处理加载过程中发生的任何错误
//     debugPrint('加载歌曲时出错: $e');
//     // 可根据需求，将 _isLoading 设置为 false 以更新 UI
//     _isLoading = false;
//     notifyListeners();
//   }
// }
}