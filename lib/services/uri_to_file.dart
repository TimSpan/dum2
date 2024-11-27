import 'dart:io';

import 'package:flutter/material.dart';

// 将 URI 转换为 File
Future<File?> uriToFile(Uri? uri) async {
  if (uri == null) {
    return null;
  }

  try {
    // 尝试从 URI 创建一个 File 对象
    return File.fromUri(uri);
  } catch (e) {
    // 处理过程中发生的任何错误
    debugPrint('将 URI 转换为 File 时出错: $e');
    return null;
  }
}
