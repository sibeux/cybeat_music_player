import 'package:audio_service/audio_service.dart';
import 'package:cybeat_music_player/core/controllers/music_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

/// Handler kustom yang menjembatani antara AudioService (sistem notifikasi)
/// dengan AudioPlayer (just_audio) dan MusicPlayerController (GetX).
///
/// Kenapa perlu ini?
/// just_audio_background hanya menampilkan tombol Skip Next/Prev jika
/// player.hasNext / player.hasPrevious == true. Karena kita memakai
/// single audioSource (1 lagu per waktu), kedua nilai itu selalu false.
///
/// Solusi: dengan mendaftarkan MediaAction.skipToNext / skipToPrevious
/// di [systemActions], tombol akan SELALU muncul di notifikasi, dan
/// aksinya di-delegate ke MusicPlayerController.seekNextButton/seekPreviousButton().
class CybeatAudioHandler extends BaseAudioHandler {
  final AudioPlayer player;

  CybeatAudioHandler(this.player) {
    // Relay PlaybackEvent dari just_audio ke AudioService
    // agar status notifikasi (play/pause/buffering) selalu sync.
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Relay MediaItem yang sedang diputar ke AudioService
    // agar judul, artis, dan cover di notifikasi terupdate.
    player.sequenceStateStream.listen((sequenceState) {
      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        final tag = currentSource.tag;
        if (tag is MediaItem) {
          mediaItem.add(tag);
        }
      }
    });

    // Relay durasi audio ke AudioService.
    // MediaItem dari tag TIDAK punya duration saat pertama dibuat karena durasi
    // baru diketahui setelah player selesai load/buffer audio.
    // Tanpa ini, Android menganggap duration = null → seekbar tidak muncul di notifikasi.
    player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null) {
        // copyWith() buat MediaItem baru dengan duration yang sudah diisi,
        // tapi metadata lain (title, artist, artUri, extras) tetap sama.
        mediaItem.add(current.copyWith(duration: duration));
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Playback Controls — semua di-delegate ke AudioPlayer
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => player.stop();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  // ---------------------------------------------------------------------------
  // Skip Controls — di-delegate ke MusicPlayerController (GetX)
  // Inilah inti dari solusi: kita TIDAK pakai player.seekToNext()
  // karena queue hanya berisi 1 item. Kita pakai controller kita sendiri.
  // ---------------------------------------------------------------------------

  @override
  Future<void> skipToNext() async {
    final controller = Get.find<MusicPlayerController>();
    controller.seekNextButton();
  }

  @override
  Future<void> skipToPrevious() async {
    final controller = Get.find<MusicPlayerController>();
    controller.seekPreviousButton();
  }

  // ---------------------------------------------------------------------------
  // Transform PlaybackEvent → PlaybackState untuk notifikasi
  // ---------------------------------------------------------------------------

  /// Mengubah [PlaybackEvent] dari just_audio ke [PlaybackState] AudioService.
  /// Kunci utama ada di [systemActions]: mendaftarkan skipToNext & skipToPrevious
  /// di sini memaksa OS untuk SELALU menampilkan tombol tersebut di notifikasi,
  /// terlepas dari nilai player.hasNext / player.hasPrevious.
  PlaybackState _transformEvent(PlaybackEvent event) {
    // Fallback: jika durationStream belum emit (misal streaming URL lambat
    // kirim header), coba ambil duration langsung dari player saat event tiba.
    // Ini memastikan seekbar muncul secepat mungkin.
    final duration = player.duration;
    if (duration != null) {
      final current = mediaItem.value;
      if (current != null && current.duration != duration) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    }

    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious, // index 0
        player.playing ? MediaControl.pause : MediaControl.play, // index 1
        MediaControl.skipToNext, // index 2
        MediaControl.stop, // index 3 — hanya muncul di expanded view
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      // Compact view: prev | play/pause | next (stop tidak masuk compact)
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[event.processingState]!,
      playing: player.playing,
      // Pakai event.updatePosition + event.updateTime (bukan player.position)
      // agar Android bisa ekstrapolasi posisi: pos = updatePos + speed × (now − updateTime)
      updatePosition: event.updatePosition,
      updateTime: event.updateTime,
      bufferedPosition: event.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

/// Config AudioService untuk notifikasi Android/iOS.
AudioServiceConfig get cybeatAudioServiceConfig => const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      notificationColor: Color(0xFF1E1E2E),
      androidNotificationIcon: 'mipmap/cybeat_launcher',
      androidShowNotificationBadge: true,
      preloadArtwork: true,
    );
