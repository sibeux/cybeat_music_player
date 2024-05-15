import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioSourceState extends ChangeNotifier {

  IndexedAudioSource? _audioSource;
  IndexedAudioSource? get audioSource => _audioSource;

  void setAudioSource(IndexedAudioSource audioSource) {
    _audioSource = audioSource;
  }
}
