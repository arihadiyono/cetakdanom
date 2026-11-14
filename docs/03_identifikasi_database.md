# 03. Identifikasi Database & Model Data

## 1. Engine Database Utama

Berdasarkan analisis file sumber (*source code*), konfigurasi koneksi pada file DFM, serta sintaks pemanggilan kueri, sistem backend basis data yang digunakan adalah:

| Atribut Database | Nilai / Temuan |
| :--- | :--- |
| **Engine RDBMS** | **Microsoft SQL Server** (Didukung bukti OLE DB Provider `SQLOLEDB.1` dan sintaks T-SQL `exec`) |
| **Koneksi OLE DB Driver** | `Provider=SQLOLEDB.1;Data Source=10.33.41.26;Initial Catalog=fd_db_dev_bsm;User ID=sa;` |
| **Katalog / Nama Database** | `fd_db_dev_bsm` (Fund Distribution Database BSM/Bansos) |
| **Database Eksternal SIKAP** | Sistem Informasi & Komunikasi Antar Pos (SIKAP) terpusat |
| **Dukungan RDBMS Lain** | Layer middleware `NCONN` secara modular mendukung *Firebird* (`fbmoddb.dll`), *MySQL* (`mysqlmoddb.dll`), dan *Sybase/MSSQL* (`mssqlmoddb.dll`), serta pustaka *UIB* (Unified InterBase) pada direktori `lib/`. Namun, pada aplikasi operasional aktif, RDBMS target adalah SQL Server. |

---

## 2. Inventaris Stored Procedure

Semua interaksi pengambilan data dari klien ke database SQL Server dilakukan melalui **Stored Procedure** terkompilasi (tidak ditemukan kueri SQL `SELECT ... FROM` langsung di sisi klien untuk tabel transaksi):

### A. Autentikasi & Otorisasi Petugas
| Stored Procedure | Parameter Masukan | Return Value / Deskripsi |
| :--- | :--- | :--- |
| `SIKAP_LOGIN` | `:ID_PETUGAS` (varchar)<br/>`:PASS_PETUGAS` (MD5 hash)<br/>`:APPVERSI` (varchar) | Recordset status login. Jika kolom 0 = `'000'`, kolom 1 memuat data profil petugas dipisahkan tanda pipa (`\|`): `IdPetugas\|Nippos\|Nama\|Nopend\|Kantor\|Jabatan`. |
| `LOGIN_BANSOS` | `:ID_PETUGAS`<br/>`:HASH_PASS`<br/>`:APPVERSI` | Versi legacy autentikasi pada `ToolCetakDanom`. Mengembalikan status izin akses aplikasi dan profil kantor pos cabang. |

### B. Hierarki Administratif Wilayah
| Stored Procedure | Parameter Masukan | Output / Kegunaan |
| :--- | :--- | :--- |
| `SIKAP_GET_LAYANAN` | *(Tanpa parameter)* | Mengambil daftar jenis bantuan sosial yang aktif (Kode Layanan & Nama Layanan). |
| `SIKAP_GET_TAHAP` | *(Tanpa parameter)* | Mengambil daftar tahap penyaluran bansos aktif (Tahap 1, 2, 3, dst.). |
| `SIKAP_GET_TAHAP_KOTAKAB` | `:KODE_PROJECT` | Tahap bansos spesifik wilayah kota/kabupaten. |
| `SIKAP_GET_TAHAP_INS` | `:KODE_PROJECT` | Tahap bansos program instansi tertentu. |
| `SIKAP_GET_TAHAP_NAS` | `:KODE_PROJECT` | Tahap bansos program skala nasional. |
| `SIKAP_GET_KABUPATEN` | `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS` | Mengambil daftar kabupaten yang menjadi wilayah kerja Kantor Pos pemeriksa (`NOPEND`). |
| `SIKAP_GET_KECAMATAN` | `:ID_KABUPATEN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS` | Mengambil daftar kecamatan di bawah kabupaten terpilih. |
| `SIKAP_GET_KELURAHAN_BYKAB`| `:ID_KABUPATEN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS` | Mengambil seluruh kelurahan/desa langsung dalam 1 kabupaten. |
| `SIKAP_GET_KELURAHAN_BYKEC`| `:ID_KECAMATAN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS` | Mengambil seluruh kelurahan/desa di bawah 1 kecamatan terpilih. |

### C. Ekstraksi Data Transaksi Bantuan Sosial
| Stored Procedure | Parameter Masukan | Output / Kegunaan |
| :--- | :--- | :--- |
| `SIKAP_GET_DATA_BANSOSRS` | `:ID_KELURAHAN`, `:KODE_JENIS`, `:FLAG` | Ekstraksi 24 kolom data penerima bansos dalam 1 kelurahan untuk disimpan ke file `.POS`. |
| `SIKAP_GET_DAFTARNOMINATIF_KOTAKAB_V4` | `:ID_KEL`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS`, `:TAHAP`, `:SORT`, `:PROJECT` | Ekstraksi Danom V4 per kota/kabupaten (format kbmMemTable binary stream). |
| `SIKAP_GET_DAFTARNOMINATIF_INSTANSI_V4`| `:ID_KEL`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS`, `:TAHAP`, `:SORT`, `:PROJECT` | Ekstraksi Danom V4 khusus program kemitraan instansi. |
| `SIKAP_GET_DAFTARNOMINATIF_NAS_V4` | `:ID_KEL`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS`, `:TAHAP`, `:SORT`, `:PROJECT` | Ekstraksi Danom V4 skala nasional (Kemensos BST Nasional). |
| `SIKAP_GET_DAFTARNOMINATIF_KOTAKAB` | `:ID_KEL`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `:JENIS`, `:TAHAP`, `:SORT`, `:PROJECT` | Ekstraksi Danom legacy. |

---

## 3. Skema Data Lokal & In-Memory Table

Aplikasi memanfaatkan database in-memory (`TkbmMemTable`) untuk menyimpan struktur data saat eksekusi:

### A. Skema Tabel Danom (`CreateDanomTable` pada `Utama.pas:350-407`)
Tabel in-memory ini digunakan saat memuat data dari file `.POS` untuk disajikan ke grid dan engine FastReport:

```pascal
Add('ID_PELANGGAN', ftString, 20, true);   // Nomor Rekening / No Danom KPM
Add('PELANGGAN',    ftString, 50, true);   // Nama Lengkap Penerima
Add('ALAMAT',       ftString, 100, true);  // Alamat Tempat Tinggal KPM
Add('AMOUNT',       ftInteger, 0, true);   // Nominal Bantuan (Rp)
Add('ID_KELURAHAN', ftString, 7, true);    // Kode Wilayah Kelurahan/Desa
Add('KELURAHAN',    ftString, 100, true);  // Nama Kelurahan/Desa
Add('ID_KECAMATAN', ftString, 7, true);    // Kode Wilayah Kecamatan
Add('KECAMATAN',    ftString, 100, true);  // Nama Kecamatan
Add('ID_KABUPATEN', ftString, 7, true);    // Kode Wilayah Kota/Kabupaten
Add('KABUPATEN',    ftString, 100, true);  // Nama Kota/Kabupaten
Add('ID_PROPINSI',  ftString, 7, true);    // Kode Wilayah Provinsi
Add('PROPINSI',     ftString, 100, true);  // Nama Provinsi
Add('ID_KANTOR',    ftString, 7, true);    // Kode Kantor Pos Cabang Pemeriksa
Add('KANTOR',       ftString, 100, true);  // Nama Kantor Pos
Add('ID_KPRK',      ftString, 7, true);    // Kode Kantor Pos Pengendali (Kprk)
Add('KPRK',         ftString, 100, true);  // Nama Kprk
Add('ID_STATUS',    ftString, 3, true);    // Status Pembayaran (0=Belum, 1=Sudah)
Add('OPT',          ftString, 200, true);  // Data Tambahan / Catatan Petugas
Add('PERCENTILE',   ftString, 200, true);  // Kelompok Desil Kesejahteraan Sosial
Add('FOOTER',       ftString, 1000, true); // Teks Kaki Laporan / Legalitas
// Index Unik: ID_PELANGGAN
```

### B. Skema Ekspor File CSV *By Name By Address* (`BNBA_*.csv`)
File CSV ini diekspor ke `data/BNBA/` dengan pemisah titik koma (`;`) sebelum proses cetak dijalankan:

| Indeks Kolom | Nama Kolom Header | Sumber Field Dataset | Keterangan Format |
| :---: | :--- | :--- | :--- |
| 1 | `BST` | `Fields[0]` | Kode Identitas BST / Nomor Batch |
| 2 | `REGIONAL` | `Fields[20]` | Nomor Regional Pos (1 s.d. 6) |
| 3 | `KANTOR` | `Fields[17] + '-' + Fields[16]` | Kode Nopend dan Nama Kantor Pos |
| 4 | `PROVINSI` | `Fields[14]` | Nama Provinsi penerima |
| 5 | `KABUPATEN` | `Fields[12]` | Nama Kabupaten/Kota penerima |
| 6 | `KECAMATAN` | `Fields[10]` | Nama Kecamatan penerima |
| 7 | `DESA/KELURAHAN`| `Fields[8]` | Nama Kelurahan/Desa penerima |
| 8 | `BATCH` | `Fields[19]` | Nomor Batch penyaluran |
| 9 | `NAMA` | `Fields[1]` | Nama Lengkap Penerima Manfaat |
| 10 | `NOMINAL` | `Fields[6]` | Jumlah Uang Bantuan (Rp) |
| 11 | `NIK` | `"`" + `Fields[21]` | Nomor Induk Kependudukan (diberi tanda backtick agar teks tidak terpotong di Excel) |
| 12 | `ALAMAT` | `Fields[2]` | Alamat domisili penerima |
| 13 | `DANOM` | `"`" + `Fields[7]` | Nomor Registrasi Danom |
| 14 | `PERCENTILE` | `Fields[32]` | Peringkat Desil / Kemiskinan KPM |

### C. Skema Konfigurasi Koneksi Server (`conf.bns` pada `Nmemtable.pas`)
File `conf.bns` disimpan secara lokal terenkripsi di direktori aplikasi:

```pascal
Add('id',        ftString,  20, true);  // Alias koneksi (contoh: 'SKS', 'FDPOS')
Add('connType',  ftString,  10, true);  // Jenis koneksi ('SOCK', 'MSSQL', 'FB')
Add('server',    ftString,  30, true);  // Host IP / FQDN server
Add('database',  ftString,  50, true);  // Nama database
Add('user',      ftString,  32, true);  // Kredensial User DB / Middleware
Add('password',  ftString,  32, true);  // Kredensial Password
Add('ziptype',   ftInteger,  0, true);  // Tipe kompresi (3 = ZLib zcMax)
Add('crypttype', ftInteger,  0, true);  // Tipe enkripsi (1 = Blowfish)
Add('timeout',   ftInteger,  0, true);  // Connection Timeout (ms, default: 20000)
// Index Unik: id
```

