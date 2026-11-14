# 13. Matriks Traceability & Analisis Kesenjangan (Gap Analysis)

Dokumen ini memetakan relasi fungsional dari **Form Delphi Eksisting &rarr; Use Case &rarr; Endpoint Go API &rarr; Stored Procedure SQL Server**, serta membedah seluruh celah teknis (*gaps*) yang berpotensi menyebabkan perbedaan perilaku antara sistem warisan (*legacy*) dan sistem modern baru.

---

## 1. Matriks Traceability: Delphi &rarr; Use Case &rarr; Go API &rarr; Stored Procedure

| Form Delphi Eksisting | Use Case / Fungsi Bisnis | Endpoint Go API Modern | Stored Procedure SQL Server / Service Eksternal | Parameter & Kontrak Input/Output |
| :--- | :--- | :--- | :--- | :--- |
| **`ULogin`** | Autentikasi Petugas Loket | `POST /api/v1/auth/login` | `SIKAP_LOGIN`<br/>*(Fallback: `LOGIN_BANSOS`)* | **In**: `:ID_PETUGAS`, `:PASS_PETUGAS` (MD5), `:APPVERSI`<br/>**Out**: Kode Status (`000`), String pipa profil petugas. |
| **`ULogin`** | Mode Offline Lapangan | *(Lokal C# / SQLite)* | *(Tidak ada)* | Mengaktifkan `IsOfflineMode = true` saat tombol **F5** ditekan. |
| **`ULogin` / `uUpdate`**| Pengecekan Versi & Update | `GET /api/v1/app/version` | Diperiksa di dalam `SIKAP_LOGIN` | **In**: Versi Klien<br/>**Out**: Status validasi & URL download binary. |
| **`ServerConf`** | Manajemen Profil Koneksi | *(Config lokal C# / `appsettings.json`)* | *(Tidak ada)* | Menggantikan file biner terenkripsi `conf.bns`. |
| **`Utama`** | Mengambil Jenis Layanan Bansos | `GET /api/v1/wilayah/layanan` | `SIKAP_GET_LAYANAN` | **Out**: `KODE_LAYANAN`, `NAMA_LAYANAN`. |
| **`Utama`** | Mengambil Tahap Penyaluran | `GET /api/v1/wilayah/tahap` | `SIKAP_GET_TAHAP`<br/>*(atau `SIKAP_GET_TAHAP_KOTAKAB`)* | **In**: `:KODE_PROJECT` (opsional)<br/>**Out**: Daftar tahap aktif (misal: Tahap 1 s.d. 3). |
| **`Utama`** | Mengambil Wilayah Kabupaten | `GET /api/v1/wilayah/kabupaten` | `SIKAP_GET_KABUPATEN` | **In**: `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `'0'`<br/>**Out**: Daftar Kabupaten/Kota kerja cabang. |
| **`Utama`** | Mengambil Wilayah Kecamatan | `GET /api/v1/wilayah/kecamatan` | `SIKAP_GET_KECAMATAN` | **In**: `:ID_KABUPATEN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `'0'`<br/>**Out**: Daftar Kecamatan. |
| **`Utama`** | Mengambil Kelurahan (per Kec) | `GET /api/v1/wilayah/kelurahan` | `SIKAP_GET_KELURAHAN_BYKEC` | **In**: `:ID_KECAMATAN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `'0'`<br/>**Out**: Daftar Kelurahan/Desa. |
| **`Utama`** | Mengambil Kelurahan (per Kab) | `GET /api/v1/wilayah/kelurahan-by-kab`| `SIKAP_GET_KELURAHAN_BYKAB` | **In**: `:ID_KABUPATEN`, `:NOPEND`, `:ID_PETUGAS`, `:NIPPOS`, `'0'`<br/>**Out**: Seluruh kelurahan dalam 1 kabupaten. |
| **`Utama`** | Ekstraksi Batch Data Danom | `GET /api/v1/danom/batch` | `SIKAP_GET_DATA_BANSOSRS`<br/>*(Alt: `SIKAP_GET_DAFTARNOMINATIF_KOTAKAB_V4`)* | **In**: `:ID_KELURAHAN`, `:KODE_JENIS`, `'0'`<br/>**Out**: Recordset 24 kolom penerima bansos. |
| **`Utama`** | Simpan Cache Data Lokal | *(Client C# Bulk Insert)* | *(Tidak ada)* | Menggantikan penyimpanan file flat `*.POS`. |
| **`Utama`** | Memuat Grid Data Danom | *(Client C# Kueri SQLite)* | *(Tidak ada)* | Menggantikan pembacaan `LoadFromDanomFile`. |
| **`Utama`** | Ekspor Berkas BNBA | *(Client C# `CsvHelper`)* | *(Tidak ada)* | Menggantikan prosedur `btn_BNBAClick`. |
| **`Utama`** | Pratinjau & Cetak Danom | *(Client C# QuestPDF)* | *(Tidak ada)* | Menggantikan template FastReport `frDanom.fr3`. |
| **`Utama`** | Cetak Bukti Terima (Kuitansi QR)| *(Client C# QuestPDF + QRCoder)*| *(Tidak ada)* | Menggantikan FastReport `frBuktiTerima.fr3`. |
| **`Utama`** | Cetak Surat Pernyataan Sembako | *(Client C# QuestPDF)* | *(Tidak ada)* | Menggantikan FastReport `Pernyataan.fr3`. |
| **`Utama`** | Pengecekan NIK Online CDS BLT | `POST /api/v1/cds/cek-nik` | WSO2 Gateway `/cds_blt/getData` *(Port 8280)* | **In**: `{"NIK": "..."}`<br/>**Out**: JSON payload DTKS Kemensos. |
| **`Utama`** | Cetak Slip CDS (Passbook Loket)| *(Client C# `RawPrinterHelper`)* | *(Tidak ada)* | Menggantikan komponen `RAWPrinter.pas` (ESC/P). |

---

## 2. Analisis Kesenjangan (*Gap Analysis*) Berdasarkan Domain Prioritas

---

### GAP 1: Domain Login & Autentikasi

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Algoritma Hashing Kata Sandi** | Menghitung hash MD5 dari konkatenasi mentah: `MD5(txt_UserId.Text + txt_Passwd.Text)`. Tidak melakukan `trim()` atau konversi huruf kecil/besar. | Klien baru mungkin secara otomatis melakukan `.Trim()` atau `.ToLower()`, yang menyebabkan kegagalan login bagi user dengan password tertentu. | Sensitivitas huruf dan karakter spasi pada input string Delphi AnsiString. | **Wajib di Go API**: Lakukan hashing karakter mentah persis: `md5.Sum([]byte(req.UserID + req.Password))`. Jangan ubah case input. |
| **Autentikasi Mode Offline (F5)** | Tombol F5 langsung membuka dashboard aplikasi tanpa meminta password lokal sama sekali (`isLokal := true`). Siapa pun dapat mencetak data lokal. | Klien baru C# mungkin mengharuskan login offline menggunakan kredensial ter-cache. | Tidak adanya mekanisme autentikasi lokal pada kode Delphi lama. | **Rekomendasi Modern**: Sediakan tombol/opsi "Mode Darurat Offline (F5)". Untuk keamanan audit, validasi password terhadap hash login terakhir yang disimpan di SQLite lokal. |
| **Pemeriksaan Versi Aplikasi** | SP `SIKAP_LOGIN` menolak login jika parameter `APPVERSI` tidak cocok, lalu Delphi memicu `update.exe` via `ShellExecute`. | Jika Go API mengirim konstanta hardcoded versi yang salah ke SP, semua user loket akan langsung terkunci tidak bisa login. | Kontrak ketat verifikasi versi pada tabel basis data SQL Server pusat. | Go API harus meneruskan versi yang dikirim oleh C# Client ke SP MSSQL, bukan menimpa dengan versi API. |
| **Pengawasan Proses Kembar (*Process Watchdog*)** | `cetak.exe` memeriksa apakah proses `cetakDanom.exe` sedang berjalan via `CreateToolhelp32Snapshot`. Jika tidak ada, langsung `Application.Terminate`. | Jika klien baru C# meniru pengecekan ini, aplikasi tidak akan pernah bisa dibuka karena `cetakDanom.exe` sudah dipensiunkan. | Mekanisme proteksi dependensi warisan (*companion tool*). | **Hapus sepenuhnya** pengecekan `processExists('cetakDanom.exe')` pada aplikasi C# baru. |

---

### GAP 2: Domain Hak Akses & Otorisasi (*Authorization Scope*)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Pembatasan Data Kantor Pos (Nopend)** | Respon login mengembalikan string pipa: `IdPetugas\|Nippos\|Nama\|Nopend\|Kantor\|Jabatan`. Nilai `Nopend` otomatis diisikan ke `edtNopend.Text`. | Jika klien baru mengizinkan petugas mengubah nilai Nopend, atau Go API tidak memvalidasi Nopend, petugas bisa menarik data bansos kantor pos lain. | Pada Delphi lama, `edtNopend` berada di form utama dan nilainya diteruskan ke SP hierarki wilayah. | **Kunci di Go API**: Simpan `Nopend`, `IdPetugas`, dan `Nippos` ke dalam klaim JWT Token. Ambil nilai ini dari JWT saat memanggil SP, jangan percaya parameter dari form klien. |
| **Perbedaan Parameter Antar-Versi** | Pada Delphi 5, SP Wilayah menerima `ItemIndex` ComboBox Layanan. Pada Delphi 7 (`ToolCetakDanom_QR`), parameter ke-4 di-hardcode menjadi `'0'`. | Hasil query wilayah (Kabupaten/Kecamatan) bisa berbeda tergantung apakah parameter dikirim `'0'` atau kode layanan riil. | Inkonsistensi modifikasi kode pada `ToolCetakDanom_QR/Utama.pas:1256`. | Go API harus mengikuti kontrak Delphi 7 yang sedang aktif: kirim parameter Nopend, IdPetugas, Nippos, dan `'0'`. |

---

### GAP 3: Domain Danom (Daftar Nominatif)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Inkonsistensi Ekstraksi vs Pemuatan Berkas** | Di `ToolCetakDanom_QR`, fungsi `GetData` menulis **teks CSV 24 kolom** ke file `.POS`, tetapi `LoadFromDanomFile` mencoba **mendekripsi biner kbmMemTable**. | Developer baru yang mencoba mem-parsing berkas `.POS` lama akan mengalami error `ZLib Decompress Failed` atau corrupt stream. | Bug tersembunyi / proses transisi setengah jalan pada kode Delphi eksisting. | **Ganti Total dengan SQLite**: Tinggalkan file flat `*.POS`. Go API mengembalikan JSON bersih dari SP `SIKAP_GET_DATA_BANSOSRS`, lalu C# menyimpannya ke tabel SQLite lokal. |
| **Kesenjangan Jumlah Kolom (24 vs 33 Kolom)** | `GetData` mengekstrak `Fields[0]` s.d. `Fields[23]`, tetapi `btn_BNBAClick` memanggil `Fields[32]` (`PERCENTILE`). | Panggilan kueri yang salah dapat menyebabkan nilai `PERCENTILE` kosong atau error *Index Out of Bounds*. | SP `SIKAP_GET_DATA_BANSOSRS` memiliki kolom lebih sedikit dibanding SP legacy `SIKAP_GET_DAFTARNOMINATIF_*_V4`. | Petakan seluruh nama kolom (*by name*) alih-alih mengandalkan indeks angka array (*by index*). |
| **Penamaan File sebagai Metadata** | Aplikasi lama mengekstrak parameter laporan dari nama file: `RightStr(SelectedFile, 5)` untuk `idheaderdanom` dan karakter ke-6 untuk `idsp`. | Jika di aplikasi baru nama file atau identitas ID ini hilang, sistem tidak tahu template kuitansi atau kop surat mana yang harus dicetak. | Metadata operasional dikodekan ke dalam *string filename* alih-alih disimpan di database. | Di database lokal SQLite, simpan field eksplisit: `kode_header_danom` dan `kode_surat_pernyataan` bersama data KPM. |

---

### GAP 4: Domain BNBA (*By Name By Address*)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Proteksi Angka NIK di Microsoft Excel** | Field `NIK` dan `DANOM` sengaja diprefiks karakter backtick (`` ` ``) sebelum ditulis ke CSV: `` '`' + Fields[21].AsString ``. | Jika di C# diekspor sebagai CSV standar tanpa backtick, nomor NIK 16 digit akan otomatis diubah Excel menjadi format ilmiah (contoh: `3.20102E+15`) dan 3 digit terakhir menjadi nol. | Perilaku otomatis aplikasi spreadsheet (Excel) yang mengonversi string numerik panjang menjadi bilangan floating point. | **Wajib Dipertahankan**: Pada generator CSV C# (`CsvHelper`), tambahkan karakter backtick (`` ` ``) di depan nomor NIK dan nomor Danom. |
| **Pembersihan Spasi Kolom Provinsi** | Delphi menjalankan string replace khusus: `StringReplace(Fields[14].AsString, '   ', '', [rfReplaceAll])`. | Teks provinsi bisa tampak berantakan atau tidak sejajar jika spasi ganda bawaan database tidak dipangkas. | Data spasi berlebih (*trailing/inline spaces*) dari tipe data `CHAR(N)` pada SQL Server. | Lakukan normalisasi string `.Trim()` dan pembersihan regex spasi berulang pada C# / Go. |
| **Triggers Otomatis Sebelum Cetak** | Prosedur cetak Danom (`btnCetakClick`) secara otomatis memanggil `btn_BNBA.Click()`. Pengguna tidak bisa mencetak jika ekspor BNBA gagal. | Jika di aplikasi baru proses cetak dipisahkan dari pembuatan BNBA, petugas lapangan bisa lupa membuat berkas BNBA untuk arsip kelurahan. | Keterikatan alur kerja (*coupled business workflow*). | Pertahankan aturan ini: tombol "Cetak Danom" di C# harus memvalidasi/mengenerate file CSV BNBA ke folder arsip terlebih dahulu. |

---

### GAP 5: Domain CDS BLT (Cetak Danom Susulan)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Crash Saat Respon Kosong / Non-Numerik** | Delphi mengeksekusi `StrToInt(xl.getString('KUANTITAS')) * StrToInt(xl.getString('NOMINAL'))` tanpa `try...except`. Jika respon bukan angka, aplikasi langsung crash (`EConvertError`). | Klien baru C# bisa crash jika format respons gateway berubah. | Ketiadaan validasi tipe data pada parser JSON Delphi (`uLkJSON`). | Di Go API dan C#, gunakan parsing defensif dengan fallback nilai default: jika `KUANTITAS` kosong, set `0` dan beri pesan user yang informatif. |
| **Port dan Alamat Gateway Hardcoded** | Delphi mengarah ke IP `10.33.41.252:8280` (dan komentar lama `10.60.64.25:8280`). | Klien desktop tidak fleksibel jika IP gateway WSO2 berubah di kemudian hari. | Alamat endpoint API di-hardcode di kode Pascal form (`Utama.pas:2409`). | Alihkan pemanggilan gateway ke Go API. Konfigurasikan IP gateway di file `config.yaml` atau environment variable Go. |

---

### GAP 6: Domain QR Code (Kuitansi Bukti Bayar)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Format Delimiter Pipa (`\|`) Barcode** | Payload dirangkai persis menggunakan pemisah pipa: `Copy(ID_PELANGGAN, 1, 19) + Tahap + '\|' + NIK + '\|' + NAMA + '\|' + ALAMAT_KTP + '\|' + ALAMAT + '\|' + BSU`. | Jika delimiter pipa diganti, atau urutan kolom dan panjang ID Pelanggan berbeda 1 karakter, aplikasi kasir loket pos tidak dapat mem-parsing data kuitansi. | Karakter pipa (`\|`) adalah kontrak baku yang wajib ada karena scanner & aplikasi lain membaca data dengan cara mem-parsing string berpemisah pipa. | Pertahankan 100% format pipe-delimited ini. Buat unit test di C# untuk memvalidasi susunan 6 segmen payload barcode agar identik dengan FastReport lama. |
| **Pencegahan Karakter Pipa Liar dalam Teks Alamat** | FastReport menggabungkan string mentah; jika nama atau alamat mengandung karakter `\|`, aplikasi lain yang mem-parsing dengan fungsi `.Split('\|')` akan membaca kelebihan kolom (>6 segmen). | Indeks kolom bergeser di aplikasi kasir pemindai (misal: BSU terbaca sebagai kelanjutan alamat). | Aplikasi hilir mengandalkan pemisahan string berdasarkan karakter pipa untuk tepat 6 atribut data. | Di C#, bersihkan karakter `\|` yang tidak sengaja ada di dalam teks nama/alamat KPM sebelum dirangkai dengan delimiter pipa resmi, sehingga aplikasi lain menerima tepat 6 segmen terpisah pipa tanpa error. |
| **Level Koreksi Error (ECC Level)** | FastReport menggunakan QR Code dengan Error Correction Level Medium (`M`, ~15%). | Ukuran densitas modul QR Code berubah, menyebabkan barcode sulit di-scan pada kertas kuitansi buram. | Perbedaan konfigurasi library pembuat QR Code. | Di library `QRCoder` C#, set eksplisit `QRCodeGenerator.ECCLevel.M`. |

---

### GAP 7: Domain Printing (Pencetakan Dokumen & Hardware)

| Aspek | Perilaku Aplikasi Delphi Lama | Potensi Perilaku Berbeda di Aplikasi Baru | Akar Masalah (*Root Cause*) | Solusi & Rekomendasi Presisi |
| :--- | :--- | :--- | :--- | :--- |
| **Pencetakan Senyap (*Silent Direct Print*)** | Prosedur `frxReport.Print` mencetak langsung ke printer default Windows tanpa menampilkan dialog konfirmasi printer (*no print dialog*). | Jika C# memunculkan dialog `PrintDialog` setiap kali klik cetak, ritme kerja petugas loket yang melayani ratusan antrean KPM akan terganggu. | FastReport diatur *silent mode* demi kecepatan loket. | Sediakan pengaturan di C#: opsi "Cetak Langsung ke Printer Default" (tanpa dialog) dan tombol terpisah "Pilih Printer". |
| **Instruksi ESC/P Printer Passbook (RAW)** | Mengirim byte kontrol: `#13` (CR), `#8` (Backspace/Indentation), `Chr(15)` (Condensed font), dan 3 baris kosong untuk form feed sobekan kertas. | Jika dicetak via GDI+ grafis biasa, printer passbook IBM 9068A / Epson LQ-300 akan mencetak sangat lambat (mode grafis titik-titik jarum) dan font menjadi kabur. | Karakteristik fisik printer jarum impact / passbook perbankan. | **Wajib Gunakan P/Invoke WinSpool**: Kirim teks dan perintah kontrol byte ESC/P mentah via `winspool.drv` (`OpenPrinter` & `WritePrinter`). |
| **Pemisahan Halaman Ketat (*Strict Pagination*)** | Dokumen Danom membatasi tepat **20 baris per halaman**, dengan header berulang di tiap lembar dan rekapitulasi nominal di lembar terakhir. | Laporan bergeser jika tinggi baris (*row height*) bersifat dinamis. | Standar pertanggungjawaban fisik kertas Danom audit pos. | Pada template **QuestPDF**, atur ukuran tabel tetap (*fixed row height*) dan gunakan kontainer tabel berulang dengan footer rekapituler. |
| **Pemindahan Berkas Fisik Pasca-Cetak** | Setelah cetak sukses, file `.POS` dipindahkan via `MoveFile` dari `data/` ke `sudah_cetak/`. | Jika pemindahan file gagal (karena file terkunci oleh antivirus), sistem Delphi menampilkan dialog error. | *State tracking* berbasis filesystem. | Di sistem baru SQLite, ubah status via transaksi database: `UPDATE penerima_bansos SET status_cetak_danom = 1`. Jauh lebih andal dan tidak rentan terkunci filesystem. |

---

## 3. Matriks Perbandingan Skema Kolom: Ekstraksi vs BNBA vs In-Memory

Untuk mencegah kesalahan pengindeksan data (*off-by-one errors*), tabel berikut memetakan kolom dari Stored Procedure `SIKAP_GET_DATA_BANSOSRS` ke file ekspor BNBA:

| Indeks SP (`Fields[i]`) | Makna Field di Database | Indeks Ekspor BNBA CSV | Header Kolom BNBA CSV | Format / Transformasi di BNBA |
| :---: | :--- | :---: | :--- | :--- |
| **0** | Nomor BST / Batch Utama | Kolom 1 | `BST` | String asli |
| **1** | Nama Penerima Manfaat (KPM) | Kolom 9 | `NAMA` | String asli |
| **2** | Alamat Tempat Tinggal KPM | Kolom 12 | `ALAMAT` | String asli |
| **6** | Nominal Bantuan Tunai (Rp) | Kolom 10 | `NOMINAL` | Format angka tanpa titik |
| **7** | Nomor Registrasi Danom | Kolom 13 | `DANOM` | **Wajib diawali backtick (`` ` ``)** |
| **8** | Nama Kelurahan / Desa | Kolom 7 | `DESA/KELURAHAN` | String asli |
| **10** | Nama Kecamatan | Kolom 6 | `KECAMATAN` | String asli |
| **12** | Nama Kabupaten / Kota | Kolom 5 | `KABUPATEN` | String asli |
| **14** | Nama Provinsi | Kolom 4 | `PROVINSI` | Hapus spasi berulang (`StringReplace`) |
| **16** | Nama Kantor Bayar | Kolom 3 (Bag. 2) | `KANTOR` | Digabung dengan Field 17 (`[17]-[16]`) |
| **17** | Nomor Pendirian (Nopend) | Kolom 3 (Bag. 1) | `KANTOR` | Digabung dengan Field 16 (`[17]-[16]`) |
| **19** | Nomor Batch Penyaluran | Kolom 8 | `BATCH` | String asli |
| **20** | Nomor Regional Pos | Kolom 2 | `REGIONAL` | String asli |
| **21** | Nomor Induk Kependudukan (NIK)| Kolom 11 | `NIK` | **Wajib diawali backtick (`` ` ``)** |
| **32** *(atau opt)* | Desil Kesejahteraan Sosial | Kolom 14 | `PERCENTILE` | Nilai desil DTKS Kemensos |

---

## 4. Rekomendasi Checklist Verifikasi Sebelum UAT Lapangan

Sebelum sistem baru diuji coba ke kantor cabang pos / loket:
- [ ] **Uji Scan Barcode QR**: Cetak kuitansi dari C# dan lakukan pemindaian menggunakan *barcode scanner* USB fisik loket pos eksisting. Pastikan aplikasi kasir teller pos mengenali seluruh 6 segmen data tanpa error.
- [ ] **Uji Kompatibilitas Excel**: Buka berkas `BNBA_*.csv` hasil ekspor C# langsung di Microsoft Excel. Pastikan kolom `NIK` (16 digit) dan `DANOM` tetap terbaca sebagai teks lengkap dan tidak berubah menjadi `3.201E+15`.
- [ ] **Uji Hardware Passbook**: Cetak slip CDS BLT ke printer IBM 9068A atau Epson LQ-300. Pastikan jarum mencetak dalam mode teks kilat (bukan rendering grafis lambat) dan posisi tanda tangan presisi pada slip kertas.
- [ ] **Uji Putus Jaringan (Mode F5)**: Putuskan kabel LAN/koneksi Wi-Fi, lalu buka aplikasi dan tekan tombol F5. Pastikan data yang sudah tersimpan di SQLite lokal tetap dapat dilihat di tabel dan dicetak tanpa hambatan.

