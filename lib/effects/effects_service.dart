import 'package:audioplayers/audioplayers.dart';

class EffectsService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSong(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  Future<void> playValidated() async {
    playSong('effects/validated.mp3');
  }

  Future<void> playUnvalided() async {
    playSong('effects/unvalidated.mp3');
  }

  Future<void> playFullValidated() async {
    playSong('effects/full_day.mp3');
  }

  Future<void> playFaillure() async {
    playSong('effects/faillure.mp3');
  }

}