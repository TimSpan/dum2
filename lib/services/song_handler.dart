import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// 用于通过 AudioService 和 Just Audio 处理音频播放的类
class SongHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  // 创建来自 just_audio 包的 AudioPlayer 实例
  final AudioPlayer audioPlayer = AudioPlayer();

  // 根据 MediaItem 创建音频源的函数
  UriAudioSource _createAudioSource(MediaItem item) {
    // print('创建音频源item: ${item}');
    return ProgressiveAudioSource(Uri.parse(item.id));
  }

  // 监听当前歌曲索引的变化，并更新媒体项
  void _listenForCurrentSongIndexChanges() {
    audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  // 根据接收到的 PlaybackEvent 广播当前播放状态
  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[audioPlayer.processingState]!,
      playing: audioPlayer.playing,
      updatePosition: audioPlayer.position,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      queueIndex: event.currentIndex,
    ));
  }

  // 初始化歌曲并设置音频播放器的函数
  Future<void> initSongs({required List<MediaItem> songs}) async {
    // 监听播放事件并广播状态
    audioPlayer.playbackEventStream.listen(_broadcastState);

    // 根据提供的歌曲创建音频源列表
    final audioSource = songs.map(_createAudioSource).toList();

    // 设置音频播放器的音频源为多个音频源的串联
    try {
      await audioPlayer
          .setAudioSource(ConcatenatingAudioSource(children: audioSource));
    } catch (e) {
      print("加载音频源失败_______________________________: $e");
    }

    // 将歌曲添加到队列中
    queue.value.clear();
    queue.value.addAll(songs);
    queue.add(queue.value);

    // 监听当前歌曲索引的变化
    _listenForCurrentSongIndexChanges();

    // 监听处理状态的变化，当状态为完成时跳到下一首歌曲
    audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) skipToNext();
    });
  }

  // 播放函数，开始播放
  @override
  Future<void> play() => audioPlayer.play();

  // @override
  // Future<void> setUrl() => audioPlayer.setUrl(
  //     "http://m10.music.126.net/20241126121356/416bddcb3f5e254cc8d2903a44ecee50/yyaac/obj/wonDkMOGw6XDiTHCmMOi/14050790823/7cbc/c66b/8e32/82f5bdc750f1a611bde1f19f25eb415d.m4a");

  // 暂停函数，暂停播放
  @override
  Future<void> pause() => audioPlayer.pause();

  // 快进函数，改变播放位置
  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  // 跳到队列中的特定项并开始播放
  @override
  Future<void> skipToQueueItem(int index) async {
    print('Duration.zero_____________${Duration.zero}');
    print('Duration.zero_____________${Duration.zero.inMilliseconds}');
    await audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  // 跳到队列中的下一首歌
  @override
  Future<void> skipToNext() => audioPlayer.seekToNext();

  // 跳到队列中的上一首歌
  @override
  Future<void> skipToPrevious() => audioPlayer.seekToPrevious();
}
