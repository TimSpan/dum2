import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 请求音频和存储权限
Future<void> requestSongPermission() async {
  try {
    // 检查音频和存储权限是否已被授予
    final bool audioGranted = await Permission.audio.isGranted;
    final bool storageGranted = await Permission.storage.isGranted;

    // 如果权限没有被授予，则请求权限
    if (!audioGranted || !storageGranted) {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      // 如果权限被永久拒绝，则打开应用设置
      if (statuses[Permission.audio] == PermissionStatus.permanentlyDenied ||
          statuses[Permission.storage] == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
    }
  } catch (e) {
    // 处理请求权限过程中发生的任何错误
    debugPrint('请求音频权限时出错: $e');
  }
}
