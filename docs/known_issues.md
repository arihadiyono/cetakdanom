# Catatan Kendala Teknis & Karakteristik Database Eksisting (Known Issues & Quirks)

Dokumen ini mencatat temuan khusus, keunikan struktur database warisan (*legacy quirks*), dan solusi yang diimplementasikan pada Go REST API.

---

## 1. Perbedaan Panjang Parameter Project ID pada Stored Procedure Danom
* **Temuan**: Stored procedure versi asli `SIKAP_GET_DAFTARNOMINATIF_NAS` mendefinisikan parameter `@ID_PROJECT varchar(3)`. Ketika aplikasi modern memanggil proyek bansos modern (seperti `'SPK1'` atau `'PBP1'`), nilai terpotong menjadi 3 huruf (`'SPK'`), sehingga query ke tabel `T_REFF_RELASI_PROJECT` menghasilkan 0 baris.
* **Solusi**: Menggunakan stored procedure versi pembaruan yang sudah disediakan pada database yaitu `SIKAP_GET_DAFTARNOMINATIF_NAS_V2` yang telah mendukung `@ID_PROJECT varchar(4)`.

---

## 2. Format Output Berpemisah Pipa (`|`) pada SP Referensi Wilayah
* **Temuan**: Stored procedure `SIKAP_GET_KABUPATEN`, `SIKAP_GET_KECAMATAN`, dan `SIKAP_GET_KELURAHAN_BYKEC` tidak mengembalikan beberapa kolom SQL terpisah, melainkan menggabungkannya menjadi satu baris string berpemisah pipa (contoh: `KD_KABUPATEN + '|' + KABUPATEN`).
* **Solusi**: Di lapisan repository Go (`internal/repositories/reference_repository.go`), string pipa diparsing menggunakan `strings.Split(raw, "|")` dan dinormalisasi menjadi objek JSON bersih dengan field `kode`, `nama`, dan `parent_id`.

---

## 3. Skema Kolom SP `SIKAP_GET_TAHAP_NAS`
* **Temuan**: Dokumentasi lama menyebut SP ini hanya mengembalikan nama batch. Saat dieksekusi langsung pada SQL Server, SP mengembalikan 2 kolom: `ID_TAHAP` (contoh: `M1-A04`) dan `KET_TAHAP` (contoh: `KEMENSOS`).
* **Solusi**: Scanner Go diperbarui untuk memindai kedua kolom (`rows.Scan(&idTahap, &ketTahap)`), lalu mengekspos `ID_TAHAP` sebagai field `batch`.

---

## 4. Autentikasi `TPETUGAS` & Hash Sandi
* **Temuan**: Tabel `TPETUGAS` pada database `DB_BLT` menggunakan format hash MD5 raw 32-karakter lowercase pada kolom `PASS_PETUGAS`.
* **Solusi**: Untuk menjamin kompatibilitas ganda, autentikasi mendukung verifikasi hash MD5 terhadap data petugas di `TPETUGAS`, sekaligus menyediakan akun pengujian lokal (`demo`/`demo123`).
