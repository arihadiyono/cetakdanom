# Spesifikasi Kontrak API (API Contract Specification) - CetakDanom FDPOS

## 1. Standar Arsitektur & Konvensi Global

### 1.1. Informasi Dasar
* **Versi Spesifikasi**: `1.0.0`
* **Protokol**: `HTTPS` (dikelola oleh Caddy Reverse Proxy dengan auto-TLS)
* **Base URL**: `https://fdpos-api.posindonesia.co.id/api/v1`
* **Format Data**: `application/json` (Encoding: `UTF-8`)
* **Timezone**: `Asia/Jakarta` (`WIB` / `UTC+7`, format ISO-8601: `YYYY-MM-DDTHH:mm:ss+07:00`)

---

### 1.2. Standar Header HTTP
| Nama Header | Tipe | Wajib | Keterangan |
| :--- | :---: | :---: | :--- |
| `Content-Type` | String | Ya | Wajib bernilai `application/json`. |
| `Accept` | String | Ya | Wajib bernilai `application/json`. |
| `Authorization` | String | Kondisional | Format: `Bearer <JWT_TOKEN>`. Wajib untuk seluruh endpoint terproteksi. |
| `X-App-Version` | String | Ya | Versi aplikasi klien (contoh: `4.1.9`). |
| `X-Client-ID` | String | Ya | Identifier unik instalasi klien / Machine GUID. |
| `X-Request-ID` | String | Tidak | UUID v4 untuk penelusuran log terdistribusi (*request tracing*). |

---

### 1.3. Format Pembungkus Respons Standar (*Standard Response Wrapper*)

#### A. Respons Sukses (`HTTP 200 / 201`)
```json
{
  "success": true,
  "code": 200,
  "message": "Operasi berhasil dilakukan",
  "data": {},
  "meta": {
    "request_id": "c1f7b3a4-8b65-4f3e-9f12-3456789abcde",
    "timestamp": "2026-11-12T09:35:00+07:00",
    "version": "4.1.9"
  }
}
```

#### B. Respons Kesalahan (*Error Response* - `HTTP 400 / 401 / 403 / 404 / 422 / 500`)
```json
{
  "success": false,
  "code": 400,
  "error_code": "ERR_VALIDATION_FAILED",
  "message": "Validasi input gagal",
  "errors": [
    {
      "field": "nik",
      "message": "NIK harus berjumlah tepat 16 digit numerik"
    }
  ],
  "meta": {
    "request_id": "c1f7b3a4-8b65-4f3e-9f12-3456789abcde",
    "timestamp": "2026-11-12T09:35:00+07:00"
  }
}
```

---

## 2. Rincian Spesifikasi Endpoint API

---

### 2.1. POST `/auth/login`
Memvalidasi kredensial petugas loket pos, melakukan pengecekan versi aplikasi ke database, mengurai profil petugas, dan menerbitkan JWT token.

* **URL**: `/api/v1/auth/login`
* **HTTP Method**: `POST`
* **Authentication Requirement**: **Public (None)**
* **Stored Procedure**: `SIKAP_LOGIN`
  * Mapping Parameter:
    * `@ID_PETUGAS` &larr; `Request.user_id`
    * `@PASS_PETUGAS` &larr; `MD5(Request.user_id + Request.password)` *(raw string concatenation)*
    * `@APPVERSI` &larr; `Request.app_version`
* **Business Rule yang Terpengaruh**:
  * [BR-01] Hashing kata sandi wajib `MD5(user_id + password)`.
  * [BR-02] Kunci versi aplikasi (*version locking*).
  * [BR-03] Parsing profil string pipa petugas (`IdPetugas|Nippos|Nama|Nopend|Kantor|Jabatan`).
  * [GAP-01] Sensitivitas karakter spasi & huruf kapital: Dilarang melakukan `.Trim()` atau `.ToLower()` otomatis pada user_id dan password sebelum proses hashing MD5.

#### Request DTO (`LoginRequestDTO`)
```json
{
  "user_id": "12045",
  "password": "p@ssw0rdLoket2026!",
  "app_version": "4.1.9"
}
```

#### Response DTO Sukses 200 (`LoginResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Otentikasi berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 28800,
    "user": {
      "id_petugas": "12045",
      "nippos": "987654321",
      "nama": "AHMAD JUNAEDI",
      "nopend": "40100",
      "kantor": "KANTOR POS BANDUNG",
      "jabatan": "MAN LAYANAN"
    }
  },
  "meta": {
    "request_id": "c1f7b3a4-8b65-4f3e-9f12-3456789abcde",
    "timestamp": "2026-11-12T09:35:00+07:00"
  }
}
```

#### Validation Rules
1. `user_id`: Wajib diisi, tipe string, panjang 1 - 32 karakter.
2. `password`: Wajib diisi, tipe string, panjang 1 - 64 karakter.
3. `app_version`: Wajib diisi, format semver regex `^\d+\.\d+\.\d+$`.

#### Error Responses
* `400 Bad Request`: Payload JSON tidak valid.
* `401 Unauthorized` (`ERR_INVALID_CREDENTIALS`): Jika SP mengembalikan kode selain `000` (contoh: password salah).
* `426 Upgrade Required` (`ERR_VERSION_MISMATCH`): Jika SP menolak karena versi klien kedaluwarsa.

---

### 2.2. GET `/auth/me`
Mengambil profil petugas aktif dan izin cabang berdasarkan JWT token.

* **URL**: `/api/v1/auth/me`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: *(None - Data diekstrak dari klaim token & cache sesi)*
* **Business Rule yang Terpengaruh**:
  * [GAP-02] Integritas Nopend: Data kantor cabang dibaca dari klaim JWT terenkripsi untuk mencegah modifikasi Nopend oleh pengguna.

#### Request DTO
*(Tidak memerlukan request body)*

#### Response DTO Sukses 200 (`UserProfileResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Profil petugas berhasil diambil",
  "data": {
    "id_petugas": "12045",
    "nippos": "987654321",
    "nama": "AHMAD JUNAEDI",
    "nopend": "40100",
    "kantor": "KANTOR POS BANDUNG",
    "jabatan": "MAN LAYANAN"
  }
}
```

---

### 2.3. GET `/app/version`
Memeriksa integritas versi aplikasi klien dan menyediakan manifest pembaruan binary otomatis (menggantikan logika form `uUpdate.pas`).

* **URL**: `/api/v1/app/version`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Public (None)**
* **Stored Procedure**: *(None - Membaca konfigurasi server / database config)*
* **Business Rule yang Terpengaruh**:
  * [BR-10] Auto-update workflow.

#### Request Query Parameters (`VersionCheckQueryDTO`)
* `current_version` (String, required): Versi klien aktif (contoh: `4.1.9`).

#### Response DTO Sukses 200 (`VersionCheckResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Pengecekan versi berhasil",
  "data": {
    "is_latest": false,
    "current_version": "4.1.9",
    "latest_version": "4.2.0",
    "mandatory_update": true,
    "release_date": "2026-11-19",
    "download_url": "https://fdpos-api.posindonesia.co.id/api/v1/app/download/CetakDanom-Setup-v4.2.0.exe",
    "checksum_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "release_notes": "Pembaruan template cetak dan keamanan koneksi"
  }
}
```

---

### 2.4. GET `/wilayah/layanan`
Mengambil daftar program bantuan sosial yang aktif (memetakan event `FormShow` dan ComboBox Layanan pada form `Utama.pas`).

* **URL**: `/api/v1/wilayah/layanan`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_LAYANAN`
  * Mapping Parameter: *(Tanpa parameter)*
  * Output SP: `Fields[0]` (Kode Layanan), `Fields[1]` (Nama Layanan)
* **Business Rule yang Terpengaruh**:
  * [BR-04] Hierarki administratif wilayah tingkat 1.

#### Response DTO Sukses 200 (`LayananListResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Daftar layanan berhasil diambil",
  "data": [
    {
      "kode_layanan": "01",
      "nama_layanan": "BANTUAN SOSIAL TUNAI (BST)"
    },
    {
      "kode_layanan": "02",
      "nama_layanan": "PROGRAM SEMBAKO / BPNT"
    },
    {
      "kode_layanan": "03",
      "nama_layanan": "BANTUAN SUBSIDI UPAH (BSU)"
    },
    {
      "kode_layanan": "04",
      "nama_layanan": "BANTUAN YATIM PIATU (YAPI)"
    }
  ]
}
```

---

### 2.5. GET `/wilayah/tahap`
Mengambil daftar nomor tahap penyaluran yang tersedia untuk jenis layanan tertentu.

* **URL**: `/api/v1/wilayah/tahap`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_TAHAP` *(atau `SIKAP_GET_TAHAP_KOTAKAB` jika parameter project terisi)*
  * Mapping Parameter:
    * `@PROJECT` &larr; `Query.kode_project` (opsional)
* **Business Rule yang Terpengaruh**:
  * [BR-06] Kondisi dinamis multi-tahap pada kuitansi QR Code.

#### Request Query Parameters (`TahapQueryDTO`)
* `kode_project` (String, opsional): Kode proyek spesifik (contoh: `PU1`, `PD01`).

#### Response DTO Sukses 200 (`TahapListResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Daftar tahap penyaluran berhasil diambil",
  "data": [
    {
      "kode_tahap": "1",
      "nama_tahap": "TAHAP 1",
      "periode": "2026-01"
    },
    {
      "kode_tahap": "2",
      "nama_tahap": "TAHAP 2",
      "periode": "2026-02"
    },
    {
      "kode_tahap": "3",
      "nama_tahap": "TAHAP 3",
      "periode": "2026-03"
    }
  ]
}
```

---

### 2.6. GET `/wilayah/kabupaten`
Mengambil daftar kabupaten/kota yang berada di bawah wilayah kerja Kantor Pos pemeriksa (Nopend).

* **URL**: `/api/v1/wilayah/kabupaten`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_KABUPATEN`
  * Mapping Parameter:
    * `@NOPEND` &larr; `JWT.Claims.nopend`
    * `@ID_PETUGAS` &larr; `JWT.Claims.id_petugas`
    * `@NIPPOS` &larr; `JWT.Claims.nippos`
    * `@JENIS` &larr; `'0'` *(Delphi 7 contract)*
* **Business Rule yang Terpengaruh**:
  * [BR-04] Otorisasi wilayah geografis berjenjang.
  * [GAP-02] Parameter Nopend dikunci dari klaim JWT untuk mencegah akses lintas cabang.

#### Request Query Parameters
*(Tidak membutuhkan parameter query eksternal; parameter diambil dari klaim JWT)*

#### Response DTO Sukses 200 (`WilayahListResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Daftar kabupaten berhasil diambil",
  "data": [
    {
      "kode_wilayah": "3273",
      "nama_wilayah": "KOTA BANDUNG"
    },
    {
      "kode_wilayah": "3204",
      "nama_wilayah": "KABUPATEN BANDUNG"
    }
  ]
}
```

---

### 2.7. GET `/wilayah/kecamatan`
Mengambil daftar kecamatan di bawah kabupaten terpilih.

* **URL**: `/api/v1/wilayah/kecamatan`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_KECAMATAN`
  * Mapping Parameter:
    * `@ID_KABUPATEN` &larr; `Query.kode_kabupaten`
    * `@NOPEND` &larr; `JWT.Claims.nopend`
    * `@ID_PETUGAS` &larr; `JWT.Claims.id_petugas`
    * `@NIPPOS` &larr; `JWT.Claims.nippos`
    * `@JENIS` &larr; `'0'`
* **Business Rule yang Terpengaruh**: [BR-04]

#### Request Query Parameters (`KecamatanQueryDTO`)
* `kode_kabupaten` (String, wajib): Kode Kabupaten (contoh: `3273`).

#### Response DTO Sukses 200 (`WilayahListResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Daftar kecamatan berhasil diambil",
  "data": [
    {
      "kode_wilayah": "327301",
      "nama_wilayah": "COBLONG"
    },
    {
      "kode_wilayah": "327302",
      "nama_wilayah": "SUKAJADI"
    }
  ]
}
```

---

### 2.8. GET `/wilayah/kelurahan`
Mengambil daftar kelurahan/desa di bawah kecamatan terpilih.

* **URL**: `/api/v1/wilayah/kelurahan`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_KELURAHAN_BYKEC`
  * Mapping Parameter:
    * `@ID_KECAMATAN` &larr; `Query.kode_kecamatan`
    * `@NOPEND` &larr; `JWT.Claims.nopend`
    * `@ID_PETUGAS` &larr; `JWT.Claims.id_petugas`
    * `@NIPPOS` &larr; `JWT.Claims.nippos`
    * `@JENIS` &larr; `'0'`
* **Business Rule yang Terpengaruh**: [BR-04], [BR-05] Granulitas file data per kelurahan.

#### Request Query Parameters (`KelurahanQueryDTO`)
* `kode_kecamatan` (String, wajib): Kode Kecamatan (contoh: `327301`).

#### Response DTO Sukses 200 (`WilayahListResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Daftar kelurahan berhasil diambil",
  "data": [
    {
      "kode_wilayah": "3273010001",
      "nama_wilayah": "DAGO"
    },
    {
      "kode_wilayah": "3273010002",
      "nama_wilayah": "LEBAKGEDE"
    }
  ]
}
```

---

### 2.9. POST `/danom/batch`
Melakukan ekstraksi data massal nominatif penerima bansos untuk 1 kelurahan tertentu (menggantikan prosedur `GetData` pada `Utama.pas:1383-1473`).

* **URL**: `/api/v1/danom/batch`
* **HTTP Method**: `POST`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_GET_DATA_BANSOSRS`
  * Mapping Parameter:
    * `@ID_KELURAHAN` &larr; `Request.kode_kelurahan`
    * `@KODE_JENIS` &larr; `Request.kode_layanan` (2 karakter pertama, contoh: `01`)
    * `@FLAG` &larr; `'0'`
* **Business Rule yang Terpengaruh**:
  * [BR-04] Granulitas batch data per kelurahan tunggal.
  * [BR-06] Skema data lengkap untuk QR Code & cetak Danom.
  * [GAP-03] Normalisasi 24 kolom stored procedure ke model data terstruktur (menghilangkan ketergantungan file flat `.POS`).

#### Request DTO (`DanomBatchRequestDTO`)
```json
{
  "kode_kelurahan": "3273010001",
  "nama_kelurahan": "DAGO",
  "kode_kecamatan": "327301",
  "nama_kecamatan": "COBLONG",
  "kode_kabupaten": "3273",
  "nama_kabupaten": "KOTA BANDUNG",
  "kode_layanan": "01",
  "kode_tahap": "1"
}
```

#### Response DTO Sukses 200 (`DanomBatchResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Data nominatif berhasil diekstraksi",
  "data": {
    "total_records": 2,
    "kode_kelurahan": "3273010001",
    "nama_kelurahan": "DAGO",
    "items": [
      {
        "id_pelanggan": "BST327301000100001",
        "nik": "3273010101900001",
        "nama": "BUDI SANTOSO",
        "alamat": "JL. DAGO NO. 12 RT 01 RW 02",
        "alamat_ktp": "JL. DAGO NO. 12 RT 01 RW 02",
        "nominal": 600000,
        "batch": "01",
        "bst": "BST2026",
        "danom": "DN-3273-0001",
        "regional": "REGIONAL 2",
        "kprk": "40000",
        "nama_kprk": "BANDUNG",
        "kantor": "40135",
        "nama_kantor": "DAGO CABANG",
        "provinsi": "JAWA BARAT",
        "kabupaten": "KOTA BANDUNG",
        "kecamatan": "COBLONG",
        "kelurahan": "DAGO",
        "percentile": "DESIL 1",
        "kode_header_danom": "0",
        "kode_surat_pernyataan": "1"
      }
    ]
  }
}
```

---

### 2.10. POST `/danom/status-cetak`
Mencatat audit trail dan memperbarui status siklus pencetakan dokumen Danom atau Bukti Terima ke server pusat (menggantikan mekanisme pemindahan folder `data/` &rarr; `sudah_cetak/`).

* **URL**: `/api/v1/danom/status-cetak`
* **HTTP Method**: `POST`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Stored Procedure**: `SIKAP_UPDATE_STATUS_CETAK` *(atau audit table log)*
* **Business Rule yang Terpengaruh**:
  * [BR-05] Proteksi cetak ganda (*double-print protection*).

#### Request DTO (`DanomStatusCetakRequestDTO`)
```json
{
  "kode_kelurahan": "3273010001",
  "jenis_dokumen": "DANOM",
  "total_records_dicetak": 150,
  "nama_file_bnba": "BNBA_KOTA BANDUNG_DAGO_COBLONG_40100_150.csv",
  "waktu_cetak": "2026-11-12T09:40:00+07:00"
}
```

#### Response DTO Sukses 200
```json
{
  "success": true,
  "code": 200,
  "message": "Status cetak berhasil diperbarui",
  "data": {
    "status": "RECORDED",
    "kode_kelurahan": "3273010001",
    "updated_at": "2026-11-12T09:40:01+07:00"
  }
}
```

---

### 2.11. POST `/cds/cek-nik`
Melakukan verifikasi data KPM susulan (CDS BLT / BSU) secara *real-time* dengan mem-proxy request ke WSO2 API Gateway Kemensos/Ketenagakerjaan (menggantikan `Button3Click` pada `Utama.pas:2384-2450`).

* **URL**: `/api/v1/cds/cek-nik`
* **HTTP Method**: `POST`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Service Eksternal Target**: `http://10.33.41.252:8280/cds_blt/getData`
  * Request Body WSO2: `{"NIK": "<nik>"}`
* **Business Rule yang Terpengaruh**:
  * [BR-08] Verifikasi real-time CDS BLT & kalkulasi BSU: `BSU = KUANTITAS * NOMINAL`.
  * [GAP-05] Penanganan aman terhadap respons kosong / non-numerik untuk mencegah crash `EConvertError`.

#### Request DTO (`CdsCekNikRequestDTO`)
```json
{
  "nik": "3273011205850003"
}
```

#### Response DTO Sukses 200 (`CdsBeneficiaryResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Data KPM susulan ditemukan",
  "data": {
    "nik": "3273011205850003",
    "id_pelanggan": "BLT3273019999",
    "nama": "SITI AMINAH",
    "alamat": "JL. KEBON BIBIT NO. 45",
    "kuantitas": 1,
    "nominal": 600000,
    "bsu": 600000,
    "nama_perusahaan": "DAGO",
    "alamat_perusahaan": "JL. DAGO ELOS",
    "header_danom": "KEMENTERIAN TENAGA KERJA RI",
    "provinsi": "JAWA BARAT",
    "kabupaten": "KOTA BANDUNG",
    "kecamatan": "COBLONG",
    "kelurahan": "DAGO"
  }
}
```

#### Error Responses
* `404 Not Found` (`ERR_NIK_NOT_FOUND`): Jika NIK tidak terdaftar di DTKS / respons WSO2 kosong.
* `502 Bad Gateway` (`ERR_GATEWAY_TIMEOUT`): Jika WSO2 ESB tidak merespons dalam 5 detik.

---

### 2.12. GET `/param/surat`
Mengambil template redaksional teks Surat Pernyataan Tanggung Jawab KPM Sembako (menggantikan file flat `param_b[idproject]_[subfix].pos` pada `Utama.pas:1618-1647`).

* **URL**: `/api/v1/param/surat`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Bearer Token (JWT)**
* **Business Rule yang Terpengaruh**:
  * [BR-07] Syarat kepatuhan 4 komoditas pangan program sembako.

#### Request Query Parameters (`ParamSuratQueryDTO`)
* `id_project` (String, wajib): 2 karakter pertama kode project (contoh: `PU`, `PD`).
* `subfix` (String, wajib): Subfix karakter ke-3 (contoh: `1`, `A`).

#### Response DTO Sukses 200 (`ParamSuratResponseDTO`)
```json
{
  "success": true,
  "code": 200,
  "message": "Template surat pernyataan berhasil diambil",
  "data": {
    "judul_surat": "SURAT PERNYATAAN TANGGUNG JAWAB MUTLAK PENERIMA BANTUAN PROGRAM SEMBAKO",
    "klausul_pembuka": "Menyatakan dengan sesungguhnya bahwa:",
    "butir_komitmen": [
      "Saya akan menggunakan uang bantuan Program Sembako untuk dibelanjakan sesuai dengan bahan pangan yang telah ditentukan oleh Kementerian Sosial yaitu: Karbohidrat, Protein Hewani, Protein Nabati, dan/atau Vitamin dan Mineral.",
      "Apabila saya tidak membelanjakan sesuai dengan bahan pangan yang telah ditentukan maka saya bersedia untuk tidak menerima kembali bantuan Program Sembako berikutnya dan bersedia dikeluarkan dari data penerima bantuan Program Sembako."
    ],
    "klausul_penutup": "Demikian pernyataan ini kami buat dengan sebenar-benarnya tanpa adanya paksaan dari pihak manapun."
  }
}
```

---

### 2.13. GET `/health`
Pemeriksaan kesehatan sistem (*health check*) untuk Caddy reverse proxy dan pemantauan konektivitas ke database SQL Server pusat.

* **URL**: `/api/v1/health`
* **HTTP Method**: `GET`
* **Authentication Requirement**: **Public (None)**

#### Response DTO Sukses 200
```json
{
  "status": "UP",
  "timestamp": "2026-11-12T09:35:00+07:00",
  "database": {
    "status": "CONNECTED",
    "rdbms": "Microsoft SQL Server",
    "latency_ms": 12
  },
  "memory": {
    "allocated_mb": 24.5,
    "system_mb": 38.2
  }
}
```

