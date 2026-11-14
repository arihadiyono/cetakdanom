# Analisis Kesenjangan & Batasan Prototipe (Known Gaps Analysis) - Fase 1

Dokumen ini mendokumentasikan kesenjangan teknis (*technical gaps*), batasan ruang lingkup (*limitations*), dan komponen yang sengaja disimulasikan pada **Fase 1 Desktop Prototype**.

---

## 1. Matriks Kesenjangan Teknis Antara Prototipe dan Sistem Produksi

| Domain | Implementasi Prototipe Fase 1 | Sistem Produksi Nyata | Tingkat Kesenjangan | Risiko & Tindak Lanjut |
| :--- | :--- | :--- | :---: | :--- |
| **Konektivitas Middleware** | `MockDanomRepository` (In-memory C# collection). | Middleware **NCONN** (port 5000/6000, protokol biner 2P) atau **Go API Middleware**. | **Tinggi** | Prototipe tidak menyentuh NCONN. Pada Fase 2, perlu diputuskan apakah mengadopsi Go REST API atau membuat driver C# untuk protokol 2P NCONN. |
| **Kredensial & Autentikasi** | Akun statis demo (`demo`, `petugas01`, `supervisor`) tanpa verifikasi ke server. | Stored Procedure `SIKAP_LOGIN` di SQL Server via NCONN dengan hash `MD5(user_id + password)`. | **Sedang** | Di produksi, login wajib meneruskan token sesi/JWT dan mempertahankan aturan hashing Delphi tanpa fungsi `.Trim()`. |
| **Hardware Printer Passbook** | Pratinjau teks monospace di layar monitor dengan tombol simulasi cetak. | Printer perbankan fisik **IBM 9068A / Epson LQ-300** menggunakan byte kontrol **ESC/P mentah** via `winspool.drv`. | **Tinggi** | Pencetakan langsung ke printer jarum/passbook memerlukan modul P/Invoke WinSpool (`OpenPrinter`, `WritePrinter`). |
| **Penyimpanan Lokal Data Danom** | Koleksi objek memori RAM (hilang saat aplikasi ditutup). | Berkas lokal berformat biner/teks `data/<file>.POS` yang dipindahkan ke `sudah_cetak/`. | **Sedang** | Pada fase selanjutnya, file `.POS` rentan rusak/terkunci ini direkomendasikan diganti dengan database lokal terenkripsi **SQLite (SQLCipher)**. |
| **Integrasi CDS BLT (WSO2)** | Belum diimplementasikan pada Fase 1. | Panggilan SOAP/REST HTTP port 8280 ke Enterprise Service Bus WSO2 Kemensos untuk pengecekan NIK susulan. | **Rendah** | Dapat diimplementasikan menggunakan `HttpClient` modern di C# .NET 8. |
| **Auto-Updater Aplikasi** | Menggunakan versi statis `5.0.0-PROTOTYPE`. | Panggilan proses terpisah `download.exe` via `ShellExecute` dengan parameter berpemisah pipa. | **Rendah** | Dapat diganti dengan solusi modern seperti Velopack atau Squirrel.Windows. |

---

## 2. Aspek yang Berhasil Divalidasi & Tidak Memiliki Gap

1. **Format Ekspor CSV BNBA**:
   * Skema 14 kolom, pemisah titik koma (`;`), dan prefix backtick (`` ` ``) untuk NIK dan Danom telah **100% tervalidasi identik** dengan keluaran prosedur Delphi `TFrm_Main.btn_BNBAClick`.
2. **Kontrak Barcode 2D (QR Code)**:
   * Format susunan 6 segmen berpemisah pipa (`|`) terbukti dapat dirender menjadi bitmap QR Code menggunakan library `QRCoder` (ECC Level M) dan divalidasi oleh unit test.
3. **Pola MVVM & Kerapian UI**:
   * Seluruh logika tampilan terisolasi dari UI XAML. Tidak ada kebocoran aturan bisnis di *code-behind*.
4. **Alur Kerja Pengguna**:
   * Ritme operasional petugas loket (pilih wilayah -> cari KPM -> ekspor data audit BNBA -> cetak Danom fisik -> cetak bukti penerimaan kuitansi) terbukti dapat dijalankan dengan alur yang jauh lebih intuitif dan bersih dibandingkan antarmuka Delphi lawas.
