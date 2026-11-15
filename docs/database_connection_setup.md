# Petunjuk Konfigurasi & Koneksi Database SQL Server (DB_BLT)

Dokumen ini menjelaskan tata cara menghubungkan Go REST API ke instance Microsoft SQL Server yang memuat data operasional bansos.

---

## 1. Parameter Koneksi SQL Server

Pengaturan koneksi dikendalikan melalui berkas `.env` pada direktori root proyek `go-api/`:

```env
# Lingkungan & Port Server API
APP_ENV=development
APP_PORT=8080

# Alamat Server & Port Database SQL Server
DB_HOST=10.29.41.125
DB_PORT=1433

# Nama Basis Data Aktif
DB_NAME=DB_BLT

# Akun Autentikasi SQL Server
DB_USER=bangtek
DB_PASSWORD=p@ss2020

# Konfigurasi Enkripsi & Sertifikat TLS
# Set 'disable' atau 'false' jika SQL Server tidak menggunakan sertifikat SSL resmi
DB_ENCRYPT=disable
DB_TRUST_SERVER_CERTIFICATE=true

# Pengaturan Connection Pool
DB_MAX_OPEN_CONNS=15
DB_MAX_IDLE_CONNS=5
DB_CONN_MAX_LIFETIME=30m
DB_QUERY_TIMEOUT=30s
```

> [!IMPORTANT]
> Jangan pernah meng-commit berkas `.env` ke repositori git publik. Gunakan berkas `.env.example` sebagai acuan template.

---

## 2. Verifikasi Koneksi Jaringan & Port

Sebelum menjalankan Go API, pastikan mesin pengembang dapat menjangkau server SQL Server:

### Menguji Port 1433 via PowerShell:
```powershell
Test-NetConnection -ComputerName 10.29.41.125 -Port 1433
```
*Hasil yang diharapkan:* `TcpTestSucceeded : True`.

Jika gagal (*False*):
1. Pastikan mesin pengembang terhubung ke VPN / jaringan lokal internal kantor Pos.
2. Pastikan firewall pada IP tujuan mengizinkan lalu lintas TCP port 1433 dari IP lokal.
3. Pastikan layanan *SQL Server Browser* dan protokol TCP/IP telah diaktifkan pada instance SQL Server.

---

## 3. Uji Coba Konektivitas via Health Endpoint

Setelah Go API dijalankan, periksa kesehatan koneksi database secara langsung melalui peramban web atau HTTP client:

```http
GET http://localhost:8080/api/v1/health
```

**Respon Sukses:**
```json
{
  "status": "ok",
  "service": "go-api",
  "database": "connected",
  "timestamp": "2026-11-15T09:34:09.2388666+07:00"
}
```

Jika database tidak dapat dijangkau, respon akan menghasilkan HTTP status 503 (*Service Unavailable*) dengan pesan kesalahan rinci pada field `database`.
