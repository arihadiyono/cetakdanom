# 05. Inventaris Seluruh Form Aplikasi & Pustaka

## 1. Ringkasan Inventaris Form

Berdasarkan penelusuran seluruh berkas DFM (*Delphi Form*) dan XFM (*CLX/Cross-Platform Form*), ditemukan total **21 form unik** yang terbagi menjadi dua kategori:
1. **Form Aplikasi Utama**: 5 Form (Login, Utama, Konfigurasi Server, QuickReport, Auto-Updater).
2. **Form Utilitas & Komponen Pihak Ketiga**: 16 Form (Editor grid, dialog pencarian, desainer dataset, editor SQL/transaksi UIB).

---

## 2. Rincian Form Aplikasi Utama (*Application Forms*)

### A. `TFrm_Login` (`ULogin.pas` / `ULogin.dfm`)
- **Lokasi**: `ToolCetakDanom/src/ULogin.*` dan `ToolCetakDanom_QR/src/ULogin.*`
- **Tujuan**: Pintu masuk utama aplikasi, validasi kredensial pengguna, pengecekan otorisasi petugas loket pos, dan pemeriksaan versi aplikasi terhadap database.
- **Komponen Utama**:
  - `txt_UserId`, `txt_Passwd`: Input username dan password petugas.
  - `btn_Login`, `btn_Exit`: Tombol eksekusi otentikasi dan keluar.
  - `lblJudul`, `lblVersi`: Label informasi versi (`TNxLabel` / `TAHMLabel`).
  - `conADOLogincon`: `TADOConnection` terhubung ke SQL Server (`fd_db_dev_bsm`).
  - `ADOloginQuery`: `TADOQuery` untuk eksekusi `exec SIKAP_LOGIN :ID_PETUGAS,:PASS_PETUGAS,:APPVERSI`.
  - `img_Login`: Logo aplikasi (klik tersembunyi dapat membuka konfigurasi server).
- **Event Penting**:
  - `FormShow`: Memeriksa file konfigurasi `conf.bns`. Jika belum ada, memunculkan form `Frm_Server`.
  - `FormKeyDown`: Menangkap tombol **F5** untuk beralih ke **Mode Lokal (Offline)**.
  - `btn_LoginClick`: Melakukan hashing `StrToMD5(UserID + Password)`, validasi versi aplikasi, dan jika sukses menyalin metadata petugas (`IdPetugas`, `Nippos`, `Nama`, `Nopend`, `Kantor`, `Jabatan`) ke `Frm_Main`.

---

### B. `TFrm_Main` (`Utama.pas` / `Utama.dfm`)
- **Lokasi**: `ToolCetakDanom/src/Utama.*` (1 MB DFM) dan `ToolCetakDanom_QR/src/Utama.*` (88 MB DFM)
- **Tujuan**: Pusat orkestrasi seluruh alur bisnis aplikasi: pengambilan data hierarkis, pemisahan file per kelurahan, preview laporan, pencetakan Danom & kuitansi bantuan sosial, ekspor file BNBA, dan pengecekan API CDS BLT.
- **Panel Kerja (Multi-Panel Interface Switching)**:
  1. `pnlAmbilData`: Panel proses penarikan data dari server pusat (berisi combo layanan, tahap, kabupaten, kecamatan, kelurahan, dan tombol eksekusi ambil).
  2. `pnlTampilData`: Panel visualisasi data file `.POS` terpilih dalam grid data `TbvDBGrid`.
  3. `pnlBuktiTerima`: Panel cetak kuitansi tanda terima bantuan (Bukti Bayar BST/Bansos).
  4. `PnlBuktiPernyataan`: Panel cetak Surat Pernyataan Tanggung Jawab KPM Sembako/BPNT.
  5. `pnlCDS`: Panel pencarian KPM susulan (CDS BLT) via NIK secara online ke REST API WSO2.
- **Komponen Dataset & Grid**:
  - `griddata`, `griddata_bt`, `griddata_btPernyataan`, `bvDBGrid1`: Grid data turunan `TbvDBGrid`.
  - `ds`, `dsconn`, `ds_load`: `TDataSource` yang terhubung ke in-memory dataset `kbmMemTable`.
  - `Query`: `TADOQuery` untuk kueri hierarki wilayah dan bansos.
  - `csvds`: `TSdfDataSet` untuk pembacaan teks file berpemisah kolom.
- **Komponen Laporan & Pencetakan**:
  - `frxReport`: FastReport untuk Cetak Danom Standar.
  - `frxReport2`, `frxReport3`, `frxReportDnmYapi`: FastReport varian template Danom instansi/YAPI.
  - `frxReportBT`: FastReport Bukti Terima Bansos dengan QR Code 2D.
  - `frxReportBTPernyataan`: FastReport Surat Pernyataan Tanggung Jawab Mutlak.
  - `frxReport1`, `frxReport4`, `frxReportYapi`: FastReport Bukti Terima spesifik program lain.
  - `frPDF`: `TfrxPDFExport` untuk ekspor laporan langsung ke format PDF.
  - `TRAWPrinter` (dibuat via kode): Pencetakan teks langsung ke printer dot-matrix / passbook printer.
- **Komponen Visual Khusus**:
  - `gifSedangProses`: `TJvGIFAnimator` indikator animasi loading transaksi.
  - `pb`: `TGauge` progress bar proses penarikan data kelurahan.
  - `listFile`, `listFile_bt`, `listFile_btPernyataan`: Listbox inventaris file `.POS` lokal.

---

### C. `TFrm_Server` (`ServerConf.pas` / `ServerConf.dfm`)
- **Lokasi**: `ToolCetakDanom/src/ServerConf.*` dan `ToolCetakDanom_QR/src/ServerConf.*`
- **Tujuan**: Antarmuka konfigurasi profil koneksi server jaringan.
- **Komponen Utama**:
  - `lstserver`: `TDBLookupListBox` menampilkan daftar profil koneksi yang tersimpan.
  - `txt_Alias`: ComboBox alias identitas profil koneksi (pilihan: `'SKS'`, `'FDPOS'`).
  - `cbo_type`: Jenis middleware/protokol (`'SOCK'`, `'MSSQL'`, `'FB'`).
  - `txt_host`: Hostname atau Alamat IP Server.
  - `txt_user`, `txt_pass`: Kredensial akun database/middleware.
  - `txt_timeout`: Batas waktu time-out koneksi (default `20000` ms).
  - `bt_save`, `bt_edit`, `bt_delete`, `bt_connect`: Tombol CRUD profil.
- **Penyimpanan**: Menyimpan seluruh konfigurasi ke file biner terenkripsi dan terkompresi `conf.bns`.

---

### D. `TQuickReport1` (`Unit1.pas` / `Unit1.dfm` & `r.dfm`)
- **Lokasi**: `ToolCetakDanom/src/Unit1.*` dan `ToolCetakDanom_QR/src/r.dfm`
- **Tujuan**: Mesin pelaporan alternatif berbasis **QuickReport** (sebelum migrasi penuh ke FastReport).
- **Komponen Utama**:
  - `TQuickReport1`: Form canvas laporan QuickReport (`TQuickRep`).
  - `QRBand1` s.d. `QRBand4`: Band header, detail, dan footer.
  - `QRDBText1`, `QRDBText2`: Komponen data binding field database.
  - `Barcode2D_QRCode1`: Komponen Han-soft 2D Barcode untuk merender QR Code.

---

### E. `TForm1` (`uUpdate.pas` / `uUpdate.dfm`)
- **Lokasi**: `downloadParam/uUpdate.*`
- **Tujuan**: Sub-aplikasi independen (*executable* `download.exe` / `update.exe`) untuk mengunduh berkas binary executable (`cetakDanom.exe`, `cetak.exe`) atau aset gambar (`logo_perusahaan.jpg`) dari web repository server.
- **Komponen Utama**:
  - `idHTTP`: `TIdHTTP` klien HTTP Indy.
  - `pb`: `TGauge` visual progress bar unduhan.
  - `lblJudul`: Informasi status proses unduhan.
  - `txtPenanda`: Komponen edit tersembunyi sebagai pengirim sinyal status thread ke UI utama.

---

## 3. Form Pustaka & Desain (*Library & Design-Time Forms*)

Form-form berikut berada di direktori `lib/` dan berfungsi sebagai editor visual pada saat perancangan (*design-time*) atau modul dialog utilitas:

| Nama Form / Berkas | Unit Pascal Terkait | Tujuan / Fungsi |
| :--- | :--- | :--- |
| `bvColumsEditor.dfm` | `bvColumsEditor.pas` | Editor pemilihan dan penyusunan kolom pada komponen `TbvDBGrid`. |
| `bvConfirmUnit.dfm` | `bvConfirmUnit.pas` | Kotak dialog konfirmasi aksi pengguna kustom. |
| `bvFindDialogUnit.dfm` | `bvFindDialogUnit.pas` | Dialog pencarian data (*Find & Replace*) pada grid data. |
| `bvGetAlignmentUnit.dfm`| `bvGetAlignmentUnit.pas`| Dialog pemilihan perataan teks kolom (*Left, Center, Right*). |
| `bvMessageUnit.dfm` | `bvMessageUnit.pas` | Dialog penampil pesan kustom dan log kesalahan sistem. |
| `bvNewFieldUnit.dfm` | `bvNewFieldUnit.pas` | Dialog pendefinisian field baru pada dataset in-memory. |
| `bvSaveTableGetColumnsUnit.dfm` | `bvSaveTableGetColumnsUnit.pas` | Dialog pemilihan kolom sebelum ekspor tabel ke berkas eksternal. |
| `bvSaveTableUnit.dfm` | `bvSaveTableUnit.pas` | Dialog konfigurasi ekspor tabel ke Excel (*Biff8*) atau CSV. |
| `bvSeeDocUnit.dfm` | `bvSeeDocUnit.pas` | Jendela pratinjau teks/dokumen terformat sederhana. |
| `bvSeeTableUnit.dfm` | `bvSeeTableUnit.pas` | Jendela pratinjau data tabel biner. |
| `bvWaitunitF2.dfm` | `bvWaitunitF2.pas` | Dialog animasi penunggu proses (*Wait Cursor / Loading Form*). |
| `jvuibdatabaseedit.dfm` / `.xfm` | `jvuibdatabaseedit.pas` | Editor koneksi database Firebird/InterBase untuk JvUIB. |
| `jvuibsqledit.dfm` / `.xfm` | `jvuibsqledit.pas` | Editor kueri SQL visual interaktif untuk JvUIB. |
| `jvuibtransactionedit.dfm` / `.xfm`| `jvuibtransactionedit.pas`| Editor parameter transaksi isolasi database untuk JvUIB. |
| `kbmMemTableDesForm.xfm`| `kbmMemTableDesForm.pas`| Desainer struktur tabel dan data editor komponen `kbmMemTable`. |
| `SQLMemDatabaseDesigner.dfm` | `SQLMemDatabaseDesigner.pas` | Desainer skema database lokal berbasis memori `SQLMemTable`. |
| `SQLMemFldLinks.dfm` | `SQLMemFldLinks.pas` | Editor relasi *Master-Detail field link* pada `SQLMemTable`. |

