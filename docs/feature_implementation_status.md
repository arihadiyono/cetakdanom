# Status Implementasi Fitur Prototipe (Fase 1) - CetakDanom

Dokumen ini menyajikan status implementasi dari seluruh modul dan fitur yang dibangun pada **Fase 1 Desktop Prototype (C# WPF / .NET 8.0 LTS)** sesuai dengan kriteria yang ditetapkan pada spesifikasi tugas.

---

## 1. Matriks Status Implementasi Keseluruhan

| Kode Modul | Nama Fitur / Komponen | Komponen UI (WPF) | Layanan / Abstraksi | Status Implementasi | Status Pengujian | Keterangan |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| **MOD-01** | **Login Petugas** | `LoginView.xaml`<br/>`LoginViewModel.cs` | `IAuthenticationService`<br/>`MockAuthenticationService` | **Fungsional (Simulasi)** | **Lulus Unit Test** | Mendukung 3 akun demo cepat (Bandung, Cimahi, SPV). Hashing MD5 produksi sengaja di-skip. |
| **MOD-02** | **Main Dashboard** | `MainView.xaml`<br/>`DashboardHomeView.xaml` | `MainViewModel.cs`<br/>`DashboardHomeViewModel.cs` | **Fungsional Penuh** | **Lulus Verifikasi Visual** | Menampilkan profil petugas, NOPEND (40000), Kantor, 4 kartu metrik KPI, dan badge status DEMO. |
| **MOD-03** | **Cascading Wilayah** | `DanomView.xaml`<br/>(ComboBox Grid) | `IWilayahRepository`<br/>`MockWilayahRepository` | **Fungsional Penuh** | **Lulus Unit Test** | Hierarki Provinsi -> Kabupaten -> Kecamatan -> Kelurahan. Reset otomatis ke bawah saat parent berubah. |
| **MOD-04** | **Danom Data Grid** | `DanomView.xaml`<br/>(DataGrid &amp; Card) | `IDanomRepository`<br/>`MockDanomRepository` | **Fungsional Penuh** | **Lulus Unit Test** | Menampilkan NIK, Nama, Alamat, Kelurahan, Nominal, Tahap, Status Danom &amp; Bukti. Search &amp; Sort aktif. |
| **MOD-05** | **Kalkulasi &amp; Ringkasan** | `DanomView.xaml`<br/>(Mini KPI Bar) | `IDanomRepository.GetSummaryAsync` | **Fungsional Penuh** | **Lulus Unit Test** | Menghitung otomatis Total KPM, Total Nominal Rupiah, Jumlah Siap Cetak, dan Sudah Cetak. |
| **MOD-06** | **Drawer Detail KPM** | `DanomView.xaml`<br/>(Side Panel) | `SelectedPenerima` Binding | **Fungsional Penuh** | **Lulus Verifikasi Visual** | Menampilkan detail lengkap baris penerima yang dipilih pengguna pada tabel (ID Pelanggan, NIK, Alamat, dll). |
| **MOD-07** | **Ekspor BNBA CSV** | `DanomViewModel.cs`<br/>(Tombol Ekspor) | `IExportService`<br/>`BnbaCsvExportService` | **Fungsional Penuh** | **Lulus Unit Test** | Mematuhi 14 kolom skema Delphi, pemisah titik koma (`;`), dan tanda kutip backtick (`` ` ``) pada NIK &amp; Danom. |
| **MOD-08** | **Pratinjau Cetak Danom** | `PrintPreviewView.xaml`<br/>`PrintPreviewViewModel.cs` | `IPrintService.PrepareDanomPrintPreviewAsync` | **Fungsional (Pratinjau)** | **Lulus Verifikasi Visual** | Menerapkan aturan presisi ketat: **Maksimal 20 baris per halaman**, header berulang di tiap lembar. |
| **MOD-09** | **Pratinjau Kuitansi BST** | `PrintPreviewView.xaml` | `IPrintService.PrepareBuktiTerimaPrintPreviewAsync` | **Fungsional (Pratinjau)** | **Lulus Verifikasi Visual** | Menampilkan lembar tanda terima kuitansi tunai, nominal terbilang, stempel waktu, dan panel QR Code. |
| **MOD-10** | **Barcode 2D (QR Code)** | `PrintPreviewView.xaml`<br/>(Image &amp; Inspector) | `IQrCodeService`<br/>`QrCodeService` (QRCoder) | **Fungsional Penuh** | **Lulus Unit Test** | Mengodekan 6 segmen terpisah pipa (`\|`). Validasi ketat kontrak scanner loket &amp; neutralisasi pipa teks. |
| **MOD-11** | **Surat Pernyataan (SPTJM)** | `PrintPreviewView.xaml` | `IPrintService.PrepareSuratPernyataanPrintPreviewAsync` | **Fungsional (Pratinjau)** | **Lulus Verifikasi Visual** | Menampilkan pakta integritas 4 unsur gizi pangan (Karbohidrat, Hewani, Nabati, Vitamin) untuk bansos sembako. |

---

## 2. Rincian Implementasi per Fitur

### A. Fitur Login (MOD-01)
* **Ketersediaan**: Terintegrasi pada form login awal aplikasi (`LoginView.xaml`).
* **Akun Demo**:
  1. `demo` / `demo123` -> Petugas Loket Utama (KCU Bandung 40000).
  2. `petugas01` / `pos12345` -> Operator Cetak Danom (KCU Bandung 40000).
  3. `supervisor` / `super123` -> Manajer Pelayanan Bansos (KCU Bandung 40000).
* **Perilaku Validasi**:
  * Menolak string kosong.
  * Menampilkan pesan kesalahan berbahasa Indonesia jika password keliru.
  * Menyediakan tombol *quick-fill* (1-Klik) untuk pengujian cepat asesor.

### B. Fitur Dashboard (MOD-02)
* **Status Bar**: Menampilkan secara persisten identitas petugas aktif, NIPPOS, kantor cabang pos, kode NOPEND wilayah kerja, serta badge peringatan oranye: `MODE DEMO / SYNTHETIC DATA`.
* **Metrik Real-time**: 4 kartu metrik merangkum status dataset sintetis in-memory.

### C. Fitur Cascading Wilayah (MOD-03)
* **Alur Hirarkis**:
  1. Pemilihan **Provinsi** (`JAWA BARAT` / `DKI JAKARTA`).
  2. Pilihan **Kabupaten** terisi otomatis (`KOTA BANDUNG`, `KOTA CIMAHI`, `KABUPATEN BANDUNG`).
  3. Pilihan **Kecamatan** terisi sesuai Kabupaten (`COBLONG`, `SUKASARI`, dll.).
  4. Pilihan **Kelurahan** terisi sesuai Kecamatan (`DAGO`, `LEBAKGEDE`, `SARIJADI`, dll.).
* **Proteksi Reset Dependensi**:
  * Jika pengguna mengganti Provinsi, ComboBox Kabupaten, Kecamatan, dan Kelurahan langsung di-reset otomatis menjadi kosong untuk mencegah anomali kueri silang wilayah.

### D. Fitur Data Grid Danom (MOD-04, MOD-05, MOD-06)
* **Koleksi Data**: Menampilkan dataset sintetis realistis KPM.
* **Filter Interaktif**:
  * Pencarian instan teks bebas pada input box (mencari substring Nama, NIK 16 digit, ID Pelanggan, atau Alamat).
  * Filter berdasarkan status cetak Danom (`Belum Cetak` / `Sudah Cetak`).
* **Kalkulasi Otomatis**: Baris ringkasan menghitung total uang tunai (BSU) yang wajib disediakan loket pos secara dinamis sesuai filter yang diterapkan.

### E. Fitur Ekspor BNBA (MOD-07)
* **Kesesuaian Kode Delphi**: Divalidasi langsung terhadap prosedur warisan `TFrm_Main.btn_BNBAClick`.
* **Keluaran**: Menghasilkan berkas `Export_BNBA/BNBA_<LAYANAN>_THP<X>_<KELURAHAN>_<TIMESTAMP>.csv`.
* **Preservasi Karakter**:
  * Pemisah antar-kolom adalah titik koma (`;`).
  * Field `NIK` dan nomor `DANOM` diberi awalan backtick (`` ` ``) agar tidak dirusak oleh Excel.
  * Tepat 14 kolom data per baris.

### F. Fitur Pratinjau Dokumen & QR Code (MOD-08, MOD-09, MOD-10, MOD-11)
* **Pratinjau Kertas Monospace**: Dokumen dicetak dengan format teks berbatas lebar tetap yang mencerminkan fisik kertas cetakan dot-matrix/inkjet kantor pos.
* **Aturan 20 Baris Danom**: Menerapkan paging otomatis setiap 20 baris data dengan pengulangan header kolom dan penutup rekapitulasi total nominal di lembar terakhir.
* **Inspeksi QR Code**:
  * Panel inspektur menampilkan gambar bitmap QR Code hasil render library `QRCoder` (ECC Level M).
  * Menampilkan string mentah payload berdelimitasi pipa (`|`).
  * Menjalankan validasi otomatis untuk memastikan struktur barcode tepat terdiri dari 6 segmen yang siap dibaca oleh scanner barcode loket pos.
