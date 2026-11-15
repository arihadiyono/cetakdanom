# Status Implementasi Fitur Prototipe (Fase 1) - CetakDanom

Dokumen ini menyajikan status implementasi dari seluruh modul dan antarmuka operasional yang dibangun pada **Fase 1 Desktop Prototype (C# WPF / .NET 8.0 LTS)**. 

Sesuai permintaan arahan operasional, antarmuka pengguna dirancang **sama persis dengan alur kerja aplikasi Delphi warisan** dengan **4 Menu Utama setelah Login** (tanpa dashboard).

---

## 1. Matriks Status Implementasi 4 Menu Utama

| No | Menu Operasional | Komponen View / ViewModel | Layanan / Abstraksi | Status Implementasi | Status Pengujian | Deskripsi Alur Bisnis |
| :-: | :--- | :--- | :--- | :---: | :---: | :--- |
| **0** | **Login Petugas** | `LoginView.xaml`<br/>`LoginViewModel.cs` | `IAuthenticationService`<br/>`MockAuthenticationService` | **Fungsional** | **Lulus Unit Test** | Validasi user/pass petugas loket pos, mode demo 3 akun (Bandung, Cimahi, SPV), langsung masuk ke Menu 1 tanpa dashboard. |
| **1** | **Unduh Danom** | `UnduhDanomView.xaml`<br/>`UnduhDanomViewModel.cs` | `IWilayahRepository`<br/>`IDanomRepository` | **Fungsional Penuh** | **Lulus Unit Test** | Pemilihan parameter bertingkat (*cascading*): Jenis Bantuan, Nama Program, Tahap, Kabupaten, Kecamatan, Desa. Simulasi unduh data & log aktivitas `memLogProses`. |
| **2** | **Cetak Danom** | `CetakDanomView.xaml`<br/>`CetakDanomViewModel.cs` | `IDanomRepository`<br/>`IExportService`<br/>`IPrintService` | **Fungsional Penuh** | **Lulus Unit Test** | Menampilkan tabel KPM, pencarian NIK/Nama, tombol **Buat BNBA** (CSV titik-koma & backtick NIK), **Pratinjau Format Danom** (20 baris/lembar), dan **Cetak Danom**. |
| **3** | **Cetak Surat** | `CetakSuratView.xaml`<br/>`CetakSuratViewModel.cs` | `ISuratService`<br/>`MockSuratService` | **Fungsional Penuh** | **Lulus Unit Test** | Format surat pemberitahuan/undangan KPM resmi. Teks klausul dibaca dari file `param_xxx.pos` dan logo `logoxxx.jpg` / `logo_perusahaan.jpg`. Cetak satuan atau batch. |
| **4** | **Cetak Danom Satuan (CDS)** | `CetakDanomSatuanView.xaml`<br/>`CetakDanomSatuanViewModel.cs` | `ICdsBltService`<br/>`MockCdsBltService`<br/>`IQrCodeService` | **Fungsional Penuh** | **Lulus Unit Test** | Mengadopsi pola aplikasi **`CDS.exe`**: Input NIK tunggal, tombol Ambil Data & Reset, panel rincian (Nama, NIK, BSU, No Voucher, Perusahaan), grid Bukti Terima, &Preview, dan &Cetak Kuitansi Loket (QR Code 6 segmen pipa). |

---

## 2. Rincian Alur Bisnis per Menu

### Menu 1: Unduh Danom (pnlAmbilData)
- **Komponen Cascading**:
  - `Jenis Layanan Bantuan`: BST, PKH, Sembako, BLT BBM, YAPI.
  - `Tahap Penyaluran`: Tahap 1, 2, 3, 4.
  - `Hierarki Wilayah`: Provinsi &rarr; Kabupaten/Kota &rarr; Kecamatan &rarr; Kelurahan/Desa.
- **Proteksi Dependensi**: Pemilihan tingkat atas me-reset otomatis pilihan di bawahnya guna mencegah anomali data.
- **Proses Penarikan Data**:
  - Tombol `"TARIK / UNDUH DATA DANOM"` memicu proses sinkronisasi data dari server pusat.
  - Progress bar dinamis (0% &rarr; 100%) dan kotak log memo (`memLogProses`) mencatat riwayat pemuatan parameter `param_xxx.pos`, eksekusi stored procedure, dan jumlah record yang tersimpan.
  - Menyediakan tombol pintas `"Lanjut ke Menu 2: Cetak Danom →"` begitu unduhan selesai.

### Menu 2: Cetak Danom (pnlTampilData)
- **DataGrid KPM**: Menampilkan data nominatif penerima bantuan yang telah tersimpan di lokal (No Danom, NIK, Nama KPM, Alamat, Kelurahan, Nominal, Barcode, Status Cetak).
- **Pencarian & Filter**: Pencarian instan teks bebas pada NIK atau Nama KPM, serta filter status cetak (*Belum Cetak* / *Sudah Cetak*).
- **Pembuatan File BNBA (CSV)**:
  - Format delimiter titik koma (`;`).
  - Prefix karakter backtick (`` ` ``) pada field NIK dan Danom agar tidak terbaca sebagai notasi ilmiah (scientific notation) di Microsoft Excel.
  - Tepat 14 kolom skema standar PT Pos Indonesia.
- **Pencetakan Danom**: Menerapkan aturan presisi resmi: **Maksimal 20 baris data per lembar halaman**, berulang header kolom, dan rekapitulasi total nominal di lembar terakhir.

### Menu 3: Cetak Surat (PnlBuktiPernyataan / Surat KPM)
- **Parameter Berkas `param_xxx.pos`**:
  - Baris 1: Header / Judul Surat resmi (misal: `"SURAT PEMBERITAHUAN PENYALURAN BANTUAN SOSIAL TUNAI (BST)"`).
  - Baris 2+: Klausul dan syarat dokumen wajib (Asli KTP-el, Kartu Keluarga, jadwal lokasi bayar di loket pos / komunitas).
- **Pengikatan Gambar Logo**: Mendukung deteksi logo Pos Indonesia (`logo_perusahaan.jpg`) dan logo instansi/kementerian mitra (`logoxxx.jpg`).
- **Pratinjau & Cetak**: Pratinjau surat live dengan nomor berkas, barcode verifikasi NIK, detail KPM, dan kolom tanda tangan ganda (Penerima & Kepala Kantor Pos).

### Menu 4: Cetak Danom Satuan (Pola Aplikasi CDS.exe)
- **Inquiry NIK Mandiri**: Operator loket menginput 16 digit NIK penerima susulan atau KPM individual.
- **Validasi Ketat**: Jika NIK kosong, menampilkan peringatan `"NIK Tidak Boleh Kosong!!"`.
- **Panel Rincian Data Penerima (Identik Form CDS)**:
  - `NAMA LENGKAP KPM`
  - `NIK KPM`
  - `BESAR UANG / BSU` (Format nominal Rupiah tebal)
  - `NO VOUCHER`
  - `NAMA PERUSAHAAN / INSTANSI`
  - `ALAMAT PERUSAHAAN / LOKASI`
  - `HIERARKI WILAYAH` (Provinsi, Kabupaten/Kota, Kecamatan, Kelurahan)
- **Grid Bukti Terima (`griddata_bt`)**: Menampilkan baris transaksi kuitansi yang siap dicairkan.
- **Tombol Operasional Loket**:
  - `&Preview`: Membuka pratinjau kuitansi tanda terima dengan stempel waktu, nominal terbilang, dan panel QR Code 2D.
  - `&Cetak`: Mengirim kuitansi langsung ke printer loket.
- **Validasi QR Code**: Menggunakan payload 6 segmen berpemisah pipa (`|`):
  $$\text{Payload} = \text{IdPelanggan} \mid \text{Tahap} \mid \text{NIK} \mid \text{Nama} \mid \text{Alamat} \mid \text{Nominal}$$

---

## 3. Hasil Pengujian Unit Otomatis (xUnit)

Seluruh logika bisnis, abstraksi service, validasi format, dan aturan delimitasi telah teruji secara otomatis pada proyek `CetakDanom.UnitTests`:
- **Total Pengujian**: 21 Unit Test
- **Status**: **100% Passed (0 Failed, 0 Skipped)**
- **Waktu Eksekusi**: 167 ms
