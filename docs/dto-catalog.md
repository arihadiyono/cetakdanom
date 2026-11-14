# Katalog Data Transfer Object (DTO Catalog) - CetakDanom FDPOS

Dokumen ini mendefinisikan seluruh struktur Data Transfer Object (DTO) yang digunakan sebagai kontrak pertukaran data antara **C# .NET Client**, **Go API Middleware**, dan **Microsoft SQL Server**.

---

## 1. Konvensi Tipe Data & Serialisasi

| Tipe Standar JSON | Pemetaan Tipe Go | Pemetaan Tipe C# | Pemetaan Delphi 5/7 | Pemetaan SQL Server |
| :--- | :--- | :--- | :--- | :--- |
| `string` | `string` | `string` | `string` / `AnsiString` | `VARCHAR` / `NVARCHAR` |
| `integer` | `int`, `int64` | `int`, `long` | `Integer`, `LongInt` | `INT`, `BIGINT` |
| `number` | `float64` | `double`, `decimal` | `Double`, `Currency` | `DECIMAL`, `FLOAT` |
| `boolean` | `bool` | `bool` | `Boolean` | `BIT` |
| `date-time` | `time.Time` | `DateTime` | `TDateTime` | `DATETIME`, `DATETIME2` |
| `array` | `[]T` | `List<T>`, `IEnumerable<T>` | `TList`, `Array of ...` | *(Table-valued / Multi-row)* |
| `object` | `struct` | `class`, `record` | `class`, `record` | *(Single Row / JSON)* |

* **Penamaan JSON**: Menggunakan gaya `snake_case` (contoh: `kode_kelurahan`, `id_pelanggan`).
* **Penamaan Properti C#**: Menggunakan gaya `PascalCase` (contoh: `KodeKelurahan`, `IdPelanggan`).
* **Penamaan Field Go**: Menggunakan gaya `PascalCase` dengan tag json (contoh: `KodeKelurahan string ` + "`json:\"kode_kelurahan\"`").

---

## 2. Katalog Request DTO

### 2.1. `LoginRequestDTO`
Digunakan saat petugas melakukan autentikasi dari form login klien desktop.

| Nama Properti JSON | Tipe Go | Tipe C# | Nullable | Validasi & Batasan | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `user_id` | `string` | `string` | Tidak | Min 1, Max 32 karakter | ID Petugas / Username Loket Pos |
| `password` | `string` | `string` | Tidak | Min 1, Max 64 karakter | Kata sandi akun petugas |
| `app_version` | `string` | `string` | Tidak | Regex `^\d+\.\d+\.\d+$` | Versi aplikasi klien (misal `4.1.9`) |

---

### 2.2. `VersionCheckQueryDTO`
Digunakan saat klien memeriksa status versi aplikasi.

| Parameter Query | Tipe Go | Tipe C# | Nullable | Validasi | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `current_version` | `string` | `string` | Tidak | Semver format | Versi klien saat ini |

---

### 2.3. `TahapQueryDTO`
Digunakan saat memfilter nomor tahap penyaluran.

| Parameter Query | Tipe Go | Tipe C# | Nullable | Validasi | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `kode_project` | `string` | `string?` | Ya | Max 10 karakter | Kode project (contoh: `PU1`, `PD01`) |

---

### 2.4. `KecamatanQueryDTO`
Digunakan saat mengambil daftar kecamatan berdasarkan kabupaten.

| Parameter Query | Tipe Go | Tipe C# | Nullable | Validasi | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `kode_kabupaten` | `string` | `string` | Tidak | Tepat 4 digit numerik | Kode wilayah Dati II (contoh: `3273`) |

---

### 2.5. `KelurahanQueryDTO`
Digunakan saat mengambil daftar kelurahan/desa berdasarkan kecamatan.

| Parameter Query | Tipe Go | Tipe C# | Nullable | Validasi | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `kode_kecamatan` | `string` | `string` | Tidak | Tepat 6 s.d. 7 karakter | Kode wilayah kecamatan (contoh: `327301`) |

---

### 2.6. `DanomBatchRequestDTO`
Digunakan untuk mengekstrak seluruh penerima bansos dalam 1 kelurahan tunggal.

| Nama Properti JSON | Tipe Go | Tipe C# | Nullable | Validasi & Batasan | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `kode_kelurahan` | `string` | `string` | Tidak | Max 10 karakter | Kode kelurahan target |
| `nama_kelurahan` | `string` | `string` | Tidak | Max 100 karakter | Nama kelurahan/desa |
| `kode_kecamatan` | `string` | `string` | Tidak | Max 7 karakter | Kode kecamatan target |
| `nama_kecamatan` | `string` | `string` | Tidak | Max 100 karakter | Nama kecamatan |
| `kode_kabupaten` | `string` | `string` | Tidak | Max 7 karakter | Kode kabupaten target |
| `nama_kabupaten` | `string` | `string` | Tidak | Max 100 karakter | Nama kabupaten/kota |
| `kode_layanan` | `string` | `string` | Tidak | 2 digit kode layanan | Kode program bantuan (contoh: `01`) |
| `kode_tahap` | `string` | `string?` | Ya | Max 6 karakter | Nomor tahap penyaluran |

---

### 2.7. `DanomStatusCetakRequestDTO`
Digunakan saat klien mencatat audit bahwa Danom atau Bukti Terima telah dicetak.

| Nama Properti JSON | Tipe Go | Tipe C# | Nullable | Validasi & Batasan | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `kode_kelurahan` | `string` | `string` | Tidak | Max 10 karakter | Kode kelurahan yang dicetak |
| `jenis_dokumen` | `string` | `string` | Tidak | Enum: `DANOM`, `BUKTI_TERIMA`, `SURAT_PERNYATAAN` | Jenis dokumen yang dicetak |
| `total_records_dicetak`| `int` | `int` | Tidak | Min 1 | Jumlah KPM yang dicetak |
| `nama_file_bnba` | `string` | `string?` | Ya | Max 255 karakter | Nama file ekspor CSV BNBA |
| `waktu_cetak` | `time.Time` | `DateTime` | Tidak | Format ISO-8601 | Waktu eksekusi pencetakan fisik |

---

### 2.8. `CdsCekNikRequestDTO`
Digunakan untuk pengecekan data susulan KPM secara *real-time* ke WSO2.

| Nama Properti JSON | Tipe Go | Tipe C# | Nullable | Validasi & Batasan | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `nik` | `string` | `string` | Tidak | Regex `^\d{16}$` | NIK 16 digit KPM |

---

### 2.9. `ParamSuratQueryDTO`
Digunakan untuk mengambil format parameter teks surat pernyataan.

| Parameter Query | Tipe Go | Tipe C# | Nullable | Validasi | Deskripsi |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `id_project` | `string` | `string` | Tidak | 2 karakter (contoh: `PU`, `PD`) | Prefix kode program |
| `subfix` | `string` | `string` | Tidak | 1 karakter (contoh: `1`, `A`) | Subfix tipe surat |

---

## 3. Katalog Response DTO

### 3.1. `ApiResponseWrapperDTO<T>`
Struktur pembungkus generik untuk seluruh respons API.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `success` | `bool` | `bool` | Menandakan status sukses (`true`/`false`) |
| `code` | `int` | `int` | HTTP Status Code (200, 400, 401, dst.) |
| `message` | `string` | `string` | Pesan deskriptif hasil operasi |
| `data` | `T` (generik) | `T` (generik) | Payload data utama |
| `errors` | `[]ErrorDetailDTO` | `List<ErrorDetailDTO>?`| Daftar rincian validasi jika terjadi kesalahan |
| `meta` | `ResponseMetaDTO` | `ResponseMetaDTO` | Metadata audit (request ID, timestamp) |

---

### 3.2. `PetugasProfileDTO`
Data identitas dan otorisasi petugas loket.

| Nama Properti JSON | Tipe Go | Tipe C# | Pemetaan Field Delphi | Pemetaan Kolom SQL Server |
| :--- | :--- | :--- | :--- | :--- |
| `id_petugas` | `string` | `string` | `arrPetugas[0]` | `ID_PETUGAS` |
| `nippos` | `string` | `string` | `arrPetugas[1]` | `NIPPOS` |
| `nama` | `string` | `string` | `arrPetugas[2]` | `NAMA_PETUGAS` |
| `nopend` | `string` | `string` | `arrPetugas[3]` | `NOPEND` |
| `kantor` | `string` | `string` | `arrPetugas[4]` | `NAMA_KANTOR` |
| `jabatan` | `string` | `string` | `arrPetugas[5]` | `JABATAN` |

---

### 3.3. `LoginResponseDTO`
Payload data hasil login sukses.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `token` | `string` | `string` | Token JWT berformat Bearer |
| `token_type` | `string` | `string` | Bernilai konstan `"Bearer"` |
| `expires_in` | `int` | `int` | Masa berlaku token dalam detik (contoh: 28800 = 8 jam) |
| `user` | `PetugasProfileDTO` | `PetugasProfileDTO`| Objek data profil petugas |

---

### 3.4. `WilayahItemDTO`
Item data generik untuk daftar kabupaten, kecamatan, dan kelurahan.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `kode_wilayah` | `string` | `string` | Kode administratif wilayah Kemendagri / BPS |
| `nama_wilayah` | `string` | `string` | Nama resmi wilayah administratif |

---

### 3.5. `LayananItemDTO`
Daftar program bantuan sosial aktif.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `kode_layanan` | `string` | `string` | Kode program (contoh: `01`, `02`) |
| `nama_layanan` | `string` | `string` | Nama program bantuan sosial |

---

### 3.6. `TahapItemDTO`
Daftar termin / tahap penyaluran.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `kode_tahap` | `string` | `string` | Nomor urut tahap (contoh: `1`, `2`, `3`) |
| `nama_tahap` | `string` | `string` | Label visual tahap (contoh: `TAHAP 1`) |
| `periode` | `string?` | `string?` | Periode penyaluran (contoh: `2026-01`) |

---

### 3.7. `DanomBeneficiaryDTO`
Model data entitas KPM penerima bansos (menggabungkan skema stored procedure, SQLite lokal, dan dokumen pelaporan).

| Nama Properti JSON | Tipe Go | Tipe C# | Indeks SP Delphi | Sumber Kolom SQL / Delphi | Deskripsi & Peran Bisnis |
| :--- | :--- | :--- | :---: | :--- | :--- |
| `id_pelanggan` | `string` | `string` | 0 | `ID_PELANGGAN` | Nomor rekening / registrasi Danom KPM |
| `nama` | `string` | `string` | 1 | `PELANGGAN` | Nama lengkap penerima manfaat |
| `alamat` | `string` | `string` | 2 | `ALAMAT` | Alamat domisili penerima saat ini |
| `alamat_ktp` | `string` | `string` | 3 | `ALAMAT_KTP` | Alamat sesuai KTP (untuk Bukti Terima) |
| `nominal` | `int64` | `long` | 6 | `AMOUNT` | Jumlah uang bantuan (Rupiah) |
| `danom` | `string` | `string` | 7 | `DANOM` | Nomor urut halaman/registrasi Danom |
| `kelurahan` | `string` | `string` | 8 | `KELURAHAN` | Nama kelurahan/desa |
| `kecamatan` | `string` | `string` | 10 | `KECAMATAN` | Nama kecamatan |
| `kabupaten` | `string` | `string` | 12 | `KABUPATEN` | Nama kabupaten/kota |
| `provinsi` | `string` | `string` | 14 | `PROPINSI` | Nama provinsi |
| `kantor` | `string` | `string` | 17 | `ID_KANTOR` | Kode Nopend kantor pos bayar |
| `nama_kantor` | `string` | `string` | 16 | `KANTOR` | Nama kantor pos bayar |
| `kprk` | `string` | `string` | 15 | `ID_KPRK` | Kode kantor pos pengendali (Kprk) |
| `nama_kprk` | `string` | `string` | 13 | `KPRK` | Nama Kprk pemeriksa |
| `batch` | `string` | `string` | 19 | `BATCH` | Nomor batch daftar nominatif |
| `regional` | `string` | `string` | 20 | `REGIONAL` | Nomor regional pos (1 s.d. 6) |
| `nik` | `string` | `string` | 21 | `NIK` | Nomor Induk Kependudukan 16 digit |
| `bst` | `string` | `string` | 0 | `BST` | Kode program / identitas BST |
| `percentile` | `string` | `string` | 32 | `PERCENTILE` | Desil kemiskinan DTKS (Desil 1 s.d. 4) |
| `kode_header_danom`| `string` | `string` | - | `idheaderdanom` | Pilihan template Danom (0, 1, 3, 4) |
| `kode_surat_pernyataan`|`string`| `string` | - | `idsp` | Pilihan template kuitansi/pernyataan |

---

### 3.8. `CdsBeneficiaryResponseDTO`
Data hasil verifikasi online KPM susulan dari WSO2 Gateway.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi & Rumus Perhitungan |
| :--- | :--- | :--- | :--- |
| `nik` | `string` | `string` | Nomor Induk Kependudukan |
| `id_pelanggan` | `string` | `string` | Nomor voucher / ID pelanggan |
| `nama` | `string` | `string` | Nama lengkap penerima |
| `alamat` | `string` | `string` | Alamat DTKS |
| `kuantitas` | `int` | `int` | Jumlah kuantitas bantuan |
| `nominal` | `int64` | `long` | Nominal satuan bantuan (Rp) |
| `bsu` | `int64` | `long` | **Kalkulasi**: `kuantitas * nominal` |
| `nama_perusahaan` | `string` | `string` | Nama desa / instansi pemberi kerja |
| `alamat_perusahaan`| `string` | `string` | Alamat instansi pemberi kerja |
| `header_danom` | `string` | `string` | Kementerian penanggung jawab program |
| `provinsi` | `string` | `string` | Provinsi DTKS |
| `kabupaten` | `string` | `string` | Kabupaten/Kota DTKS |
| `kecamatan` | `string` | `string` | Kecamatan DTKS |
| `kelurahan` | `string` | `string` | Kelurahan/Desa DTKS |

---

### 3.9. `ParamSuratResponseDTO`
Redaksional teks format surat pernyataan sembako.

| Nama Properti JSON | Tipe Go | Tipe C# | Deskripsi |
| :--- | :--- | :--- | :--- |
| `judul_surat` | `string` | `string` | Judul resmi dokumen surat pernyataan |
| `klausul_pembuka` | `string` | `string` | Pernyataan pembuka identitas KPM |
| `butir_komitmen` | `[]string` | `List<string>` | Daftar poin komitmen pembelanjaan pangan |
| `klausul_penutup` | `string` | `string` | Teks penutup dan klausul kesediaan sanksi |

---

### 3.10. `ErrorResponseWrapperDTO` & `ErrorDetailDTO`
Struktur standar untuk pesan kesalahan.

```csharp
public class ErrorResponseWrapperDTO
{
    public bool Success { get; set; } = false;
    public int Code { get; set; }
    public string ErrorCode { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public List<ErrorDetailDTO> Errors { get; set; } = new();
    public ResponseMetaDTO Meta { get; set; } = new();
}

public class ErrorDetailDTO
{
    public string Field { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}
```

