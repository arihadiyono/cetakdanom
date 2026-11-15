# CetakDanom Go REST API Service

Layanan RESTful API modern berbasis bahasa pemrograman Go yang menggantikan middleware warisan `NasZSvr.exe` (port 1973 protocol 2P) untuk sistem penyaluran bansos PT Pos Indonesia (CetakDanom / FDPOS).

---

## 1. Prasyarat Sistem

* **Go**: Versi 1.22 atau lebih baru (direkomendasikan Go 1.27.4 LTS).
* **Basis Data**: Microsoft SQL Server 2008 / 2012 / 2016 / 2019 / 2022 (terverifikasi pada instance IP `10.29.41.125:1433` database `DB_BLT`).
* **Jaringan**: Port 1433 (SQL Server) dan Port 8080 (REST API) dapat diakses.

---

## 2. Pengaturan Koneksi Basis Data (`.env`)

Salin berkas `.env.example` menjadi `.env` di dalam direktori `go-api/`:

```powershell
Copy-Item .env.example .env
```

Sesuaikan parameter konfigurasi pada `.env`:

```env
APP_ENV=development
APP_PORT=8080

# Kredensial SQL Server
DB_HOST=10.29.41.125
DB_PORT=1433
DB_NAME=DB_BLT
DB_USER=bangtek
DB_PASSWORD=p@ss2020

# Opsi Driver TLS/SSL
DB_ENCRYPT=disable
DB_TRUST_SERVER_CERTIFICATE=true

# Connection Pool
DB_MAX_OPEN_CONNS=15
DB_MAX_IDLE_CONNS=5
DB_CONN_MAX_LIFETIME=30m
DB_QUERY_TIMEOUT=30s
```

---

## 3. Cara Menjalankan Layanan

### A. Menjalankan Go REST API
Dari direktori `d:\CetakDanom\go-api`:

```powershell
# Mengompilasi dan menjalankan langsung:
& "C:\Program Files\Go\bin\go.exe" run .\cmd\api\main.go

# Atau mengompilasi menjadi berkas executable biner:
& "C:\Program Files\Go\bin\go.exe" build -o bin\api.exe .\cmd\api\main.go
.\bin\api.exe
```

Server akan aktif dan melayani permintaan di `http://localhost:8080`.

### B. Menjalankan Frontend WPF (C#)
Dari direktori `d:\CetakDanom`:

```powershell
# Menjalankan aplikasi WPF:
& "C:\Users\user\.dotnet\dotnet.exe" run --project src\CetakDanom.Desktop\CetakDanom.Desktop.csproj

# Atau langsung membuka biner executable:
.\src\CetakDanom.Desktop\bin\Debug\net8.0-windows\CetakDanom.Desktop.exe
```

---

## 4. Daftar Endpoint API Aktif

| Metode | URL Endpoint | Deskripsi |
| :--- | :--- | :--- |
| `GET` | `/api/v1/health` | Status kesehatan API dan pengecekan koneksi live ke SQL Server |
| `GET` | `/api/v1/reference/layanan` | Daftar jenis program bansos (SP `SIKAP_GET_Project_NAS`) |
| `GET` | `/api/v1/reference/tahap?project_id=SPK1` | Daftar tahap/batch penyaluran (SP `SIKAP_GET_TAHAP_NAS`) |
| `GET` | `/api/v1/reference/kabupaten` | Daftar kabupaten/kota (SP `SIKAP_GET_KABUPATEN`) |
| `GET` | `/api/v1/reference/kecamatan?kabupaten_id=3273` | Daftar kecamatan per kabupaten (SP `SIKAP_GET_KECAMATAN`) |
| `GET` | `/api/v1/reference/kelurahan?kecamatan_id=327315` | Daftar kelurahan/desa per kecamatan (SP `SIKAP_GET_KELURAHAN_BYKEC`) |
| `GET` | `/api/v1/danom?kelurahan_id=3273151001&batch=M1-A04&project_id=SPK1` | Daftar KPM aktual (SP `SIKAP_GET_DAFTARNOMINATIF_NAS_V2`) |
| `GET` | `/api/v1/danom/inquiry?nik=1116054107500066` | Pencarian data satu penerima KPM untuk bukti terima CDS |

---

## 5. Cara Menguji Endpoint (PowerShell / cURL)

```powershell
# 1. Health check
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/health"

# 2. Ambil data Danom Kel. Cijerah (Batch M1-A04, Project SPK1)
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/danom?kelurahan_id=3273151001&batch=M1-A04&project_id=SPK1"

# 3. Inquiry NIK penerima aktual (CDS)
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/danom/inquiry?nik=1116054107500066"
```

---

## 6. Panduan Pemecahan Masalah (Troubleshooting)

1. **Error: `connection refused` atau `failed to ping database`**:
   * Periksa apakah port 1433 dapat dijangkau menggunakan:
     `Test-NetConnection -ComputerName 10.29.41.125 -Port 1433`.
   * Periksa kecocokan user (`bangtek`) dan sandi (`p@ss2020`) pada berkas `.env`.
2. **Error: `TLS Handshake / certificate error`**:
   * Pastikan `DB_ENCRYPT=disable` dan `DB_TRUST_SERVER_CERTIFICATE=true` pada berkas `.env`.
3. **WPF Menampilkan Data Kosong**:
   * Pastikan Go REST API telah dijalankan terlebih dahulu pada port 8080 sebelum menjalankan aplikasi WPF.
   * Periksa endpoint `/api/v1/health` apakah statusnya `"database": "connected"`.
