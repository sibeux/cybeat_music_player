# FIX-20260217-01: Masalah Inisialisasi Async pada InitialBinding

## Deskripsi Masalah
Aplikasi mengalami error saat startup dimana `MusicPlayerController` tidak ditemukan di `RootPage`.

**Gejala:**
- Error "Instance of MusicPlayerController not found" saat aplikasi pertama kali dijalankan.
- Terkadang works, terkadang tidak (race condition).

**Analisis Penyebab:**
1. Di `InitialBinding`, kita melakukan inisialisasi `AuthService` menggunakan `await Get.putAsync(...)`.
2. Method `dependencies()` pada `Bindings` berjalan secara synchronous, namun `Get.putAsync` bersifat asynchronous.
3. Karena `dependencies()` berisi `await`, flow eksekusi di dalamnya terhenti sejenak, sementara proses utama aplikasi (`runApp`) terus lanjut merender widget tree.
4. `RootPage` di-render dan mencoba memanggil `Get.find<MusicPlayerController>()`.
5. Namun, `Get.put(MusicPlayerController())` di `InitialBinding` belum dieksekusi karena masih "menunggu" baris `await AuthService` di atasnya selesai.
6. Akibatnya, controller belum terdaftar saat UI membutuhkannya.

## Solusi
Memindahkan inisialisasi service yang bersifat **critical** dan **blocking** ke `main()` sebelum `runApp()`.

### Langkah Perbaikan:
1. **Pemindahan Kode**: Pindahkan inisialisasi `SecureStorageService` dan `AuthService` dari `InitialBinding` ke fungsi `main()`.
2. **Blocking Initialization**: Dengan meletakkannya sebelum `runApp()`, kita memaksa aplikasi untuk menunggu service-service ini siap 100% sebelum mulai merender UI apapun. Splash screen native akan tetap muncul selama proses ini.
3. **Synchronous Binding**: Kembalikan `InitialBinding` menjadi metode synchronous biasa tanpa `async/await`. Ini menjamin semua `Get.put` di dalamnya (termasuk `MusicPlayerController`) dieksekusi seketika secara berurutan.

### Kode Terkait
File: `lib/main.dart`

**Sebelum (Salah):**
```dart
class InitialBinding extends Bindings {
  @override
  void dependencies() async { // async di sini berbahaya
    Get.put(SecureStorageService());
    await Get.putAsync(() => AuthService().init()); // Blocking UI rendering
    
    Get.put(MusicPlayerController()); // Belum dijalankan saat UI butuh
  }
}
```

**Sesudah (Benar):**
```dart
Future<void> main() async {
  // ... setup lainnya ...
  
  // FIX-20260217-01: Load Service sebelum runApp
  Get.put(SecureStorageService());
  await Get.putAsync(() => AuthService().init());

  runApp(MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() { // Synchronous, aman
    Get.put(AlbumService());
    Get.put(MusicPlayerController()); // Pasti sudah ada saat UI render
    // ...
  }
}
```

## Kesimpulan
Untuk service atau controller yang mutlak diperlukan sebelum halaman pertama (RootPage) muncul, inisialisasilah di `main()` sebelum `runApp`. Gunakan `InitialBinding` hanya untuk dependency injection yang bersifat *instan* (synchronous) atau lazy loading.
