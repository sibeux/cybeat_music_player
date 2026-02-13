# Summary

Secara sederhana, yang kita lakukan tadi adalah **membangun "ruang kerja" Flutter yang mandiri (portable)** agar tidak bentrok dengan pengaturan kantor yang sudah ada.

Berikut adalah rangkuman langkah-langkah teknis yang kita eksekusi:

## 1. Menyiapkan Mesin Java (JDK 17) Secara Terisolasi

Laptop kantor kamu menggunakan Java 8 untuk proyek pekerjaan utama. Karena Flutter terbaru butuh Java 17, kita mengunduh JDK 17 versi *portable* (tanpa instalasi).

* **Tujuannya:** Agar kamu punya Java 17 untuk Flutter, tapi Java 8 di laptopmu tidak terganggu atau terhapus.

## 2. Memasang Android SDK Tanpa Installer

Biasanya orang menginstal Android SDK lewat Android Studio (yang butuh izin Admin). Kita melakukan "jalan pintas" dengan mengunduh **Command Line Tools** saja.

* **Tujuannya:** Menghindari permintaan izin Admin (UAC) dan menghemat ruang penyimpanan karena kita hanya mengunduh komponen yang benar-benar dibutuhkan untuk *running* aplikasi.

## 3. Merapikan Struktur Folder (`latest`)

Kita tadi sempat memperbaiki struktur folder karena `sdkmanager` (si pengelola SDK) sangat pemilih. Dia butuh berada di folder bernama `latest` agar bisa mengenali folder induknya sebagai "Rumah SDK".

* **Tujuannya:** Memastikan alat bantu Android bisa mendownload *platform-tools* (seperti `adb`) ke lokasi yang benar.

## 4. "Menipu" Terminal Secara Sementara (`set Path`)

Ini langkah paling krusial. Kita menggunakan perintah `set` (di CMD) atau `$env` (di PowerShell) untuk mengarahkan terminal ke Java 17.

* **Tujuannya:** Perubahan ini **hanya berlaku di jendela terminal itu saja**. Begitu terminal ditutup, laptopmu kembali ke pengaturan asli kantor (Java 8). Ini cara paling aman agar kamu tidak dipanggil orang IT karena merusak konfigurasi laptop perusahaan.

## 5. Menghubungkan SDK ke Flutter

Terakhir, kita memberi tahu Flutter lewat perintah `flutter config` di mana lokasi "ruang kerja" baru yang kita buat tadi.

* **Tujuannya:** Agar saat kamu mengetik `flutter run`, Flutter tidak mencari SDK di folder sistem Windows, melainkan langsung ke folder `Documents\sibeux\...` milikmu.

---

## Kesimpulan Akhir

Sekarang kamu punya **dua jalur** di satu laptop:

1. **Jalur Kantor:** Menggunakan Java 8 untuk proyek rutin.
2. **Jalur Nasrul:** Menggunakan Java 17 + Android SDK Portable di folder `tool` untuk proyek Flutter/Cybeat.

Besok-besok kalau mau ngoding Flutter lagi, kamu tinggal jalankan *script* `.bat` yang saya sarankan tadi supaya tidak perlu mengulang proses "penyamaran" terminalnya dari awal.
