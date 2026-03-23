import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._internal();
  final AudioPlayer _player = AudioPlayer();

  SoundManager._internal();

  Future<void> playMove() async {
    try {
      await _player.play(AssetSource('sounds/move.mp3'));
    } catch (_) {
      // Asset might be missing
    }
  }

  Future<void> playWin() async {
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
    } catch (_) {
      // Asset might be missing
    }
  }

  Future<void> playDraw() async {
    try {
      await _player.play(AssetSource('sounds/draw.mp3'));
    } catch (_) {
      // Asset might be missing
    }
  }

  Future<void> playLoss() async {
    try {
      await _player.play(AssetSource('sounds/loosing.mp3'));
    } catch (_) {
      // Asset might be missing
    }
  }

  void dispose() {
    _player.dispose();
  }
}
