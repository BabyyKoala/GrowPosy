[file-tag: code-generated-file-0-1777981184283966742]

Berikut adalah raw markdown dari file yang telah dibuat sesuai dengan susunan struktur project GrowPosy yang Anda unggah:

```markdown
# GrowPosy 🌱

GrowPosy adalah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah manajemen kegiatan Posyandu, memantau tumbuh kembang balita, jadwal imunisasi, serta menyediakan edukasi kesehatan bagi para Ibu.

## 🚀 Fitur Utama

- **Autentikasi & Manajemen Peran:** Login dan registrasi dengan pembagian peran antara **Kader** Posyandu dan **Ibu** balita.
- **Manajemen Data Anak:** Pencatatan dan pengelolaan profil anak/balita.
- **Pemantauan Pertumbuhan (Growth Chart):** Pemantauan berat badan, tinggi badan, dan lingkar kepala anak yang divisualisasikan menggunakan grafik.
- **Rekam Imunisasi:** Pencatatan dan jadwal riwayat imunisasi anak.
- **Manajemen Posyandu:** Pencatatan data dan pembuatan laporan bulanan oleh Kader Posyandu.
- **Artikel Edukasi:** Kumpulan artikel kesehatan dan *parenting* untuk mengedukasi para Ibu.
- **Profil Pengguna:** Pengelolaan data akun dan pengaturan profil.

## 🛠️ Teknologi yang Digunakan

- **Framework Mobile:** [Flutter](https://flutter.dev/) (menggunakan bahasa pemrograman Dart)
- **Backend & Database:** Firebase (Cloud Firestore & Firebase Authentication)
- **Desain & UI/UX:** Material Design dengan kustomisasi komponen visual

## 📋 Prasyarat Instalasi

Sebelum menjalankan aplikasi ini, pastikan Anda telah menginstal beberapa perangkat lunak berikut:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stabil terbaru).
2. Code Editor atau IDE seperti [Visual Studio Code](https://code.visualstudio.com/) atau [Android Studio](https://developer.android.com/studio).
3. Akun [Firebase](https://firebase.google.com/) untuk mengonfigurasi database dan sistem autentikasi.

> **Catatan Konfigurasi Firebase:** Pastikan Anda telah mengunduh file `google-services.json` (untuk Android) dan meletakkannya di direktori `android/app/` serta mengonfigurasi `GoogleService-Info.plist` (untuk iOS) agar aplikasi dapat terhubung dengan backend.

## 📁 Susunan Project

Struktur utama dari direktori source code (`lib/`) project ini diatur sebagai berikut:

```text
lib/
├── models/         # Struktur model data (misal: child_model.dart)
├── screens/        # Tampilan/UI aplikasi berdasarkan modul
│   ├── auth/       # Layar Login, Register, Reset Password, Verifikasi
│   ├── child/      # Layar Daftar Anak dan Form Tambah Anak
│   ├── edukasi/    # Layar Daftar Edukasi dan Detail Artikel
│   ├── growth/     # Layar Form Pertumbuhan dan Grafik Pertumbuhan (Chart)
│   ├── home/       # Dashboard Utama terpisah untuk Kader dan Ibu
│   ├── imunisasi/  # Layar Manajemen Imunisasi
│   ├── posyandu/   # Layar Laporan Bulanan dan Pengaturan Posyandu
│   ├── profil/     # Layar Profil Pengguna
│   ├── role/       # Layar Pemilihan Peran (Kader/Ibu)
│   └── splash/     # Splash Screen Aplikasi
├── services/       # Logika bisnis, koneksi ke Firebase Auth & Firestore, Session
├── theme/          # Konfigurasi tema global, warna (app_color), dan teks (app_text_style)
├── widgets/        # Komponen UI modular (Custom Button, Card, TextField)
├── firebase_options.dart # Konfigurasi environment Firebase
└── main.dart       # Titik masuk (entry point) aplikasi
