import 'package:audio_service/audio_service.dart';
import 'package:dum/notifiers/songs_provider.dart'; // 导入歌曲提供者
import 'package:dum/services/song_handler.dart'; // 导入歌曲处理逻辑
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入系统服务
import 'package:provider/provider.dart'; // 导入状态管理
import 'package:dynamic_color/dynamic_color.dart'; // 动态色彩支持
import 'package:get/get.dart'; // 导入 GetX

import 'ui/screens/home_screen.dart'; // 导入主屏幕

// 创建一个 SongHandler 的单例实例
SongHandler _songHandler = SongHandler();

// 应用的入口点
Future<void> main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 AudioService，使用自定义的 SongHandler
  _songHandler = await AudioService.init(
    builder: () => SongHandler(), // 初始化歌曲处理器
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.dum.app',
      androidNotificationChannelName: 'Dum Player', // Android 通知配置
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    ),
  );

  // 运行应用
  runApp(
    MultiProvider(
      providers: [
        // 提供 SongsProvider，用来加载歌曲和管理状态
        ChangeNotifierProvider(
          create: (context) => SongsProvider()..loadSongs(_songHandler),
        ),
      ],
      // 使用 MainApp 作为根组件
      child: const MainApp(),
    ),
  );

  // 设置应用的首选屏幕方向为竖屏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

// 应用的根组件
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 DynamicColorBuilder 构建应用的主题
    return DynamicColorBuilder(
      builder: (ColorScheme? light, ColorScheme? dark) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false, // 禁用调试模式的标志
          darkTheme: ThemeData(
            colorScheme: dark, // 设置深色模式的颜色方案
            useMaterial3: true, // 使用 Material 3 风格
          ),
          // 设置 HomeScreen 作为应用的首页
          home: HomeScreen(songHandler: _songHandler),
        );
      },
    );
  }
}
