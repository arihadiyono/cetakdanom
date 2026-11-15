# Rencana Implementasi Tahap Lanjutan (Next Implementation Steps)

Setelah pembuktian siklus integrasi **WPF Frontend → Go REST API → SQL Server Express (`DB_BLT`) → Go REST API → WPF Frontend** berhasil 100%, berikut adalah langkah-langkah implementasi tahap berikutnya:

---

## 1. Implementasi Otentikasi Berbasis JWT (JSON Web Token)
* Menambahkan endpoint `POST /api/v1/auth/login` yang memverifikasi User ID dan hash sandi MD5 terhadap tabel `TPETUGAS`.
* Menerbitkan token JWT (*bearer token*) yang menyertakan klaim NOPEND, NIPPOS, dan ID_KANTOR untuk disisipkan pada setiap header panggilan API berikutnya.

---

## 2. Penyimpanan Lokal Terenkripsi (Local Cache SQLite)
* Sesuai arsitektur *dual-mode* (Online vs Mode Offline F5), hasil penarikan data dari `GET /api/v1/danom` disimpan ke dalam basis data lokal terenkripsi SQLite (`danom_local.db`) menggunakan pustaka `SQLCipher` atau enkripsi AES-256 .NET.
* Menggantikan berkas *.pos lama dan meniadakan dependensi pada serialisasi biner `TkbmMemTable`.

---

## 3. Integrasi Endpoint Update Status Penyaluran & Cetak
* Menambahkan endpoint `POST /api/v1/danom/update-status-cetak` untuk mencatat audit trail waktu cetak lembar nominatif ke database SQL Server pusat.
* Menambahkan endpoint `POST /api/v1/danom/update-status-bayar` untuk konfirmasi pembayaran loket.

---

## 4. Pencetakan Fisik Dokumen & Passbook Printer (ESC/P)
* Mengintegrasikan generator PDF presisi tinggi (QuestPDF / FastReport .NET) untuk lembar Daftar Nominatif 20 baris per halaman.
* Mengimplementasikan modul P/Invoke native WinSpool `RawPrinterHelper` untuk pencetakan langsung (*direct print*) ke printer buku tabungan / passbook dot matrix Olivetti PR2 Plus / Epson PLQ-20.

---

## 5. Kontainerisasi & Deployment Go API
* Menyusun `Dockerfile` multi-stage build untuk menghasilkan biner Go API berukuran kecil (< 20 MB).
* Menyusun `docker-compose.yml` yang mencakup reverse proxy (Caddy / Nginx) untuk mengamankan koneksi HTTPS TLS.
