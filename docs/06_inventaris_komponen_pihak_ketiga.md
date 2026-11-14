# 06. Inventaris Seluruh Komponen Pihak Ketiga (*Third-Party Components*)

## 1. Tabel Ringkasan Komponen Pihak Ketiga

Aplikasi ini sangat bergantung pada pustaka (*libraries*) dan komponen VCL eksternal yang diinstal pada IDE Delphi 5 dan Delphi 7:

| Komponen / Pustaka | Vendor / Author | Lisensi | Kategori | Tingkat Ketergantungan |
| :--- | :--- | :--- | :--- | :---: |
| **FastReport 4.0 / 6.6.12** | Fast Reports Inc. | Komersial | Reporting & Barcode | **Kritis (Tinggi)** |
| **kbmMemTable v5.00** | Components4Developers (Kim Madsen) | Komersial | In-Memory Dataset | **Kritis (Tinggi)** |
| **DCPcrypt v2.0** | David Barton | Open Source / BSD | Kriptografi | **Kritis (Tinggi)** |
| **ZLibEx v1.1.4** | Roberto Della Pasqua / zlib | zlib License | Kompresi Data | **Kritis (Tinggi)** |
| **Indy (Internet Direct)** | Indy Pit Crew / Chad Z. Hower | BSD / Dual | Jaringan (HTTP/TCP) | **Tinggi** |
| **RAWPrinter v1.5** | Bisma Jayadi / P. Jankowski | Freeware | Direct Spooler Printing| **Tinggi** |
| **uLkJSON** | Leonid Koninin | LGPL | JSON Parser | **Sedang** |
| **DevExpress ExpressQuantum**| Developer Express Inc. | Komersial | UI Controls (dxButtons) | **Sedang** |
| **NextSuite (NxCollection)** | Berg Software | Komersial | UI Controls (TNxLabel) | **Sedang** |
| **JVCL (JEDI Visual Component)**| Project JEDI | MPL | Visual / GIF Animator | **Sedang** |
| **BvComponents (bvDBGrid)** | BV Software / Tim Pos | Proprietary/Custom| Advanced DBGrid | **Tinggi** |
| **QuickReport & Han-soft 2D** | QBS Software & Han-soft | Komersial | Legacy Reporting & QR | **Rendah (Legacy)** |
| **FastMM4 & FastShareMem** | Pierre le Riche | MPL / LGPL | Memory Management | **Rendah (Teknis)** |
| **SQLMemTable** | AidAim Software | Komersial | In-Memory SQL DB | **Rendah (Arsip)** |
| **SynEdit & JvUIB** | SynEdit Team / UIB Team | MPL / LGPL | SQL Editor & Firebird | **Rendah (Arsip)** |
| **GPanel & AHM Components** | Public Delphi Contributors | Freeware | Visual Panels & Labels | **Rendah** |

---

## 2. Analisis Rinci Tiap Komponen

### 1. FastReport (Versi 4.0 & Versi 6.6.12)
- **Unit Terkait**: `frxClass`, `frxDBSet`, `frxBarcode`, `frxExportPDF`, `frxExportBaseDialog`, `frxpngimage`, `fs_iinterpreter`.
- **Peran**: Mesin utama pencetakan Daftar Nominatif (Danom), Bukti Penerimaan Bantuan (Bukti Bayar), dan Surat Pernyataan Tanggung Jawab.
- **Fitur Kritis**:
  - Render Barcode 2D (QR Code) langsung pada dokumen kuitansi.
  - Scripting engine internal (PascalScript) untuk manipulasi visibilitas objek laporan saat *runtime*.
  - Ekspor dokumen langsung ke format PDF melalui `TfrxPDFExport`.
  - Integrasi fungsi kustom `ToMD5` melalui RTTI module `UFunction.pas`.
- **Dampak Modernisasi**: Format `.fr3` adalah XML terstruktur tetapi memiliki dependensi kuat terhadap tipe objek visual FastReport VCL. Migrasi ke stack non-Delphi memerlukan konversi template ke mesin pelaporan alternatif (QuestPDF, FastReport .NET, atau CSS HTML Print).

---

### 2. kbmMemTable (Versi 5.00)
- **Unit Terkait**: `kbmMemTable.pas`, `kbmMemBinaryStreamFormat.pas`, `kbmCompress.pas`.
- **Peran**: Media penyimpanan data tabular dalam memori RAM berkecepatan tinggi.
- **Fitur Kritis**:
  - Menjadi fondasi representasi data pada middleware `NCONN` (`TMem = Tkbmmemtable`).
  - Serialisasi aliran data biner melalui `TkbmBinaryStreamFormat` (`LoadFromStream` dan `SaveToStream`).
- **Dampak Modernisasi**: Format serialisasi biner kbmMemTable adalah proprietary. Data yang tersimpan dalam format stream lama tidak dapat dibaca secara langsung oleh bahasa lain (.NET / Rust) tanpa parser biner khusus atau konversi ke format terbuka (JSON/SQLite/Parquet).

---

### 3. DCPcrypt Cryptographic Component Library (Versi 2.0)
- **Unit Terkait**: `DCPcrypt2`, `DCPblockciphers`, `DCPblowfish`, `DCPtwofish`, `DCPdes`, `DCPrc4`, `DCPsha1`, `Md5`.
- **Peran**: Mengamankan file konfigurasi profil server (`conf.bns`) dan data transaksi lokal.
- **Fitur Kritis**:
  - Enkripsi simetris menggunakan algoritma **Blowfish** (`TDCP_blowfish`) dengan mode block cipher standar.
  - Fungsi hashing MD5 untuk validasi kata sandi petugas dan verifikasi integritas data kuitansi.
- **Dampak Modernisasi**: Implementasi Blowfish pada DCPcrypt menggunakan padding dan *initialization vector* (IV) spesifik yang harus ditiru secara persis di C# (`BouncyCastle` / `System.Security.Cryptography`) atau Rust (`blowfish` crate) jika ingin tetap membaca file `.bns` dan `.POS` terenkripsi yang ada.

---

### 4. ZLibEx (Versi 1.1.4)
- **Unit Terkait**: `ZLibEx.pas`, `adler32.obj`, `compress.obj`, `crc32.obj`, `deflate.obj`, `trees.obj`.
- **Peran**: Melakukan kompresi dan dekompresi data biner transaksi sebelum dikirim via soket jaringan atau ditulis ke disk.
- **Karakteristik Teknis**: Bergantung pada berkas objek biner C 32-bit (`.obj`).
- **Dampak Modernisasi**: Berkas `.obj` 32-bit OMF format tidak dapat di-link ke Delphi 64-bit modern. Pada C# dan Rust, fungsionalitas ini dapat digantikan langsung oleh pustaka standar `System.IO.Compression.DeflateStream` atau crate `flate2`.

---

### 5. RAWPrinter (Versi 1.5)
- **Unit Terkait**: `RAWPrinter.pas`.
- **Peran**: Mencetak teks dan instruksi kontrol printer secara mentah (*raw byte stream*) langsung ke subsystem Windows Print Spooler (`winspool.drv`).
- **Hardware Target**: Printer dot-matrix slip (Epson LQ-300) dan Passbook printer loket pos (IBM 9068A).
- **Fitur Kritis**: Mengabaikan driver GDI Windows untuk mencetak teks tanpa jeda rendering grafis dan mendukung perintah kontrol kertas/form feed.
- **Dampak Modernisasi**: Pada C# memerlukan pemanggilan Win32 P/Invoke (`OpenPrinter`, `StartDocPrinter`, `WritePrinter`). Pada Tauri/Rust memerlukan native bindings ke API WinSpool Windows.

---

### 6. Pustaka Kontrol Visual (DevExpress, NextSuite, JVCL, BvComponents, GPanel)
- **`TdxButton`**: Tombol dengan styling antarmuka modern khas DevExpress.
- **`TNxLabel`, `TNxButton`**: Komponen teks dan tombol dari Berg Software NextSuite.
- **`TJvGIFAnimator`**: Komponen JVCL untuk memutar animasi file GIF saat proses pengunduhan berlangsung.
- **`TbvDBGrid`**: Komponen grid basis data lanjutan yang dilengkapi fitur pencarian data, penyembunyian kolom, dan penyimpanan preferensi kolom ke file eksternal.
- **`TGPanel`**: Kontrol panel dengan latar belakang gradien warna.
- **Dampak Modernisasi**: Seluruh kontrol visual ini terikat erat pada arsitektur Win32 GDI/VCL dan akan digantikan secara penuh oleh teknologi UI modern (WPF XAML pada .NET atau HTML5/CSS3 pada Tauri).

