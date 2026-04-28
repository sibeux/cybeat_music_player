# Fix Documentation: CYBEAT-FIX-001

## Notification Controls: Next/Prev Buttons & Seekbar via Custom AudioHandler

**ID:** `CYBEAT-FIX-001`  
**Tanggal:** 2026-04-28  
**Status:** ✅ Selesai & Verified  
**Files Involved:**

- `lib/core/audio/cybeat_audio_handler.dart` ← **baru**
- `lib/core/controllers/audio_state_controller.dart`
- `lib/core/controllers/music_player_controller.dart`
- `lib/main.dart`

---

## Problem

Tombol **Skip Next** dan **Skip Previous** tidak pernah muncul di notifikasi media Android.

### Root Cause

Proyek ini memakai arsitektur **single audioSource** — setiap ganti lagu, `AudioPlayer` hanya memuat satu item:

```dart
await player.setAudioSources(
  [AudioSource.uri(Uri.parse(url), tag: mediaItem)],
  initialIndex: 0,
);
```

Paket `just_audio_background` menampilkan tombol skip hanya jika:

- `player.hasNext == true` → tombol Next muncul
- `player.hasPrevious == true` → tombol Previous muncul

Karena queue selalu berisi **1 item**, kedua nilai itu selalu `false`. Akibatnya tombol tidak pernah dirender di notifikasi, meskipun logika navigasi lagu (playlist next/prev) sudah benar.

### Kenapa Tidak Masukkan Semua Lagu ke AudioSource?

Alternatif paling naif adalah memasukkan seluruh playlist ke `ConcatenatingAudioSource`. Ini **tidak layak** karena:

1. **Signed URL** — URL lagu dari CDN (Cloudflare, GDrive) bisa expired atau perlu signed token per-request. Tidak bisa di-generate sekaligus untuk 100+ lagu.
2. **Memory** — `ConcatenatingAudioSource` mengelola state buffer untuk semua source sekaligus.
3. **Overhead inisialisasi** — Setiap ganti album, semua URL harus di-resolve terlebih dahulu.
4. **Desain yang sudah ada** — Logika shuffle, repeat, dan navigasi playlist sudah berjalan baik dengan sistem single source + controller GetX.

---

## Solusi

Migrasi dari `just_audio_background` ke `audio_service` langsung, dengan membuat `CybeatAudioHandler` sebagai **custom AudioHandler**.

Idenya sederhana: pisahkan dua hal yang sebelumnya digabungkan oleh `just_audio_background`:

| Tanggung Jawab | Sebelum | Sesudah |
|---|---|---|
| Notifikasi OS | `just_audio_background` (auto, pasif) | `CybeatAudioHandler` (aktif, custom) |
| Navigasi lagu | `MusicPlayerController` (GetX) | `MusicPlayerController` (GetX) — tidak berubah |
| Playback audio | `AudioPlayer` (just_audio) | `AudioPlayer` (just_audio) — tidak berubah |

Dengan `CybeatAudioHandler`, kita bisa mendaftarkan `MediaAction.skipToNext` dan `MediaAction.skipToPrevious` di `systemActions` **secara eksplisit**, tanpa bergantung pada `player.hasNext` / `player.hasPrevious`.

---

## Alur & Logic

### 1. Inisialisasi (saat app pertama dibuka)

```
main() → runApp()
    └── InitialBinding.dependencies()
            ├── Get.put(MusicPlayerController())   ← onInit() dipanggil
            ├── Get.put(AudioStateController())    ← onInit() dipanggil
            │       └── _initAudioService() [fire & forget]
            │               ├── AudioPlayer player = AudioPlayer()
            │               ├── activePlayer.value = player      ← Rx berubah
            │               └── AudioService.init(
            │                     builder: () => CybeatAudioHandler(player)
            │                   )
            └── Get.put(MusicDownloadController())
```

Setelah widget dirender, GetX memanggil `onReady()`:

```
MusicPlayerController.onReady()
    ├── ever(activePlayer, _listenToPlayerStreams)   ← daftar listener
    └── if (activePlayer.value != null)              ← race condition guard
            └── _listenToPlayerStreams(player)        ← subscribe streams manual
```

> **Kenapa perlu race condition guard?**
>
> `_initAudioService()` bersifat **async fire & forget** — ia berjalan di background sejak `onInit()`, dan bisa selesai **sebelum** `onReady()` dipanggil. Jika sudah selesai, `activePlayer.value` sudah bernilai saat `ever()` baru didaftarkan. Karena `ever` hanya menangkap **perubahan berikutnya** (bukan nilai saat ini), `_listenToPlayerStreams` tidak pernah dipanggil → semua stream (posisi, durasi, state) tidak pernah di-subscribe → button UI tidak berfungsi.
>
> Guard ini memastikan `_listenToPlayerStreams` selalu terpanggil minimal sekali, terlepas dari timing.

---

### 2. Notifikasi Muncul dan Tombol Selalu Ada

```dart
// Di CybeatAudioHandler._transformEvent()
PlaybackState(
  controls: [
    MediaControl.skipToPrevious,
    player.playing ? MediaControl.pause : MediaControl.play,
    MediaControl.skipToNext,
  ],
  systemActions: const {
    MediaAction.seek,
    MediaAction.skipToNext,      // ← tombol selalu ada, bukan bergantung hasNext
    MediaAction.skipToPrevious,  // ← tombol selalu ada, bukan bergantung hasPrevious
  },
  androidCompactActionIndices: const [0, 1, 2], // prev | play/pause | next
  ...
)
```

`systemActions` adalah daftar aksi yang **diberitahukan ke OS** bahwa handler kita mendukungnya. OS Android akan selalu merender tombol untuk aksi yang terdaftar di sini, terlepas dari state internal player.

---

### 3. Saat Tombol Next/Prev di Notifikasi Ditekan

```
[User tap Skip Next di notifikasi]
    └── Android OS kirim event ke AudioService
            └── CybeatAudioHandler.skipToNext()
                    └── MusicPlayerController.seekNextButton()
                            ├── Hitung index lagu berikutnya dari playlist
                            ├── Buat MediaItem baru dari playlist[index]
                            └── playMusicNow()
                                    └── player.setAudioSources([lagu_baru])
                                            └── player.play()
```

Handler **tidak** memanggil `player.seekToNext()` (yang akan gagal karena queue hanya 1 item). Ia mendelegasikan sepenuhnya ke `MusicPlayerController.seekNextButton()` yang sudah punya logika lengkap (shuffle, boundary check, dll).

---

### 4. Saat Metadata Lagu di Notifikasi Perlu Diupdate

Ada dua stream yang dipakai untuk menjaga notifikasi selalu sinkron:

**4a. `sequenceStateStream` → update judul, artis, cover art**

```dart
player.sequenceStateStream.listen((sequenceState) {
  final tag = sequenceState?.currentSource?.tag;
  if (tag is MediaItem) {
    mediaItem.add(tag); // ← push ke AudioService agar notifikasi update
  }
});
```

Karena kita menggunakan `tag: mediaItem` di setiap `AudioSource.uri(...)`, stream ini akan selalu punya data MediaItem terbaru. Ini yang membuat judul, artis, dan cover art di notifikasi berubah setiap ganti lagu.

**4b. `durationStream` → update durasi untuk seekbar**

```dart
player.durationStream.listen((duration) {
  final current = mediaItem.value;
  if (current != null && duration != null) {
    mediaItem.add(current.copyWith(duration: duration));
  }
});
```

`MediaItem` dari tag **tidak punya `duration`** saat pertama dibuat, karena durasi audio baru diketahui setelah player selesai buffering/loading. Android menggunakan `duration` dari `MediaItem` untuk merender seekbar interaktif di notifikasi. Tanpa ini:

- `MediaItem.duration == null`
- Android tidak tahu panjang lagu
- Seekbar tidak ditampilkan

`copyWith()` membuat `MediaItem` baru dengan `duration` yang sudah diisi, tapi semua field lain (title, artist, artUri, extras) tetap sama.

---

### 5. Saat Album Diganti / Player Di-clear

Sebelum implementasi ini, `clear()` membuat `AudioPlayer()` baru:

```dart
// LAMA — berbahaya setelah CybeatAudioHandler
activePlayer.value?.dispose();
activePlayer.value = AudioPlayer(); // ← instance baru, handler jadi yatim
```

`CybeatAudioHandler` sudah terikat ke instance player yang lama. Jika player diganti, handler kehilangan koneksi → notifikasi tidak terupdate, bahkan bisa error.

Sekarang `clear()` hanya stop + reset source:

```dart
// BARU — aman
await activePlayer.value?.stop();
await activePlayer.value?.setAudioSources([]); // source kosong, instance tetap sama
lastProcessedMusicId = null;
```

---

## Perubahan File

### `lib/core/audio/cybeat_audio_handler.dart` (baru)

Custom `BaseAudioHandler` yang:
- Menerima instance `AudioPlayer` di constructor
- Merelay `PlaybackEvent` ke `AudioService` via `playbackState`
- Merelay `MediaItem` terbaru (judul/artis/cover) via `sequenceStateStream`
- Merelay durasi audio via `durationStream` → agar seekbar muncul di notifikasi
- Mengimplementasikan `skipToNext()` / `skipToPrevious()` yang delegate ke `MusicPlayerController`
- Mendaftarkan `systemActions` eksplisit agar tombol selalu muncul
- Menyediakan `cybeatAudioServiceConfig` (config notifikasi)

### `lib/core/controllers/audio_state_controller.dart`

| Perubahan | Alasan |
|---|---|
| Tambah field `late CybeatAudioHandler audioHandler` | Simpan referensi handler |
| `onInit()` → panggil `_initAudioService()` | Pisahkan async init ke fungsi tersendiri |
| `_initAudioService()` baru (async) | Init `AudioPlayer` + register ke `AudioService` |
| `clear()` tidak buat `AudioPlayer()` baru | Handler sudah terikat ke instance awal; replace = koneksi putus |

### `lib/core/controllers/music_player_controller.dart`

| Perubahan | Alasan |
|---|---|
| `onReady()` tambah race condition guard | `_initAudioService()` bisa selesai sebelum `ever()` terdaftar; guard pastikan `_listenToPlayerStreams` selalu dipanggil minimal sekali |

### `lib/main.dart`

| Perubahan | Alasan |
|---|---|
| Hapus `JustAudioBackground.init()` | Tidak kompatibel dipakai bersamaan dengan `AudioService.init()` — keduanya mendaftarkan `AudioService` sebagai plugin background |
| Hapus `import just_audio_background` | Package tidak lagi digunakan |

> **Catatan:** `just_audio_background` masih ada di `pubspec.yaml`. Bisa dihapus di versi build selanjutnya jika sudah dipastikan tidak ada ketergantungan lain.

---

## Diagram Arsitektur (Sesudah)

```
┌─────────────────────────────────────────┐
│              ANDROID OS                 │
│  [Notifikasi Media]                     │
│   [ ⏮ ]  [ ⏯ ]  [ ⏭ ]               │
└──────────────┬──────────────────────────┘
               │ MediaAction event
               ▼
┌─────────────────────────────────────────┐
│         CybeatAudioHandler              │
│  (BaseAudioHandler / audio_service)     │
│                                         │
│  skipToNext()  ──────────────────────┐  │
│  skipToPrevious() ───────────────┐   │  │
│  play() / pause() → AudioPlayer  │   │  │
│  seek()           → AudioPlayer  │   │  │
│                                  │   │  │
│  PlaybackEvent  ←── AudioPlayer  │   │  │
│  (relay ke OS)                   │   │  │
└──────────────────────────────────┼───┼──┘
                                   │   │
                                   ▼   ▼
                    ┌──────────────────────────┐
                    │   MusicPlayerController  │
                    │   (GetX)                 │
                    │                          │
                    │  seekNextButton()         │
                    │  seekPreviousButton()     │
                    │   └── playMusicNow()      │
                    │         └── setAudioSources([1 item])
                    └──────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │     AudioPlayer          │
                    │     (just_audio)         │
                    │   [single AudioSource]   │
                    └──────────────────────────┘
```

---

## Hal yang Tidak Berubah

- Arsitektur **single audioSource** — tetap 1 item per waktu
- Logika navigasi (next/prev/shuffle) di `MusicPlayerController` — tidak ada perubahan
- Logika fetch playlist dan stream URL — tidak ada perubahan
- Android Manifest — sudah benar sejak awal (`AudioServiceActivity`, `AudioService`, `MediaButtonReceiver`)

---

## Bug yang Ditemukan & Diperbaiki

### BUG-001: Widget Button UI Tidak Berfungsi Setelah Migrasi

**Gejala:** Tombol play/pause, progress bar, dan semua kontrol UI di dalam app berhenti berfungsi setelah migrasi ke `AudioService`.

**Penyebab:** Race condition antara `_initAudioService()` (async) dan `MusicPlayerController.onReady()`.

```
Timeline bermasalah:
t=0ms  → onInit() → _initAudioService() [fire & forget]
t=1ms  → activePlayer.value = player   ← Rx berubah, tapi ever() belum ada
t=5ms  → onReady() → ever(activePlayer, ...) didaftarkan
              ↳ ever tidak firing karena tidak ada perubahan baru
              ↳ _listenToPlayerStreams tidak pernah dipanggil
              ↳ positionStream, playerStateStream, dll → tidak di-subscribe
```

**Fix:** Guard di `onReady()`:

```dart
if (audioStateController.activePlayer.value != null) {
  _listenToPlayerStreams(audioStateController.activePlayer.value);
}
```

---

### BUG-002: Seekbar Tidak Muncul di Notifikasi

**Gejala:** Notifikasi menampilkan tombol next/prev dan play/pause dengan benar, tapi tidak ada seekbar (progress bar) yang bisa digeser.

**Penyebab:** `MediaItem` yang di-push ke `AudioService` tidak memiliki field `duration`.

```
MediaItem dari AudioSource.tag:
  title: "Lagu A"
  artist: "Artist B"
  artUri: ...
  duration: null  ← tidak diisi saat MediaItem dibuat

Android cek duration → null → seekbar tidak dirender
```

Durasi audio baru diketahui **setelah** `AudioPlayer` selesai load/buffer audio, bukan saat `MediaItem` dibuat sebelum play.

**Fix:** Tambah `durationStream` listener di `CybeatAudioHandler` constructor:

```dart
player.durationStream.listen((duration) {
  final current = mediaItem.value;
  if (current != null && duration != null) {
    mediaItem.add(current.copyWith(duration: duration)); // ← update duration
  }
});
```

Saat player berhasil resolve durasi, `mediaItem` di-update dengan `copyWith(duration: ...)` → Android menerima duration yang valid → seekbar muncul dan bisa digeser.

---

## Related Docs

- `CYBEAT-FLOW-001` — Recent music + codec + dominant color flow
- `FIX-20260217-01` — Async initialization fix (AuthService)
