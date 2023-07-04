import 'package:audioplayers/audioplayers.dart';

AudioCache audioCache = AudioCache();
final player = AudioPlayer();

class AudioService{
  static Future<void> playSuccessSound()async{
    await player.setVolume(1);
    await player.stop();
    await player.play(AssetSource('sounds/success_sound.mp3'));
  }
  static Future<void> playFailSound()async{
    await player.setVolume(1);
    await player.stop();
    await player.play(AssetSource('sounds/error_sound.mp3'));
  }
}