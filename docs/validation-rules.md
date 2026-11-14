# Aturan Validasi Lengkap (Validation Rules Specification) - CetakDanom FDPOS

Dokumen ini mendefinisikan seluruh aturan validasi data, aturan pengamanan (*security & sanitization*), batasan lintas field (*cross-field validation*), dan penanganan kesalahan untuk implementasi **Client C#** dan **Go API Middleware**.

---

## 1. Aturan Validasi Tingkat Field (*Field-Level Validation*)

| Nama Field | Tipe | Wajib | Aturan Panjang & Pola Regex | Deskripsi & Pesan Kesalahan |
| :--- | :---: | :---: | :--- | :--- |
| `user_id` | String | Ya | Min 1, Max 32 karakter.<br/>Regex: `^[a-zA-Z0-9_\-\.]+$` | User ID / ID Petugas loket pos.<br/>*Pesan*: "User ID harus diisi (maksimal 32 karakter alfanumerik)". |
| `password` | String | Ya | Min 1, Max 64 karakter. | Kata sandi akun petugas pos.<br/>*Pesan*: "Kata sandi harus diisi". |
| `app_version` | String | Ya | Regex: `^\d+\.\d+\.\d+$` | Versi aplikasi klien (contoh: `4.1.9`).<br/>*Pesan*: "Format versi aplikasi tidak valid (contoh: 4.1.9)". |
| `nik` | String | Ya | Panjang: **Tepat 16 digit**.<br/>Regex: `^\d{16}$` | Nomor Induk Kependudukan KPM.<br/>*Pesan*: "NIK harus terdiri dari tepat 16 digit angka numerik". |
| `kode_wilayah` | String | Ya | Panjang: 2 s.d. 10 digit.<br/>Regex: `^\d+$` | Kode administratif wilayah Kemendagri / BPS.<br/>*Pesan*: "Kode wilayah harus berupa angka". |
| `kode_kabupaten`| String | Ya | Panjang: **Tepat 4 digit**.<br/>Regex: `^\d{4}$` | Kode Dati II Kota/Kabupaten.<br/>*Pesan*: "Kode kabupaten tidak valid (harus 4 digit angka)". |
| `kode_kecamatan`| String | Ya | Panjang: **Tepat 6 s.d. 7 digit**.<br/>Regex: `^\d{6,7}$` | Kode Dati III Kecamatan.<br/>*Pesan*: "Kode kecamatan tidak valid (harus 6-7 digit angka)". |
| `kode_kelurahan`| String | Ya | Panjang: **Tepat 10 digit**.<br/>Regex: `^\d{10}$` | Kode Dati IV Kelurahan/Desa.<br/>*Pesan*: "Kode kelurahan tidak valid (harus 10 digit angka)". |
| `kode_layanan` | String | Ya | Panjang: **Tepat 2 digit**.<br/>Regex: `^\d{2}$` | Kode program bantuan sosial (contoh: `01`, `02`).<br/>*Pesan*: "Kode layanan harus berupa 2 digit angka". |
| `kode_tahap` | String | Tidak | Panjang: 1 s.d. 6 karakter. | Nomor termin penyaluran bantuan.<br/>*Pesan*: "Kode tahap tidak valid". |
| `jenis_dokumen`| String | Ya | Enum: `DANOM`, `BUKTI_TERIMA`, `SURAT_PERNYATAAN` | Jenis dokumen yang dicetak.<br/>*Pesan*: "Jenis dokumen harus bernilai DANOM, BUKTI_TERIMA, atau SURAT_PERNYATAAN". |
| `total_records`| Integer| Ya | Range: `1 s.d. 100.000` | Jumlah baris data yang diproses.<br/>*Pesan*: "Jumlah record harus minimal 1". |
| `waktu_cetak` | String | Ya | Format: `ISO-8601 UTC+7` | Waktu stempel pencetakan dokumen fisik.<br/>*Pesan*: "Format waktu cetak tidak valid". |

---

## 2. Aturan Validasi Lintas Field (*Cross-Field & Contextual Validation*)

### 2.1. Validasi Rentang Multi-Tahap Penyaluran (Kuitansi Bukti Terima)
Saat mencetak Kuitansi Bukti Terima multi-tahap pada form `Utama.pas` (variabel `cbb_awal` dan `cbbakhir`):
* **Aturan**: Nilai `tahap_akhir` **harus lebih besar atau sama dengan** `tahap_awal`.
* **Kalkulasi Selisih**:
  $$\Delta = \text{tahap\_akhir} - \text{tahap\_awal}$$
  * Jika $\Delta = 0$: Cetak 1 blok kuitansi dan 1 QR Code tunggal.
  * Jika $\Delta = 1$: Cetak 2 blok kuitansi dan 2 QR Code.
  * Jika $\Delta = 2$: Cetak 3 blok kuitansi dan 3 QR Code pada 1 lembar kuitansi.
  * Jika $\Delta < 0$ atau $\Delta > 2$: **Tolak request** (*Validation Error*: "Rentang tahap pencairan tidak valid (maksimal 3 tahap sekaligus)").

### 2.2. Validasi Kuantitas & Nominal BSU (CDS BLT)
Saat menerima data KPM dari respon gateway WSO2:
* **Aturan**:
  * Nilai `kuantitas` harus bernilai integer $\ge 0$. Jika null atau kosong, otomatis diisi nilai *default* `1`.
  * Nilai `nominal` harus bernilai integer $\ge 0$. Jika null atau kosong, otomatis diisi nilai *default* `0`.
  * **Kalkulasi**: $\text{BSU} = \text{kuantitas} \times \text{nominal}$.
  * Dilarang mengonversi string ke integer secara mentah tanpa blok validasi defensif (*pencegahan fatal crash EConvertError Delphi lama*).

---

## 3. Aturan Keamanan, Kriptografi, & Sanitasi Data

### 3.1. Hashing Kata Sandi Petugas (Aturan Preservasi Delphi)
* **Aturan Kritis**: Kata sandi di-hash menggunakan **MD5** dengan menggabungkan string mentah `user_id` dan `password`:
  $$\text{Hash} = \text{MD5}(\text{user\_id} + \text{password})$$
* **Larangan**:
  * **Dilarang keras** melakukan fungsi `.Trim()` pada input kata sandi.
  * **Dilarang keras** mengubah case string (seperti `.ToLower()` atau `.ToUpper()`).
  * Jika pengguna memasukkan spasi di akhir kata sandi pada Delphi lama, hashing MD5 harus memperhitungkan spasi tersebut agar login tetap berhasil.

### 3.2. Spesifikasi Delimiter Wajib Barcode 2D (QR Code) & Kontrak Parsing Antar-Aplikasi
* **Kontrak Integrasi Mutlak (Pipe-Delimited Standard)**:
  * Seluruh data yang dikodekan ke dalam Barcode 2D (QR Code) kuitansi bukti terima **WAJIB terpisah menggunakan karakter pipa (`|`)**.
  * Format pemisah pipa ini merupakan **kontrak protokol integrasi baku** antar-sistem di PT Pos Indonesia, karena perangkat scanner loket pos serta aplikasi hilir (*downstream apps* seperti aplikasi loket kasir/teller pos) membaca dan mem-parsing data kuitansi dengan memecah string hasil scan berdasarkan tanda pipa (`string.Split('|')`).
  * **Larangan**: Dilarang mengganti karakter pemisah pipa (`|`) dengan karakter lain (seperti koma, titik koma, spasi, tab, maupun format JSON) agar tidak merusak fungsi pemindaian di seluruh loket pos.
* **Struktur Susunan 6 Segmen Payload Barcode**:
  $$\text{Payload} = \text{ID\_PELANGGAN\_19DIGIT} + \text{TAHAP} + \text{"|" } + \text{NIK} + \text{"|" } + \text{NAMA} + \text{"|" } + \text{ALAMAT\_KTP} + \text{"|" } + \text{ALAMAT} + \text{"|" } + \text{BSU}$$
  * Contoh output hasil scan: `12345678901234567891|3201021234560001|BUDI SANTOSO|JL CEMPAKA NO 1|DESA SUKAMAJU|600,000`
* **Penanganan Integritas Data Teks Bebas (Defensive Normalization)**:
  * Karena aplikasi lain mengandalkan pemisahan string tepat 6 segmen kolom, maka jika di dalam konten teks nama KPM atau alamat KPM terdapat karakter pipa liar (*accidental pipe character*, misal terketik: `"Jl. Mawar | No. 10"`), karakter pipa di dalam isi field tersebut dinetralisir (misal diganti spasi) saat merangkai payload.
  * Tujuannya adalah melindungi struktur 6 segmen tersebut agar saat di-*split* dengan karakter pipa (`|`) oleh aplikasi lain, jumlah kolom yang dihasilkan tetap tepat 6 kolom dan urutan indeks kolom tidak bergeser (*off-by-one column parsing*).
  * Data hasil pemindaian yang diterima dan dibaca oleh aplikasi lain tetap berformat baku terpisah menggunakan karakter pipa (`|`).

### 3.3. Proteksi Nilai Numerik Panjang pada Ekspor CSV BNBA (Aturan Backtick)
* **Aturan Kritis**: Kolom `NIK` (16 digit) dan nomor `DANOM` yang diekspor ke file CSV BNBA **wajib diawali karakter backtick (`` ` ``)**:
  $$\text{CSV\_Value} = \text{"`"} + \text{NIK\_STRING}$$
* **Tujuan Bisnis**: Mencegah Microsoft Excel mengonversi string numerik 16 digit menjadi notasi ilmiah (*scientific exponential notation*, contoh: `3.20102E+15`) atau memotong angka 0 di digit awal saat file dibuka oleh petugas kelurahan/audit.

### 3.4. Penguncian Hak Akses Berbasis Nopend (Anti-Tampering)
* **Aturan Kritis**:
  * Nilai `nopend` (Kode Kantor Pos Cabang) diambil secara eksklusif dari klaim terenkripsi **JWT Token**, bukan dari input parameter form klien.
  * Go API wajib meneruskan `nopend` dari JWT ke Stored Procedure SQL Server (`@NOPEND`), sehingga pengguna loket tidak dapat memanipulasi form untuk mengakses data KPM milik kantor pos cabang lain.

---

## 4. Aturan Validasi Bisnis Dokumen & Cetak

1. **Pengecekan Kode Status Stored Procedure**:
   * Setiap eksekusi stored procedure autentikasi (`SIKAP_LOGIN`) harus memeriksa kolom status pertama:
     * Jika kode status $= \text{'000'}$: Operasi sukses.
     * Jika kode status $\neq \text{'000'}$: Operasi ditolak, kembalikan pesan kesalahan yang sesuai dari kolom kedua SP.
2. **Aturan Presisi Halaman Dokumen Danom (*Strict Pagination*)**:
   * Setiap lembar dokumen fisik Daftar Nominatif (Danom) **wajib berisi maksimal 20 baris data**.
   * Header laporan (Provinsi, Kabupaten, Kecamatan, Kelurahan, Nopend) wajib diulang di setiap halaman.
   * Total jumlah uang bantuan dan jumlah KPM wajib direkapitulasi secara otomatis di baris terbawah lembar terakhir.
3. **Aturan Cetak Pasca-BNBA**:
   * Klien desktop dilarang mencetak dokumen Danom sebelum berkas `BNBA_*.csv` berhasil dibuat dan disimpan di folder lokal `data/BNBA/`.

---

## 5. Tabel Pemetaan Kode Kesalahan Standar (*Standard Error Codes*)

| Kode Kesalahan (*Error Code*) | HTTP Status | Kondisi Pemicu | Pesan Respons Pengguna (Bahasa Indonesia) |
| :--- | :---: | :--- | :--- |
| `ERR_BAD_REQUEST` | 400 | Format payload JSON tidak valid atau malformed. | "Format permintaan tidak valid atau dokumen JSON rusak." |
| `ERR_VALIDATION_FAILED` | 422 | Satu atau lebih field melanggar aturan validasi data. | "Validasi data gagal. Silakan periksa kembali isian formulir Anda." |
| `ERR_INVALID_CREDENTIALS` | 401 | User ID tidak terdaftar atau kata sandi tidak cocok di SP. | "User ID atau kata sandi yang Anda masukkan salah." |
| `ERR_ACCOUNT_LOCKED` | 403 | Akun petugas dinonaktifkan atau di-suspend oleh admin pusat. | "Akun petugas Anda telah dinonaktifkan. Hubungi Manajer Layanan." |
| `ERR_VERSION_MISMATCH` | 426 | Versi aplikasi klien lebih rendah dari syarat versi minimum. | "Versi aplikasi Anda sudah kedaluwarsa. Silakan lakukan pembaruan." |
| `ERR_UNAUTHORIZED` | 401 | Token JWT tidak disertakan, format salah, atau kadaluwarsa. | "Sesi kerja Anda telah berakhir. Silakan login kembali." |
| `ERR_FORBIDDEN_NOPEND` | 403 | Petugas mencoba mengakses data wilayah di luar Nopend cabangnya.| "Anda tidak memiliki hak akses untuk wilayah kerja kantor pos ini." |
| `ERR_WILAYAH_NOT_FOUND` | 404 | Data wilayah yang diminta tidak ditemukan di database. | "Data wilayah administratif tidak ditemukan." |
| `ERR_DANOM_DATA_EMPTY` | 404 | SP `SIKAP_GET_DATA_BANSOSRS` mengembalikan 0 baris penerima bansos.| "Tidak ada data penerima bantuan untuk kelurahan terpilih." |
| `ERR_NIK_NOT_FOUND` | 404 | NIK KPM susulan tidak ditemukan pada database DTKS WSO2. | "Data NIK tidak terdaftar dalam penerima bantuan susulan (CDS BLT)." |
| `ERR_GATEWAY_TIMEOUT` | 504 | Layanan WSO2 Gateway port 8280 tidak merespons dalam 5 detik. | "Koneksi ke gateway verifikasi NIK mengalami batas waktu (timeout)." |
| `ERR_DB_CONNECTION_FAILED` | 503 | Go API gagal melakukan koneksi ke Microsoft SQL Server. | "Gagal terhubung ke database pusat. Periksa koneksi jaringan Anda." |
| `ERR_INTERNAL_SERVER_ERROR`| 500 | Terjadi kesalahan eksepsi internal yang tidak terduga di server. | "Terjadi kesalahan internal pada server aplikasi." |

