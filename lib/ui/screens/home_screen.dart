// 导入必要的包和文件
import 'package:dum/notifiers/songs_provider.dart'; // 导入歌曲提供者
import 'package:dum/services/song_handler.dart'; // 导入歌曲处理服务
import 'package:dum/ui/components/player_deck.dart'; // 导入播放器控制面板
import 'package:dum/ui/components/songs_list.dart'; // 导入歌曲列表组件
import 'package:dum/ui/screens/search_screen.dart'; // 导入搜索页面
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入系统服务
import 'package:get/get.dart'; // 导入 GetX
import 'package:provider/provider.dart'; // 导入状态管理
import 'package:scroll_to_index/scroll_to_index.dart'; // 导入滚动到指定位置的功能

// 定义 HomeScreen 类，继承自 StatefulWidget
class HomeScreen extends StatefulWidget {
  final SongHandler songHandler;

  // 构造函数，接收一个 SongHandler 实例
  const HomeScreen({super.key, required this.songHandler});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 定义 HomeScreen 的状态类
class _HomeScreenState extends State<HomeScreen> {
  // 创建一个 AutoScrollController，用于平滑滚动
  final AutoScrollController _autoScrollController = AutoScrollController();

  // 滚动到指定索引的位置
  void _scrollTo(int index) {
    _autoScrollController.scrollToIndex(
      index,
      preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 800),
    );
  }

  // HomeScreen 的构建方法
  @override
  Widget build(BuildContext context) {
    // 设置系统UI的外观样式（如状态栏、导航栏）
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.background,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Consumer<SongsProvider>(
        builder: (context, songsProvider, _) {
          // 使用 Scaffold 组件构建页面结构
          return Scaffold(
              appBar: AppBar(
                title: const Text("网易云音乐"),
                actions: [
                  // 搜索按钮，点击后导航到 SearchScreen
                  IconButton(
                    onPressed: () => Get.to(
                      () => SearchScreen(songHandler: widget.songHandler),
                      duration: const Duration(milliseconds: 700),
                      transition: Transition.rightToLeft,
                    ),
                    icon: const Icon(
                      Icons.search_rounded,
                    ),
                  ),
                ],
              ),
              body: songsProvider.isLoading
                  ? _buildLoadingIndicator() // 显示加载指示器  这是 那个 loading 转圈状态
                  : _buildSongsList(songsProvider) // 显示歌曲列表
              // body: _buildSongsList(songsProvider)
              );
        },
      ),
    );
  }

  // 构建加载指示器的方法
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        strokeCap: StrokeCap.round,
      ),
    );
  }

  // 构建歌曲列表的方法，包含播放器控制面板
  Widget _buildSongsList(SongsProvider songsProvider) {
    return Stack(
      children: [
        // 歌曲列表组件，传递歌曲数据和滚动控制器
        SongsList(
          songHandler: widget.songHandler,
          songs: songsProvider.songs,
          autoScrollController: _autoScrollController,
        ),
        _buildPlayerDeck(), // 构建播放器控制面板
      ],
    );
  }

  // 构建播放器控制面板的方法
  Widget _buildPlayerDeck() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        // 显示底部播放控制栏
        PlayerDeck(
          songHandler: widget.songHandler,
          isLast: false,
          onTap: _scrollTo,
        ),
      ],
    );
  }
}
