# Laporan Pengujian Integrasi End-to-End (Integration Test Report)

Dokumen ini memuat catatan resmi hasil pengujian siklus integrasi nyata:
**WPF Frontend (C#) → Go REST API → Microsoft SQL Server Express (`DB_BLT`) → Go REST API → WPF Frontend**.

---

## 1. Ringkasan Eksekusi Pengujian

* **Tanggal Pelaksanaan**: 15 November 2026
* **Database Target**: `10.29.41.125:1433` (`DB_BLT`), User: `bangtek`
* **Layanan Go API**: Berjalan di `http://localhost:8080` (Go 1.27.4 Windows x64)
* **Frontend WPF**: Solusi `CetakDanom.sln` (.NET 8.0 WPF)
* **Total Automated Tests**: **26 Kasus Uji** (21 Domain & Logic Tests + 5 End-to-End Live Integration Tests)
* **Tingkat Kelulusan (*Pass Rate*)**: **100% Lulus (0 Gagal)**

---

## 2. Rincian Kasus Uji Integrasi (Test Cases)

### Test 1 – Database Connectivity (SQL Server Express)
* **Tujuan**: Memastikan Go API dapat membuka connection pool dan melakukan ping ke `DB_BLT` di `10.29.41.125:1433`.
* **Metode**: Panggilan `database.Connect()` dengan driver `github.com/microsoft/go-mssqldb`.
* **Hasil**: **LULUS (Passed)**.
* **Log Verifikasi**:
  ```text
  time=2026-11-15T09:33:53.120+07:00 level=INFO msg="database connection established successfully" host=10.29.41.125 database=DB_BLT max_open_conns=15
  ```

---

### Test 2 – API Connectivity & Standard Contracts
* **Tujuan**: Memvalidasi seluruh endpoint HTTP mengembalikan JSON sesuai kontrak DTO envelope.
* **Hasil per Endpoint**:
  1. `GET /api/v1/health`: Mengembalikan status `"database": "connected"` (HTTP 200).
  2. `GET /api/v1/reference/layanan`: Mengembalikan proyek bansos (SPK1, BMA, PBP1, dll.).
  3. `GET /api/v1/reference/tahap?project_id=SPK1`: Mengembalikan daftar batch (`M1-A10` s.d. `M1-A01`).
  4. `GET /api/v1/reference/kabupaten`: Mengembalikan katalog kabupaten dari tabel `KABUPATEN1`.
  5. `GET /api/v1/reference/kecamatan?kabupaten_id=3273`: Mengembalikan kecamatan di Kota Bandung dari `KECAMATAN1`.
  6. `GET /api/v1/reference/kelurahan?kecamatan_id=327315`: Mengembalikan kelurahan di Bandung Kulon dari `DESA1`.
  7. `GET /api/v1/danom?kelurahan_id=3273151001&batch=M1-A04&project_id=SPK1`: Mengembalikan 67 KPM aktual.
  8. `GET /api/v1/danom/inquiry?nik=1116054107500066`: Mengembalikan data tunggal penerima KPM untuk CDS.
* **Status**: **LULUS (Passed)**.

---

### Test 3 – FE Connectivity & Integration (WPF to Go API)
* **Tujuan**: Memverifikasi antarmuka WPF dapat memanggil Go API melalui `CetakDanomApiClient` dan `ApiDanomRepository`.
* **Uji Coba**:
  * Pengujian unit terotomasi `Test5_WpfApiDanomRepository_FetchesAndCachesActualData`.
  * Pengujian simulasi UI interaktif (`test_wpf_api_ui.ps1`) via Windows UI Automation.
* **Hasil**: **LULUS (Passed)**. Jendela WPF terbuka, data dimuat tanpa freeze, dan DataGrid menampilkan penerima bansos asli.

---

### Test 4 – Data Consistency (Pencocokan Data SQL Server vs API vs WPF)

Dilakukan audit pencocokan langsung antara data mentah SQL Server pada tabel `T_PENERIMA_SPK_MB1` dengan output Go API dan model di WPF:

| Parameter Uji | Kueri SQL Server Langsung | Output Go REST API | Tampilan Frontend WPF | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Wilayah Uji** | Kel. Cijerah (`3273151001`) | Kel. Cijerah (`3273151001`) | Kel. Cijerah | **IDENTIK** |
| **Batch / Tahap** | `M1-A04` | `M1-A04` | `M1-A04` | **IDENTIK** |
| **Total Penerima (KPM)** | **67 Record** | **67 Record** | **67 Record** | **IDENTIK** |
| **Total Akumulasi Nominal** | **Rp 40.200.000** | **Rp 40.200.000** | **Rp 40.200.000** | **IDENTIK** |
| **Record #1 NIK** | `3273152107570001` | `3273152107570001` | `3273152107570001` | **IDENTIK** |
| **Record #1 Nama** | `ADE MULYADI` | `ADE MULYADI` | `ADE MULYADI` | **IDENTIK** |
| **Record #1 Alamat** | `JL. JENDRAL SUDIRMAN GG. MAMA OTTO RW 006 RT 001` | `JL. JENDRAL SUDIRMAN GG. MAMA OTTO RW 006 RT 001` | `JL. JENDRAL SUDIRMAN GG. MAMA OTTO RW 006 RT 001` | **IDENTIK** |
| **Record #1 Nominal** | `600000` | `600000` | `Rp 600.000` (terformat) | **IDENTIK** |
| **Barcode 1 (Pipe Format)** | `SPK32731521075700012` | `SPK32731521075700012` | `SPK32731521075700012` | **IDENTIK** |

---

### Test 5 – Error Handling & Edge Cases
* **Kasus Parameter Kosong**: `GET /api/v1/reference/kecamatan` tanpa `kabupaten_id` mengembalikan HTTP 400 Bad Request dengan pesan berbahasa Indonesia: `"Parameter 'kabupaten_id' (4 digit) wajib diisi."`
* **Kasus NIK Tidak Ditemukan**: `GET /api/v1/danom/inquiry?nik=9999999999999999` mengembalikan HTTP 404 Not Found dengan pesan ramah pengguna.
* **Kasus Backend Down**: Jika Go API dimatikan, `CetakDanomApiClient` menangani pengecualian secara mulus dan mengembalikan list fallback aman sehingga antarmuka pengguna WPF tidak mengalami *crash*.
