import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mcnd_mobile/ui/radio/audio_player_task.dart';
import 'package:mcnd_mobile/ui/radio/radio_screen_model.dart';

@injectable
class RadioViewModel extends StateNotifier<RadioScreenModel> {
  StreamSubscription<PlaybackState>? _streamSubscription;

  RadioViewModel() : super(const RadioScreenModel.loading());

  void _onPlayerStateChanged(PlaybackState playbackState) {
    if (playbackState.processingState == AudioProcessingState.connecting) {
      state = const RadioScreenModel.loading();
      return;
    }
    state = playbackState.playing ? const RadioScreenModel.playing() : const RadioScreenModel.stopped();
  }

  @override
  void dispose() {
    // AudioService.disconnect();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startBackgroundTask() async {
    if (!AudioService.running) {
      await AudioService.start(backgroundTaskEntrypoint: audioPlayerTaskEntrypoint);
    }
  }

  Future<void> load() async {
    // await AudioService.connect();
    _streamSubscription = AudioService.playbackStateStream.listen(_onPlayerStateChanged);
    _startBackgroundTask();
  }

  Future<void> play() async {
    if (!AudioService.running) {
      state = const RadioScreenModel.loading();
      await _startBackgroundTask();
    }
    AudioService.play();
  }

  Future<void> stop() async {
    if (AudioService.running) {
      AudioService.pause();
    }
  }
}
