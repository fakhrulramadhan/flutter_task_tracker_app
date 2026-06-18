# flutter_task_tracker_app

Aplikasi Flutter untuk manajemen task yang terintegrasi dengan REST API Laravel Task Tracker.

---

## Setup & Run

Pastikan Laravel API sudah berjalan di `http://127.0.0.1:8000`.

```bash
flutter pub get
flutter run
```

Untuk menjalankan test terlebih dahulu:

```bash
flutter test          # 35 test cases
flutter analyze       # pengecekan kode
```

---

## Fitur

Fitur utama yang diimplementasikan sesuai requirement:

- **Task list** — menampilkan seluruh task dari API, dilengkapi filter status (semua / pending / done)
- **Tambah task** — form input dengan validasi (judul wajib diisi, minimal 3 karakter, maksimal 255 karakter)
- **Detail task** — menampilkan informasi lengkap task beserta timestamp pembuatan dan update terakhir
- **Toggle status** — mengganti status task antara done dan pending, bisa dari halaman list maupun detail
- **Hapus task** — dilengkapi dialog konfirmasi sebelum eksekusi

Fitur tambahan yang dikembangkan:

- **Cache lokal** — task list disimpan ke SharedPreferences dengan masa berlaku 5 menit, sehingga data tetap tersedia meskipun API sedang bermasalah
- **Offline support** — saat koneksi terputus, aplikasi otomatis menampilkan data dari cache. Terdapat banner pemberitahuan offline serta indikator status koneksi di AppBar
- **Infinite scroll** — menerapkan pagination dengan 10 item per halaman. Data halaman berikutnya otomatis dimuat saat pengguna menggulir ke bawah
- **Repository pattern** — memisahkan sumber data dari Bloc melalui layer repository. Bloc hanya perlu memanggil repository tanpa mengetahui asal data (API atau cache)
- **Reusable widgets** — komponen seperti loading indicator, error message, empty state, offline banner, dan connectivity indicator dipisahkan ke dalam `core/components/` agar dapat digunakan kembali

---

## Struktur Project

Project ini menggunakan arsitektur 3-layer dengan Repository Pattern dan Bloc sebagai state management. Struktur ini mengacu pada project referensi flutter_ayo_piknik.

```
lib/
├── core/
│   ├── components/       # widget reusable (loading, error, empty, dsb)
│   ├── constants/        # colors, base URL
│   └── services/         # connectivity service (stream)
├── data/
│   ├── datasources/      # remote (http) + local (SharedPreferences)
│   ├── models/           # TaskModel + response models
│   └── repositories/     # TaskRepository (single source of truth)
├── presentation/
│   └── task/
│       ├── blocs/        # event, state, bloc
│       ├── pages/        # task_list, add_task, task_detail
│       └── widgets/      # task_card
└── main.dart
```

### Penjelasan Arsitektur

Pendekatan yang diambil adalah memisahkan kode ke dalam tiga layer utama agar setiap bagian memiliki tanggung jawab yang jelas:

- **`data/`** — menangani pengambilan dan penyimpanan data, baik dari API maupun cache lokal. Jika terjadi perubahan pada endpoint atau struktur response JSON, perbaikan cukup dilakukan pada layer ini
- **`presentation/`** — menangani tampilan UI dan state management. Halaman hanya bertugas menampilkan data, sementara logika bisnis diatur oleh Bloc
- **`core/`** — berisi konstanta, widget yang digunakan di berbagai tempat, dan service yang bersifat umum

Repository berperan sebagai jembatan antara layer data dan presentation. Bloc cukup memanggil `repository.getTasks()` tanpa perlu mengetahui apakah data berasal dari API atau cache. Pola ini juga memudahkan pengujian karena repository dapat di-mock tanpa perlu menyentuh HTTP client.

### Alasan Memilih Bloc

Beberapa pertimbangan dalam memilih Bloc dibandingkan alternatif lain:

- Aplikasi ini memiliki operasi asynchronous yang cukup banyak — GET, POST, PATCH, PUT, DELETE — ditambah pagination dan penanganan offline
- Provider akan menjadi kurang terkelola ketika state yang ditangani semakin banyak, karena harus membuat banyak ChangeNotifier
- Bloc memberikan alur yang jelas: event → state. Setiap transisi state dapat dilacak dengan mudah saat debugging
- Bloc adalah pure Dart class, sehingga dapat diuji secara unit test tanpa Flutter framework (terbukti pada 19 unit test yang berhasil dijalankan)

**Mengapa tidak menggunakan Provider?** Provider lebih cocok untuk state yang sederhana. Untuk aplikasi dengan banyak operasi async dan berbagai state (loading, success, error, empty), Bloc memberikan kontrol yang lebih terstruktur.

**Mengapa tidak menggunakan Riverpod?** Riverpod adalah library yang powerful, namun tingkat kompleksitasnya relatif lebih tinggi. Untuk skala project ini, Bloc dengan pendekatan Event → State sudah memadai dan lebih eksplisit.

**Mengapa tidak menggunakan GetX?** GetX menggabungkan routing, dependency injection, dan state management dalam satu paket, yang menurut saya melanggar prinsip separation of concerns.

### Strategi Penanganan Offline

Penyimpanan lokal menggunakan SharedPreferences karena struktur data yang disimpan relatif sederhana (list task dalam format JSON). Tidak diperlukan database lokal seperti sqflite atau Hive.

Alur penanganan offline:

1. Fetch data dari API terlebih dahulu
2. Jika berhasil → tampilkan data dan simpan ke cache lokal
3. Jika gagal → coba ambil data dari cache
4. Jika cache juga kosong → tampilkan pesan error

Untuk deteksi status koneksi, digunakan package `connectivity_plus` yang menyediakan stream sehingga UI dapat langsung merespons perubahan status (menampilkan atau menyembunyikan banner offline).

---

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.0.0       # state management
  http: ^1.2.2                # http client
  dartz: ^0.10.1              # Either type (success/failure pattern)
  google_fonts: ^6.2.1        # font Inter
  intl: ^0.19.0               # date format
  shared_preferences: ^2.3.5  # local cache
  connectivity_plus: ^6.1.1   # network detection

dev_dependencies:
  mocktail: ^1.0.4            # mocking untuk unit test
  flutter_test: sdk           # widget test
```

---

## Testing

Total 35 test cases terbagi menjadi:

### Unit test (19)
- **task_model_test.dart** — pengujian serialization JSON, helper method (`statusLabel`, `shortDescription`), penanganan null values
- **task_bloc_test.dart** — pengujian seluruh transisi event → state menggunakan MockTaskRepository. Mencakup GetTasks, GetTaskDetail, CreateTask, UpdateTaskStatus, DeleteTask, ResetTaskForm

### Widget test (16)
- **task_card_test.dart** — pengujian render title, description, status label, warna pending vs done, callback onTap/onToggle/onDelete
- **components_test.dart** — pengujian LoadingIndicator, ErrorMessage (termasuk tombol retry), EmptyState, OfflineBanner, ConnectivityIndicator

Menjalankan test:

```bash
flutter test              # seluruh test
flutter test test/unit/   # unit test saja
flutter test test/widget/ # widget test saja
```

---

## API Endpoints

Seluruh request mengarah ke `http://127.0.0.1:8000/api/...`

| Method | Endpoint | Penggunaan |
|--------|----------|-------------|
| GET | `/tasks` | List task + pagination |
| GET | `/tasks?status=pending` | Filter task pending |
| GET | `/tasks?status=completed` | Filter task completed |
| GET | `/tasks/{id}` | Detail task |
| POST | `/tasks` | Membuat task baru |
| PATCH | `/tasks/{id}` | Update sebagian (status) |
| PUT | `/tasks/{id}` | Update seluruh data task |
| DELETE | `/tasks/{id}` | Menghapus task |

Format response API standar: `{ success: bool, message: string, data: ... }`

---

## Catatan Teknis

- Base URL disimpan di `lib/core/constants/variables.dart`. Jika perlu diubah, cukup edit satu file tersebut
- Durasi cache diatur di `TaskLocalDatasource._cacheExpiry`, default 5 menit
- Jumlah item per halaman pagination diatur di `TaskBloc._perPage`, default 10
- Project ini tidak menggunakan code generation (freezed/json_serializable) agar build tetap ringan dan konfigurasi sederhana
