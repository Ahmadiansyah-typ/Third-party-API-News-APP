# TeknoToday Indonesia

Aplikasi berita teknologi dan digital berbasis Flutter yang mengambil artikel dari **GNews REST API**. Aplikasi ini dibuat sebagai tugas praktikum Pemrograman Mobile – Topic 11: *FutureBuilder, News App & Error Handling API di Flutter*.

> **Catatan konfigurasi:** API key GNews tidak disertakan dalam repository. Buat file `config/env.json` secara lokal mengikuti petunjuk di bawah.

## Fitur

- Menampilkan daftar berita dari GNews API berdasarkan kategori.
- Kategori berita: Teknologi, Sains, Bisnis, Nasional, Dunia, dan Utama.
- Pencarian berita menggunakan endpoint GNews `/search`.
- Dialog pencarian dengan validasi kata kunci.
- Halaman detail artikel yang menampilkan gambar, judul, deskripsi, sumber, tanggal, dan konten yang tersedia.
- Tombol untuk membuka sumber berita asli.
- `FutureBuilder` dengan empat state: loading, error, empty, dan data.
- Future cache per kategori menggunakan `Map<String, Future<List<ArticleModel>>>`.
- Pull-to-refresh untuk meminta data baru pada kategori aktif.
- Retry ketika request gagal.
- Penanganan error terpusat menggunakan `ApiException`.
- Format tanggal dengan locale Indonesia (`id_ID`).
- Pemuatan gambar dengan placeholder dan fallback ketika gambar gagal dimuat.

## Teknologi

- Flutter 3.47.1
- Dart 3.13.1
- Dio 5.x untuk HTTP client
- GNews REST API sebagai sumber berita
- GetX untuk routing
- `cached_network_image` untuk gambar artikel
- `intl` untuk format tanggal
- `url_launcher` untuk membuka tautan berita asli

Versi Flutter dan Dart di atas adalah lingkungan pengembangan yang digunakan saat proyek dibuat. Versi dependency yang terpasang dapat dilihat di `pubspec.lock`.

## Struktur Folder

```text
teknotoday_indonesia/
├── config/
│   ├── env.example.json
│   └── env.json                 # lokal saja, jangan di-commit
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── env.dart
│   ├── models/
│   │   ├── article_model.dart
│   │   └── news_response_model.dart
│   ├── services/
│   │   ├── api_exception.dart
│   │   └── news_api_service.dart
│   ├── views/
│   │   ├── home_view.dart
│   │   ├── search_view.dart
│   │   └── detail_view.dart
│   ├── widgets/
│   │   ├── article_card.dart
│   │   ├── error_view.dart
│   │   └── news_image.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── utils/
│       ├── app_colors.dart
│       └── date_formatter.dart
├── screenshots/
├── .gitignore
├── pubspec.yaml
└── README.md
```

## Sumber API dan Endpoint

Aplikasi menggunakan GNews API dengan base URL:

```text
https://gnews.io/api/v4
```

Endpoint yang digunakan:

| Endpoint | Fungsi |
|---|---|
| `GET /top-headlines` | Mengambil berita berdasarkan kategori |
| `GET /search` | Mencari berita berdasarkan kata kunci |

Parameter umum yang dikirim oleh service:

| Parameter | Nilai |
|---|---|
| `lang` | `id` |
| `country` | `id` |
| `max` | `10` |
| `apikey` | API key pribadi (konfigurasi lokal) |

Kategori yang digunakan aplikasi adalah `technology`, `science`, `business`, `nation`, `world`, dan `general`.

Perhatikan batas paket GNews yang berlaku pada akun masing-masing. Paket gratis pada materi praktikum memiliki batas request, jumlah artikel per request, dan kecepatan request. Hindari menekan pencarian atau mengganti kategori berulang kali dengan cepat.

## Persiapan dan Instalasi

### 1. Prasyarat

- Flutter SDK dan Dart SDK.
- Visual Studio Code atau IDE Flutter lainnya.
- Google Chrome untuk menjalankan Flutter Web, atau perangkat/emulator Android untuk pengujian Android.
- Akun GNews dan API key yang sudah diperoleh.

### 2. Ambil dependency

Dari folder proyek, jalankan:

```bash
flutter pub get
```

### 3. Dapatkan API key GNews

Daftar atau masuk melalui [GNews](https://gnews.io/), verifikasi email bila diminta, lalu ambil API key dari dashboard akun.

### 4. Buat konfigurasi lokal

Salin `config/env.example.json` menjadi `config/env.json`, lalu isi API key milik sendiri.

Contoh `config/env.example.json`:

```json
{
  "GNEWS_BASE_URL": "https://gnews.io/api/v4",
  "GNEWS_API_KEY": "ISI_API_KEY_ANDA"
}
```

Contoh `config/env.json` pada komputer lokal:

```json
{
  "GNEWS_BASE_URL": "https://gnews.io/api/v4",
  "GNEWS_API_KEY": "API_KEY_GNEWS_MILIK_ANDA"
}
```

**Jangan mengunggah `config/env.json` atau API key asli ke GitHub.** Pastikan `.gitignore` memuat:

```gitignore
config/env.json
config/env.prod.json
```

### 5. Jalankan aplikasi

Untuk Chrome:

```bash
flutter run -d chrome --dart-define-from-file=config/env.json
```

Untuk perangkat atau emulator yang terdeteksi Flutter:

```bash
flutter run --dart-define-from-file=config/env.json
```

## Penjelasan Implementasi

### Model data

- `ArticleModel` memetakan field artikel dari JSON GNews, termasuk `title`, `description`, `url`, `image`, `publishedAt`, `source.name`, dan `content`.
- `NewsResponseModel` memetakan `totalArticles` dan daftar `articles`.

### News API Service

`NewsApiService` menjadi pusat request HTTP menggunakan Dio. Service mengatur base URL, timeout, parameter umum, endpoint kategori, endpoint pencarian, validasi kata kunci, parsing response, dan konversi error.

### FutureBuilder dan empat state

Home dan Search menggunakan `FutureBuilder<List<ArticleModel>>`. Pemeriksaan state dilakukan dengan urutan:

1. **Loading** – request masih berlangsung.
2. **Error** – request gagal dan pesan ditampilkan melalui `ErrorView`.
3. **Empty** – request berhasil tetapi daftar artikel kosong.
4. **Data** – artikel ditampilkan menggunakan `ListView.builder`.

Future disimpan pada State dan dibuat di `initState()` atau ketika pengguna mengganti kategori, melakukan retry, atau refresh. Future tidak dibuat langsung di dalam `build()`.

### Future cache kategori

Home menyimpan Future setiap kategori dengan tipe:

```dart
Map<String, Future<List<ArticleModel>>>
```

Ketika kategori dipilih untuk pertama kali, service membuat request dan Future disimpan. Ketika kategori yang sama dipilih kembali, aplikasi menggunakan Future yang sudah tersimpan sehingga tidak membuat request kategori baru. Retry dan pull-to-refresh membuat Future baru untuk kategori aktif lalu memperbarui entri cache tersebut.

### Pencarian berita

Search Dialog memvalidasi kata kunci yang tidak boleh kosong dan membatasi panjang input. SearchView memanggil `searchNews(keyword)`, yang menggunakan endpoint GNews `/search`; hasil pencarian bukan hasil filter lokal dari daftar Home.

### Error handling

`ApiException` mengubah error jaringan, timeout, respons HTTP, dan format JSON menjadi pesan yang lebih mudah dipahami. Skenario yang ditangani meliputi:

- Konfigurasi belum diisi.
- HTTP 400 – permintaan tidak valid.
- HTTP 401 – API key salah atau tidak terdaftar.
- HTTP 403 – kuota atau verifikasi akun.
- HTTP 404 – endpoint tidak ditemukan.
- HTTP 429 – request terlalu cepat.
- HTTP 5xx – server bermasalah.
- Connection error – tidak ada koneksi internet.
- Timeout – server tidak merespons tepat waktu.
- Sertifikat keamanan tidak valid.
- Struktur data JSON tidak sesuai model.

## Pengujian Manual

Jalankan pengujian berikut pada aplikasi. Tandai hasil berdasarkan pengujian yang benar-benar dilakukan.

| No. | Skenario | Hasil yang diharapkan |
|---:|---|---|
| 1 | Membuka Home | Berita dari GNews tampil |
| 2 | Memilih kategori berbeda | Berita kategori yang dipilih tampil |
| 3 | Kembali ke kategori yang pernah dibuka | Future kategori digunakan kembali dari cache |
| 4 | Menekan refresh / melakukan pull-to-refresh | Future baru dibuat dan kategori aktif dimuat ulang |
| 5 | Membuka Search Dialog | Dialog pencarian tampil |
| 6 | Mengirim kata kunci | SearchView menampilkan hasil dari endpoint `/search` |
| 7 | Membuka artikel | Detail artikel tampil |
| 8 | API key tidak valid | Error HTTP 401 ditampilkan |
| 9 | Jaringan offline | Pesan tidak ada koneksi ditampilkan |
| 10 | Request timeout | Pesan timeout ditampilkan |
| 11 | Response artikel kosong | Empty state ditampilkan |
| 12 | Request gagal lalu retry | Request baru dicoba kembali |

## Screenshot

Simpan screenshot pengujian di folder `screenshots/`. Nama file yang digunakan pada dokumentasi ini:

### Tampilan aplikasi

| Halaman | File screenshot |
|---|---|
| Home / daftar berita | `home-page.png` |
| Hasil pencarian | `search-page.png` |
| Detail berita | `detail-page.png` |

### Dua skenario error wajib

**1. API key salah (HTTP 401)**

![Error API key salah (HTTP 401)](screenshots/error-401-invalid-api-key.png)

File: `screenshots/error-401-invalid-api-key.png`

**2. Tidak ada koneksi internet**

![Error tidak ada koneksi internet](screenshots/error-no-internet.png)

File: `screenshots/error-no-internet.png`

### Screenshot fitur tambahan (opsional)

Apabila sudah diambil, tambahkan screenshot berikut ke folder `screenshots/`:

- `pull-to-refresh.png` – bukti refresh memicu pemuatan ulang kategori aktif.
- `category-future-cache.png` – bukti log `CACHE MISS` dan `CACHE HIT` saat berpindah kategori.

## Keamanan API Key

File `config/env.json` diabaikan oleh Git agar API key tidak masuk ke repository. Namun, penggunaan `--dart-define-from-file` **bukan perlindungan penuh untuk aplikasi production**: nilai yang dikompilasi ke aplikasi dapat diekstrak dari binary, dan key pada Flutter Web dapat terlihat melalui file JavaScript atau request browser.

Untuk aplikasi production, gunakan backend/proxy milik sendiri (misalnya Cloudflare Workers) untuk menyimpan GNews API key sebagai secret server. Jangan mempublikasikan aplikasi production dengan API key pribadi yang ditanam di aplikasi.

## Repository

URL repository GitHub: **[ISI URL REPOSITORY SETELAH REPOSITORY DIBUAT]**

Pastikan repository berstatus **Public** bila itu yang diminta untuk pengumpulan tugas. Periksa kembali bahwa `config/env.json` tidak ikut terunggah.

## Lisensi dan Sumber

Proyek ini dibuat untuk keperluan pembelajaran/praktikum. Data berita dan gambar berasal dari GNews serta media/sumber berita masing-masing. Hak atas artikel, gambar, dan merek tetap berada pada pemiliknya.

- [GNews API](https://gnews.io/)
- [Dokumentasi Flutter](https://docs.flutter.dev/)
- [Dokumentasi Dio](https://pub.dev/packages/dio)
