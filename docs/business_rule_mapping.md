# Pemetaan Aturan Bisnis (Business Rule Mapping) - Delphi Legacy vs C# WPF Prototype

Dokumen ini memetakan seluruh aturan bisnis utama yang ditemukan pada analisis rekayasa balik (*reverse engineering*) kode sumber Delphi terhadap implementasi C# WPF pada **Fase 1 Prototipe**.

---

## 1. Matriks Keterlacakan Aturan Bisnis (*Business Rule Traceability*)

| ID Aturan | Domain Bisnis | Implementasi Delphi Warisan | Implementasi C# WPF Prototype | Status Kesesuaian |
| :---: | :--- | :--- | :--- | :---: |
| **BR-01** | **Autentikasi Petugas** | Memanggil SP `SIKAP_LOGIN`. Jika status `'000'`, kolom 1 berisi profil string berpemisah pipa (`IdPetugas\|Nippos\|Nama\|Nopend\|Kantor\|Jabatan`). | Diabstraksikan pada `MockAuthenticationService`. Mengembalikan entitas `Petugas` dengan atribut identik. | **Sesuai (Abstraksi)** |
| **BR-02** | **Proteksi NOPEND Kantor Pos** | Nilai `edtNopend.Text` mengikat batas wilayah penarikan data dan dicetak pada header dokumen. | Entitas `Petugas.Nopend` ("40000") menjadi identitas persisten pada `MainViewModel` dan header cetakan. | **Sesuai** |
| **BR-03** | **Hierarki Wilayah Cascading** | Event `cbbKabupatenChange`, `cbbKecamatanChange` memicu pengisian dropdown anak. | Diimplementasikan di `DanomViewModel` melalui method reaktif `OnProvinsiChanged`, `OnKabupatenChanged`, `OnKecamatanChanged` dengan pembersihan otomatis anak hierarki. | **Sesuai** |
| **BR-04** | **Siklus Status Danom** | Perpindahan file fisik `.POS` dari folder `data/` ke folder `data/sudah_cetak/`. | Dimodelkan dengan state enum `StatusCetak.BelumCetak` -> `StatusCetak.SudahCetak` pada `PenerimaBansos` dengan penanda waktu `WaktuCetakDanom`. | **Modernisasi** *(Jauh lebih stabil dibanding manipulasi filesystem)* |
| **BR-05** | **Ekspor Berkas BNBA** | Prosedur `TFrm_Main.btn_BNBAClick`: 14 kolom header, pemisah titik koma (`;`), backtick (`` ` ``) pada NIK & Danom. | Diimplementasikan di `BnbaRecord.cs` dan `BnbaCsvExportService.cs`. Menghasilkan berkas CSV persis sama dan divalidasi unit test. | **100% Identik** |
| **BR-06** | **Aturan Paging Danom (20 Baris)** | FastReport membatasi tepat 20 baris per halaman, mengulang header di tiap lembar, dan mencetak rekapitulasi di baris terbawah lembar terakhir. | Diimplementasikan di `MockPrintService.PrepareDanomPrintPreviewAsync` dengan pembagian `pageSize = 20`, paging counter, dan footer penandatanganan. | **100% Identik** |
| **BR-07** | **Kontrak QR Code 6 Segmen Pipa** | Prosedur FastReport `Barcode2D1OnBeforePrint`: Merangkai payload 6 segmen berpemisah pipa (`\|`). | Diimplementasikan di `QrPayloadRules.BuildPayload` dan `ValidatePayload`. Dilengkapi neutralisasi defensif karakter pipa liar pada isi teks nama/alamat. | **100% Identik + Hardened** |
| **BR-08** | **Pembulatan Nominal BSU** | BSU dihitung dari kuantitas dikali nominal per tahap, diformat ribuan dengan pemisah koma/titik. | Diimplementasikan di entitas `PenerimaBansos.Nominal` dan string format IDR (`C0` dan `N0`). | **Sesuai** |
| **BR-09** | **Pakta Integritas Pangan SPTJM** | Surat Pernyataan Tanggung Jawab Mutlak membatasi belanja bansos hanya pada 4 unsur gizi pangan Kemensos. | Ditampilkan pada dokumen pratinjau `PrepareSuratPernyataanPrintPreviewAsync` dengan klausul lengkap 4 unsur pangan dan sanksi DTKS. | **Sesuai** |

---

## 2. Analisis Preservasi Logika Kritis

### A. Format Ekspor BNBA (Preservasi Backtick)
* **Logika Asli Delphi (`Utama.pas` line 2320-2345)**:
  ```pascal
  strdata.Add('BST;REGIONAL;KANTOR;PROVINSI;KABUPATEN;KECAMATAN;DESA/KELURAHAN;BATCH;NAMA;NOMINAL;NIK;ALAMAT;DANOM;PERCENTILE');
  ...
  strdata.Add(
    Fields[0].AsString + ';' +
    ...
    '`'+Fields[21].AsString + ';' + // NIK dengan backtick
    Fields[2].AsString + ';' +
    '`'+Fields[7].AsString + ';' +  // Danom dengan backtick
    Fields[32].AsString + ';'
  );
  ```
* **Logika C# WPF (`BnbaRecord.cs`)**:
  ```csharp
  string nikWithBacktick = Nik.StartsWith("`") ? Nik : $"`{Nik}";
  string danomWithBacktick = Danom.StartsWith("`") ? Danom : $"`{Danom}";
  return $"{Sanitize(Bst)};...;{nikWithBacktick};{Sanitize(Alamat)};{danomWithBacktick};{Sanitize(Percentile)};";
  ```
* **Hasil Verifikasi**: Kolom NIK 16-digit (contoh: `3273011001900001`) aman dari pemotongan angka nol di awal atau pengubahan format menjadi notasi eksponensial ilmiah (`3.27301E+15`) saat dibuka menggunakan aplikasi spreadsheet seperti Microsoft Excel atau LibreOffice Calc.

---

### B. Kontrak Barcode 2D (Delimiter Pipa `|`)
* **Logika Asli Delphi (`frBuktiTerima.fr3`)**:
  ```pascal
  Barcode2D1.Text := Copy(<frxDBDataset1."ID_PELANGGAN">,1,19) + Copy(thp_awal.Text,1,1) + '|' +
                     <frxDBDataset1."NIK"> + '|' +
                     <frxDBDataset1."PELANGGAN"> + '|' +
                     <frxDBDataset1."ALAMAT_KTP"> + '|' +
                     <frxDBDataset1."ALAMAT"> + '|' + bsu;
  ```
* **Logika C# WPF (`QrPayloadRules.cs`)**:
  ```csharp
  public static string BuildPayload(...)
  {
      string seg1IdTahap = id19 + thp;
      string seg2Nik = SanitizeNik(nik);
      string seg3Nama = SanitizeTextField(nama);
      string seg4AlamatKtp = SanitizeTextField(alamatKtp);
      string seg5Alamat = SanitizeTextField(alamat);
      string seg6Bsu = nominal.ToString("#,##0", CultureInfo.InvariantCulture);

      return $"{seg1IdTahap}|{seg2Nik}|{seg3Nama}|{seg4AlamatKtp}|{seg5Alamat}|{seg6Bsu}";
  }
  ```
* **Hasil Verifikasi**:
  * Delimiter pipa (`|`) tetap 100% menjadi pemisah resmi antar-kolom.
  * Karakter pipa liar yang secara tidak sengaja terketik di dalam teks alamat dinetralisir menjadi karakter spasi agar aplikasi scanner loket tidak memecah 6 segmen menjadi 7 atau 8 segmen (*defensive parsing protection*).
