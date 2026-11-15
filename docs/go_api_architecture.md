# Arsitektur Layanan Go REST API & Pola Integrasi Modernisasi FDPOS

Dokumen ini mendokumentasikan desain arsitektur teknis dari layanan **Go REST API** yang dibangun untuk menggantikan middleware warisan `NasZSvr.exe` (port 1973 proprietary 2P protocol) dalam sistem penyaluran bansos PT Pos Indonesia (CetakDanom / FDPOS).

---

## 1. Topologi Arsitektur Tiga Tingkat (3-Tier Modern)

Topologi modern memisahkan tanggung jawab secara tegas tanpa ada koneksi langsung dari antarmuka desktop ke basis data:

```
+------------------------------------+
|       WPF Desktop Frontend         |
|      (C# .NET 8, MVVM, Views)      |
+-----------------+------------------+
                  | HTTP/JSON REST
                  v
+-----------------+------------------+
|          Go REST API               |
|  (Port 8080, net/http, go-mssqldb) |
|  - Middleware: CORS, Log, Recover  |
|  - Handlers: REST Controller       |
|  - Services: Business Rules        |
|  - Repositories: SP/SQL Dispatcher |
+-----------------+------------------+
                  | TDS Protocol (Port 1433)
                  v
+-----------------+------------------+
|    Microsoft SQL Server Express    |
|   (IP 10.29.41.125 - DB_BLT)       |
|   - Stored Procedures SIKAP_*      |
|   - Tabel Master Wilayah           |
|   - Tabel Partisi Penerima Bansos  |
+------------------------------------+
```

---

## 2. Struktur Proyek Go REST API

Proyek Go API disusun secara modular mengikuti prinsip *Standard Go Project Layout*:

```text
d:\CetakDanom\go-api\
├── cmd\
│   └── api\
│       └── main.go              # Entry point aplikasi, server lifecycle & graceful shutdown
├── internal\
│   ├── config\
│   │   └── config.go            # Manajemen konfigurasi berbasis Environment Variables & .env
│   ├── database\
│   │   └── database.go          # Inisialisasi pool koneksi database (github.com/microsoft/go-mssqldb)
│   ├── models\
│   │   └── models.go            # Entitas domain & amplop JSON (Envelope ApiResponse[T])
│   ├── repositories\
│   │   ├── reference_repository.go # Query Stored Procedure wilayah & metadata bansos
│   │   └── danom_repository.go     # Query Stored Procedure SIKAP_GET_DAFTARNOMINATIF_NAS_V2 & NIK
│   ├── services\
│   │   ├── reference_service.go    # Logika bisnis data referensi
│   │   └── danom_service.go        # Logika bisnis, kalkulasi summary & filter pencarian Danom
│   ├── handlers\
│   │   └── handlers.go          # HTTP Handlers RESTful & error formatting
│   ├── middleware\
│   │   └── middleware.go        # Logging terstruktur (slog), CORS support, & Panic Recovery
│   └── routes\
│       └── routes.go            # Registrasi routing HTTP ServeMux (Go 1.22+ method-based pattern)
├── .env.example                 # Contoh template konfigurasi tanpa kredensial
├── .env                         # Konfigurasi aktif (di-ignore oleh git)
├── .gitignore                   # Mengabaikan biner hasil build dan berkas rahasia
├── go.mod                       # Definisi modul & dependensi
└── README.md                    # Petunjuk instalasi dan operasional
```

---

## 3. Komponen & Lapisan Desain Teknis

### A. Lapisan Database & Connection Pooling (`internal/database`)
* **Driver**: `github.com/microsoft/go-mssqldb` v1.11.2 (driver native resmi Microsoft).
* **Connection Pooling**:
  * `DBMaxOpenConns`: 15 koneksi aktif bersamaan.
  * `DBMaxIdleConns`: 5 koneksi siaga dalam pool.
  * `DBConnMaxLifetime`: 30 menit daur hidup koneksi untuk mencegah koneksi basi (*stale TCP sockets*).
* **Keamanan Koneksi**: Parameter string koneksi disanitasi saat dicatat ke log; kata sandi database dimasking (`******`).

### B. Lapisan Routing & Middleware (`internal/routes`, `internal/middleware`)
* Menggunakan fitur routing native Go (`http.ServeMux`) dengan pola `METHOD /path` tanpa ketergantungan framework eksternal berat.
* **Logging Middleware**: Menggunakan pustaka standar `log/slog` untuk menghasilkan *structured JSON/text logs* memuat metode HTTP, path, waktu eksekusi (*duration*), status respons, dan alamat pemanggil.
* **CORS Middleware**: Membuka header `Access-Control-Allow-Origin: *` dan menangani pre-flight `OPTIONS`.
* **Recovery Middleware**: Melindungi proses Go dari panic pada runtime agar tidak terjadi *crash*, melainkan mengembalikan kode status HTTP 500 terstruktur.

### C. Pemanggilan Stored Procedure Warisan
* Pemanggilan Stored Procedure dilakukan menggunakan parameter terikat (`sql.Named`), mencegah bahaya SQL Injection.
* Mendukung spesifikasi multi-kolom dan delimitasi pipa warisan (misal: parsing `KD_KABUPATEN + '|' + KABUPATEN`).

---

## 4. Keunggulan Dibandingkan Middleware Lama (`NasZSvr.exe`)

| Parameter | Middleware Lama (`NasZSvr.exe`) | Go REST API Baru |
| :--- | :--- | :--- |
| **Protokol** | Proprietary 2P TCP (Port 1973) | Standar HTTP/1.1 REST (JSON) |
| **Format Data** | Binary serialisasi Delphi `TkbmMemTable` | JSON Terbuka (ISO 8601, UTF-8) |
| **Ketergantungan OS** | Terikat Windows Service & Delphi DLLs | Multiplatform (Windows/Linux Docker) |
| **Audit & Log** | Biner tertutup tanpa log terstruktur | Structured Logging (`log/slog`) |
| **Observabilitas** | Sulit dimonitor | Endpoint `/api/v1/health` real-time |
| **Keamanan Kredensial**| Hardcoded / biner `conf.bns` terenkripsi statis | Terisolasi di file `.env` / Environment Vars |
