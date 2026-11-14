# 10. Analisis Risiko Migrasi ke C# (.NET 8 / .NET 9)

## 1. Evaluasi Kelayakan & Kecocokan Arsitektur C# .NET

Migrasi ke ekosistem **C# (.NET 8 / .NET 9)** merupakan jalur modernisasi paling matang (*enterprise-grade*) untuk aplikasi CetakDanom. Mengingat infrastruktur PC loket PT Pos Indonesia mayoritas menggunakan sistem operasi Microsoft Windows dengan backend pusat Microsoft SQL Server, .NET memiliki sinergi arsitektur yang sangat tinggi.

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION: WPF (Windows Presentation Foundation) / MVVM  │
│ - CommunityToolkit.Mvvm (Reactive UI, Data Binding)         │
│ - MaterialDesignInXaml / MahApps.Metro (Modern Look)        │
├─────────────────────────────────────────────────────────────┤
│ BUSINESS LOGIC & ORCHESTRATION                              │
│ - File Pipeline & Relocation Manager                        │
│ - BNBA CSV Generator (CsvHelper)                            │
│ - CDS BLT Service (HttpClientFactory, System.Text.Json)     │
├─────────────────────────────────────────────────────────────┤
│ REPORTING & PRINTING ENGINE                                 │
│ - QuestPDF / FastReport .NET (PDF & Kuitansi QR Code)       │
│ - Win32 Spooler P/Invoke (Direct ESC/P Passbook Printing)   │
├─────────────────────────────────────────────────────────────┤
│ LOCAL DATA STORAGE & CACHE                                  │
│ - SQLite (Microsoft.Data.Sqlite) / Encrypted DB             │
│ - Menggantikan sistem flat-file *.POS yang rapuh            │
├─────────────────────────────────────────────────────────────┤
│ DATA ACCESS LAYER                                           │
│ - Dapper (Micro-ORM untuk Stored Procedure SQL Server)      │
│ - Microsoft.Data.SqlClient (Dukungan penuh TLS 1.3 & Entra) │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Matriks Analisis Risiko Migrasi ke C#

| Faktor Risiko | Probabilitas | Tingkat Dampak | Kategori Masalah | Deskripsi Risiko |
| :--- | :---: | :---: | :--- | :--- |
| **Inkompatibilitas Stream kbmMemTable Biner** | **Pasti (100%)** | **Kritis** | Data Serialization | .NET tidak dapat membaca stream biner terkompresi `TkbmMemTable` lama dari file `.POS` legacy tanpa parser manual yang kompleks. |
| **Perbedaan Scripting Template FastReport** | **Pasti (100%)** | **Tinggi** | Reporting Engine | Kode PascalScript pada template `frBuktiTerima.fr3` dan `Pernyataan.fr3` tidak dapat dieksekusi di .NET dan harus ditulis ulang ke C# script atau engine baru. |
| **Pencetakan Dot-Matrix / Passbook Spooling** | **Tinggi** | **Tinggi** | Hardware Interop | Penggunaan driver grafis standar GDI+ pada printer dot-matrix akan menghasilkan cetakan yang sangat lambat dan kabur (*slow graphic printing*). |
| **Divergensi Kriptografi DCPcrypt Blowfish** | **Sedang** | **Sedang** | Security / Crypto | Algoritma Blowfish bawaan .NET (atau BouncyCastle) memerlukan konfigurasi cipher mode dan padding yang identik untuk membaca konfigurasi `conf.bns` lama. |
| **Ketergantungan Komunikasi Socket NCONN** | **Sedang** | **Tinggi** | Network Protocol | Jika backend server masih menggunakan port 2P dengan soket biner kbmMemTable, klien .NET harus mengimplementasikan deserializer soket tersebut. |

---

## 3. Rincian Isu Kritis & Solusi Mitigasi

### A. Format Serialisasi File Transaksi (`.POS`)
- **Masalah**: Pada sistem lama, file `.POS` disimpan menggunakan `SaveToStream` biner dari `TkbmMemTable` lalu dikompresi ZLib dan dienkripsi Blowfish. .NET tidak memiliki pustaka native yang dapat mem-parsing tata letak memori internal kbmMemTable.
- **Solusi Mitigasi**:
  1. Jangan memaksakan pembacaan file biner `.POS` lama pada aplikasi baru.
  2. Ganti mekanisme file lokal dengan **SQLite terenkripsi (SQLCipher / AES)** atau format **JSON/Parquet**.
  3. Setiap batch kelurahan disimpan ke tabel SQLite lokal (`DanomLocalCache.db`), yang jauh lebih tangguh terhadap kerusakan berkas (*file corruption*), mendukung transaksi ACID, dan memiliki kueri SQL instan.

---

### B. Migrasi Mesin Pelaporan (*Reporting Engine*)
- **Masalah**: Berkas template laporan FastReport (`*.fr3`) memuat script PascalScript internal (contoh pada `frBuktiTerima.fr3`):
  ```pascal
  procedure MasterData1OnBeforePrint(Sender: TfrxComponent);
  begin
    bsu := FormatFloat('#,##0', <frxDBDataset1."TOTAL">);
    if (StrToInt(Copy(thp_akhir.Text,1,1)) - StrToInt(Copy(thp_awal.Text,1,1)) = 2) then ...
  ```
- **Solusi Mitigasi**:
  - **Pilihan 1 (Direkomendasikan)**: Gunakan **QuestPDF** (Fluent API C#). Seluruh logika percabangan multi-tahap dipindahkan sepenuhnya ke dalam kode C# yang bersih (*strongly typed*), dapat diuji via unit test, dan menghasilkan berkas PDF dengan kecepatan render tinggi tanpa bergantung pada desainer visual eksternal. Barcode QR dirender menggunakan pustaka **QRCoder** / **SkiaSharp**.
  - **Pilihan 2**: Gunakan **FastReport .NET**. Template `.fr3` diimpor ke format `.frx` FastReport .NET, dan script event diubah dari PascalScript menjadi C#.

---

### C. Penanganan Pencetakan RAW Printer (Passbook & Dot-Matrix)
- **Masalah**: Fitur `btnCtkCdsClick` pada aplikasi lama menggunakan `TRAWPrinter` untuk mencetak langsung ke printer passbook IBM 9068A atau Epson LQ-300 tanpa driver grafis. Jika mencetak melalui dialog Windows biasa, jarum printer dot-matrix akan bekerja mencetak titik per titik (lambat dan bising).
- **Solusi Mitigasi**:
  - Implementasikan kelas pembantu `RawPrinterHelper` menggunakan Win32 Spooler P/Invoke:
    ```csharp
    [DllImport("winspool.drv", CharSet = CharSet.Ansi, ExactSpelling = true)]
    public static extern bool OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

    [DllImport("winspool.drv", ExactSpelling = true)]
    public static extern bool StartDocPrinter(IntPtr hPrinter, int level, [In] DOCINFOA di);

    [DllImport("winspool.drv", ExactSpelling = true)]
    public static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, int dwCount, out int dwWritten);
    ```
  - Kirim perintah byte ESC/P standar (`0x1B, 0x40`, form feed `0x0C`) langsung ke buffer printer fisik.

---

### D. Akses Basis Data SQL Server
- **Keuntungan C#**: Akses ke SQL Server adalah keunggulan utama ekosistem .NET.
- **Implementasi yang Disarankan**:
  - Gunakan **Dapper** dan **Microsoft.Data.SqlClient**:
    ```csharp
    using var connection = new SqlConnection(connectionString);
    var parameters = new DynamicParameters();
    parameters.Add("@ID_PETUGAS", userId);
    parameters.Add("@PASS_PETUGAS", md5Hash);
    parameters.Add("@APPVERSI", appVersion);

    var result = await connection.QueryFirstOrDefaultAsync<LoginResponse>(
        "SIKAP_LOGIN", parameters, commandType: CommandType.StoredProcedure);
    ```
  - Mendukung enkripsi koneksi modern (TLS 1.2 / 1.3, Encrypt=Mandatory, TrustServerCertificate).

---

## 4. Evaluasi Beban Kerja & Rekomendasi Migrasi C#

| Komponen Arsitektur | Teknologi Target (.NET) | Estimasi Hari Kerja |
| :--- | :--- | :---: |
| Antarmuka Pengguna (UI) | WPF (XAML) + CommunityToolkit.Mvvm | 10 Hari |
| Autentikasi & Integrasi SQL Server | Microsoft.Data.SqlClient + Dapper | 4 Hari |
| Integrasi REST API (CDS BLT) | HttpClient + System.Text.Json | 2 Hari |
| Penyimpanan Lokal & Data Pipeline | SQLite (Microsoft.Data.Sqlite) | 4 Hari |
| Mesin Laporan (Danom, Bukti Terima, Surat) | QuestPDF + QRCoder | 8 Hari |
| Driver Pencetakan Slip Raw Printer | WinSpool P/Invoke (RawPrinterHelper) | 3 Hari |
| Auto-Update / Packaging | MSIX / Velopack (.NET Modern Updater) | 3 Hari |
| Quality Assurance & Pengujian Regresi Lapangan | Uji Stres & Uji Hardware Printer Loket | 6 Hari |
| **Total Estimasi Upaya** | | **40 Hari Kerja** |

> [!TIP]
> **Kesimpulan**: C# .NET adalah jalur migrasi yang **paling direkomendasikan** untuk target lingkungan operasional jangka panjang di PT Pos Indonesia karena stabilitas runtime pada Windows, dukungan native SQL Server, kemudahan menangani printer passbook loket, dan melimpahnya tenaga ahli developer C# di pasar.

