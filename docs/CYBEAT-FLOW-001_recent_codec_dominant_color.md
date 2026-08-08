# Flow Documentation: CYBEAT-FLOW-001

## Recent Music + Codec + Dominant Color

**ID:** `CYBEAT-FLOW-001`  
**Last Updated:** 2026-03-01  
**Files Involved:**

- `lib/core/controllers/audio_state_controller.dart`
- `lib/core/repositories/audio_repository.dart`
- `api/recent-music/set_recent.php` (backend)
- `api/recent-music/read_codec.php` (backend)
- `api/image-dominant-color/get_color.php` (backend)

---

## Overview

Setiap kali lagu baru mulai diputar, aplikasi melakukan tiga hal sekaligus lewat satu API call:

1. **Menyimpan riwayat (recents)** — mencatat musik yang baru diputar ke database
2. **Membaca codec audio** — ffprobe dijalankan di server untuk mendapatkan metadata teknis (sample rate, bit rate, dll)
3. **Mendapatkan dominant color** — warna dominan dari cover art diproses di server untuk dipakai sebagai warna tema UI

---

## Flow Diagram

```
[AudioPlayer sequenceStateStream berubah]
        |
        v
[CYBEAT-FLOW-001-A] Cek apakah musicId sudah pernah diproses?
        | (lastProcessedMusicId != currentMusicId)
        | Ya (music baru)
        v
[CYBEAT-FLOW-001-B] checkCodecAudio()
        | - Cek metadata lokal (dari response API songs) dulu
        | - Jika sudah ada → return true (isCodecExist = true)
        | - Jika belum → return false (server akan prosesnya)
        v
[CYBEAT-FLOW-001-C] checkDominantColor()
        | - Cek dominant_color di extras MediaItem
        | - Jika sudah ada → return true (isDominantColorExist = true)
        | - Jika belum → return false (server akan prosesnya)
        v
[CYBEAT-FLOW-001-D] setRecentsCodecDominantColor() — fire & forget (tanpa await)
        |
        v
[CYBEAT-FLOW-001-E] AudioRepository.setRecentCodecDominantColor()
        | - Kirim POST request ke RECENT_MUSIC_API_URL
        | - Format: multipart/form-data (FormData.fromMap)  ← PENTING, bukan JSON!
        | - Timeout: 30 detik
        |
        v
[Backend PHP: set_recent.php]
        |
        |--[1] INSERT recents_musics (jika userId != 0)
        |--[2] checkCodecAudio() via ffprobe  ← hanya jika codec_exist == 'false'
        |--[3] getDominantColors() via image processing ← hanya jika dominant_color_exist == 'false'
        |--[4] DELETE recents lama (simpan 500 terbaru)
        |
        v
[Response JSON]
        |
        v
[CYBEAT-FLOW-001-F] Update reactive state di controller
        | - bitsPerRawSample, sampleRate, bitRate ← dari codec
        | - bgColor, textColor ← dari dominant_color
```

---

## Penjelasan Tiap Step

### [CYBEAT-FLOW-001-A] Guard: Cek `lastProcessedMusicId`

```dart
if (currentMusicId != lastProcessedMusicId &&
    !musicPlayerController.getCurrentMediaItem!.extras!['is_offline']) {
  lastProcessedMusicId = currentMusicId; // Set duluan, baru proses
  ...
}
```

> **Kenapa perlu ini?**  
> `sequenceStateStream` bisa emit berkali-kali untuk satu lagu yang sama (buffering, seeking, dll).  
> Tanpa guard ini, API akan dipanggil berulang-ulang untuk lagu yang sama.  
> ID di-set **sebelum** proses dimulai (bukan sesudah), untuk mencegah race condition.

---

### [CYBEAT-FLOW-001-B & C] checkCodecAudio & checkDominantColor

Dua fungsi ini hanya mengecek **data lokal** yang sudah ada di `extras` MediaItem (disimpan waktu API `getSongs` pertama kali dipanggil).  
Mereka tidak hit API sendiri. Tujuannya hanya untuk mengisi flag `isCodecExist` dan `isDominantColorExist` yang dikirim ke backend.

---

### [CYBEAT-FLOW-001-D] Fire & Forget

```dart
setRecentsCodecDominantColor(...); // tanpa await
```

> **Sengaja tidak di-await** di dalam `sequenceStateStream` listener.  
> Ini agar stream listener tidak terblokir menunggu HTTP request selesai.  
> Error ditangani di dalam fungsi itu sendiri (catch di controller).

---

### [CYBEAT-FLOW-001-E] FormData, Bukan JSON — CRITICAL

```dart
data: FormData.fromMap({ ... })
```

> **WAJIB pakai `FormData.fromMap()`**, bukan plain `Map`.  
> PHP hanya bisa membaca `$_POST` dari request dengan Content-Type:
>
> - `multipart/form-data` ✅
> - `application/x-www-form-urlencoded` ✅
>
> Kalau dikirim sebagai JSON (`Content-Type: application/json`), `$_POST` di PHP akan **kosong**,  
> kondisi `isset($_POST['music_id'])` jadi `false`, dan server return **400 Bad Request**.

---

### [CYBEAT-FLOW-001-F] Update State

```dart
if (body['status'] == "success" &&
    (body['codec'] != null || body['dominant_color'] != null)) {
  // Update codec info
  bitsPerRawSample.value = codec["bits_per_raw_sample"];
  ...
  // Update tema warna
  bgColor.value = dominantColor["bg_color"];
  textColor.value = dominantColor["text_color"];
}
```

Body responsenya null-safe: jika `codec_exist = true` maka server return `"codec": null` (tidak perlu diproses lagi).

---

## Error Handling

| Error | Handling |
|-------|----------|
| `TimeoutException` (>30s) | Log error, return `{}`, UI tidak update |
| `DioException` (network error) | Log error, return `{}`, UI tidak update |
| HTTP 400 | Log error + response body, return `{}` (biasanya karena format data salah) |
| HTTP 401 / 403 | Dianggap tidak authorized |
| Exception lain | Di-rethrow ke caller (controller) → dicatch dan di-log |

---

## Bug yang Pernah Terjadi

### BUG-001: `TimeoutException` tidak tertangani

- **Penyebab:** `catch (e) { rethrow; }` meneruskan `TimeoutException` ke atas
- **Fix:** Tambahkan `on TimeoutException` sebelum `catch` umum, return `{}`

### BUG-002: HTTP 400 Bad Request

- **Penyebab:** Dio mengirim data sebagai JSON (`application/json`), PHP tidak bisa baca lewat `$_POST`
- **Fix:** Ganti `data: { ... }` dengan `data: FormData.fromMap({ ... })`

---

## Catatan Backend (PHP)

- `checkCodecAudio()` menjalankan **ffprobe** terhadap URL audio — ini bisa lambat (10–30 detik) tergantung kecepatan server dan ukuran file audio
- `getDominantColors()` mendownload image dan memproses piksel — bisa lambat di koneksi jelek
- Tambahkan **index DB** di `recents_musics (user_id, played_at)` untuk mempercepat query DELETE
- Pertimbangkan `fastcgi_finish_request()` di PHP-FPM untuk merespons client segera, lalu proses ffprobe & color di background

---

## Related Docs

- `CYBEAT-ERR-001` — setState during build fix
- `CYBEAT-ERR-002` — refresh controller sharing fix
