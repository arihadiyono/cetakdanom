# Pemetaan Fitur Frontend WPF ke Go REST API & Database SQL Server (DB_BLT)

Dokumen ini memuat hasil audit dan pemetaan nyata (*evidence-based traceability*) antara antarmuka pengguna WPF (C#), rancangan endpoint Go REST API, dan basis data Microsoft SQL Server (`DB_BLT` pada `10.29.41.125`).

---

## 1. Lingkungan Basis Data Terverifikasi

* **Host Server**: `10.29.41.125:1433` (SQL Server 2008 / Version 10.00.1600)
* **Kredensial**: User `bangtek`, terverifikasi aktif dengan mode SQL Server Authentication
* **Basis Data Operasional**: `DB_BLT`
* **Status Konektivitas**: **ONLINE & ACCESSIBLE** (Pengujian TCP Port 1433 dan ADO.NET berhasil)

---

## 2. Matriks Pemetaan Fitur, Endpoint, dan Objek Database

| FE Feature | API Endpoint | Table / View / Stored Procedure | Field Mapping (Database → API JSON → FE DTO) | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Konektivitas & Health Check** | `GET /api/v1/health` | Query SQL: `SELECT 1` | `status`: "ok", `database`: "connected" | **VERIFIED** |
| **Pilih Jenis Bansos (Menu 1)** | `GET /api/v1/reference/layanan` | SP: `SIKAP_GET_Project_NAS`<br>Tabel: `refProject_NAS`, `T_REFF_EXTEND_PROJECT` | `idproject` → `Kode`<br>`Deskripsi` → `Nama`<br>`HEADER_DANOM` → `HeaderDanom` | **VERIFIED** |
| **Pilih Tahap/Batch (Menu 1)** | `GET /api/v1/reference/tahap?project={id}` | SP: `SIKAP_GET_TAHAP_NAS` | `BATCH` (contoh: `M1-A04`, `M1-A05`) → `tahap_list` | **VERIFIED** |
| **Hierarki Kabupaten (Menu 1)** | `GET /api/v1/reference/kabupaten` | SP: `SIKAP_GET_KABUPATEN`<br>Tabel: `KABUPATEN1` | String Delimiter: `KD_KABUPATEN+'\|'+KABUPATEN`<br>Diparsing menjadi: `kode`, `nama` | **VERIFIED** |
| **Hierarki Kecamatan (Menu 1)** | `GET /api/v1/reference/kecamatan?kabupaten_id={id}` | SP: `SIKAP_GET_KECAMATAN`<br>Tabel: `KECAMATEN1` | Param: `@IDKECAMATAN = kab_id (4 digit)`<br>Output: `KD_KECAMATAN+'\|'+KECAMATAN` | **VERIFIED** |
| **Hierarki Kelurahan (Menu 1)** | `GET /api/v1/reference/kelurahan?kecamatan_id={id}` | SP: `SIKAP_GET_KELURAHAN_BYKEC`<br>Tabel: `DESA1`, `KECAMATAN1` | Param: `@IDKECAMATAN = kec_id (6 digit)`<br>Output: `KD_DESA+'\|'+DESA+'\|'+KECAMATAN` | **VERIFIED** |
| **Unduh Data Danom (Menu 1)** | `GET /api/v1/danom` | SP: `SIKAP_GET_DAFTARNOMINATIF_NAS_V2`<br>Tabel Partisi: `T_PENERIMA_SPK_MB1` (atau sesuai `T_REFF_RELASI_PROJECT`) | • `NIK` → `nik`<br>• `PELANGGAN` → `nama`<br>• `ALAMAT` → `alamat`<br>• `AMOUNT` → `nominal`<br>• `ID_PELANGGAN` → `id_pelanggan`<br>• `BATCH` → `tahap`<br>• `KELURAHAN` → `kelurahan`<br>• `KECAMATAN` → `kecamatan`<br>• `KABUPATEN` → `kabupaten`<br>• `BS1` → `barcode_1` | **VERIFIED** |
| **Tampil Data & Grid (Menu 2)** | `GET /api/v1/danom` | Cache Lokal / In-Memory / Query API Danom | Menampilkan daftar penerima bansos aktual | **VERIFIED** |
| **Ekspor BNBA CSV (Menu 2)** | Berbasis Data Danom API | Dataset `T_PENERIMA_*` | 14 Kolom Standar BNBA dengan tanda kutip backtick (`` ` ``) | **VERIFIED** |
| **Cetak Danom Satuan (Menu 4)** | `GET /api/v1/danom/inquiry?nik={nik}` | SP: `AMBIL_NIK` / Tabel: `T_PENERIMA_SPK_MB1` | Mengambil data satu NIK penerima aktual untuk kuitansi CDS | **VERIFIED** |
| **Autentikasi Petugas** | `POST /api/v1/auth/login` | Tabel: `TPETUGAS` | Kolom: `ID_PETUGAS`, `PASS_PETUGAS` (Hash MD5), `ID_KANTOR` (NOPEND), `ID_PEGAWAI` (NIPPOS) | **VERIFIED** |

---

## 3. Rincian Parameter Stored Procedure Utama

### A. `SIKAP_GET_DAFTARNOMINATIF_NAS_V2`
* **Input Parameters**:
  * `@IDKELURAHAN` (`varchar(12)`): Kode Kelurahan 10 digit (contoh: `3273151001` untuk Cijerah).
  * `@NOPEND` (`varchar(7)`): Nopend Kantor Pos (contoh: `40000`).
  * `@ID_PETUGAS` (`varchar(15)`): ID Petugas penarik data.
  * `@NIPPOS` (`varchar(9)`): Nomor Identitas Pegawai Pos.
  * `@OPT` (`varchar(3)`): Kode opsi sistem (standar: `'0'`).
  * `@BATCH` (`varchar(6)`): Kode Tahap/Batch (contoh: `'M1-A04'`).
  * `@SORT` (`varchar(6)`): Mode sortir (`'Nama'` atau `'Alamat'`).
  * `@ID_PROJECT` (`varchar(4)`): ID Project Bansos (contoh: `'SPK1'` untuk Sembako & PKH).
* **Output Schema**:
  33 Kolom termasuk `ID_PELANGGAN`, `PELANGGAN`, `ALAMAT`, `AMOUNT`, `KUANTITAS`, `TOTAL`, `NIK`, `KELURAHAN`, `KECAMATAN`, `KABUPATEN`, `BATCH`, `BS1`.

### B. `SIKAP_GET_KABUPATEN`
* **Output Format**: Baris string pipa: `KD_KABUPATEN + '|' + KABUPATEN` (misal: `3273|KOTA BANDUNG`).

### C. `SIKAP_GET_KECAMATAN`
* **Input Parameter**: `@IDKECAMATAN` (`varchar(7)`) berupa kode kabupaten 4 digit (misal: `3273`).
* **Output Format**: Baris string pipa: `KD_KECAMATAN + '|' + KECAMATAN` (misal: `327315|BANDUNG KULON`).

### D. `SIKAP_GET_KELURAHAN_BYKEC`
* **Input Parameter**: `@IDKECAMATAN` (`varchar(7)`) berupa kode kecamatan 6 digit (misal: `327315`).
* **Output Format**: Baris string pipa: `KD_DESA + '|' + DESA + '|' + KECAMATAN` (misal: `3273151001|CIJERAH|BANDUNG KULON`).
