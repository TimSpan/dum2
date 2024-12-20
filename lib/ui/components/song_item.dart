import 'package:cached_network_image/cached_network_image.dart';
import 'package:dum/utils/formatted_text.dart';
import 'package:flutter/material.dart';

class SongItem extends StatelessWidget {
  final String? searchedWord; // 用户搜索的关键字（如果有的话）
  final bool isPlaying; // 当前歌曲是否在播放
  final Uri? art; // 歌曲封面图的Uri（如果有的话）
  final String title; // 歌曲标题
  final String? artist; // 歌手名字（如果有的话）
  final int id; // 歌曲的ID
  final VoidCallback onSongTap; // 点击歌曲项的回调函数

  // SongItem 类的构造函数
  const SongItem({
    super.key,
    required this.isPlaying,
    required this.title,
    required this.artist,
    required this.onSongTap,
    required this.id,
    this.searchedWord,
    required this.art,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        // 根据歌曲是否在播放设置列表项的背景颜色
        tileColor: isPlaying
            ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        // 点击列表项时执行 onSongTap 回调
        onTap: () => onSongTap(),
        // 构建前置部件（歌曲封面）
        leading: _buildLeading(),
        // 构建歌曲标题和副标题
        title: _buildTitle(context),
        subtitle: _buildSubtitle(context),
      ),
    );
  }

  // 构建歌曲标题部件，支持高亮搜索关键字
  Widget _buildTitle(BuildContext context) {
    return searchedWord != null
        ? formattedText(
            corpus: title,
            searchedWord: searchedWord!, // 高亮显示用户搜索的词
            context: context,
          )
        : Text(
            title,
            maxLines: 1, // 限制为一行显示
            overflow: TextOverflow.ellipsis, // 文字超出部分使用省略号
          );
  }

  // 构建歌曲副标题部件（歌手名字），支持高亮搜索关键字
  Text? _buildSubtitle(BuildContext context) {
    return artist == null
        ? null
        : searchedWord != null
            ? formattedText(
                corpus: artist!,
                searchedWord: searchedWord!, // 高亮显示搜索的词
                context: context,
              )
            : Text(
                artist!,
                maxLines: 1, // 限制为一行显示
                overflow: TextOverflow.ellipsis, // 文字超出部分使用省略号
              );
  }

  Widget _buildLeading() {
    return Builder(
      builder: (context) {
        return Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              height: 45,
              width: 45,
              // 将 Uri 转换为 String
              imageUrl: art?.toString() ?? '',
              placeholder: (context, url) => const Icon(Icons.image),
              // 可以使用占位符
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline),
              // 错误时显示图标
              // fadeInDuration: const Duration(milliseconds: 700),
              // 图片淡入效果
              fit: BoxFit.cover, // 图片填充方式
            ),
          ),
        );
      },
    );
  }
}
