# 09. Analisis Risiko Migrasi ke Delphi Modern (Delphi 11 Alexandria / 12 Athens)

## 1. Ringkasan Opsi Migrasi Delphi Modern

Migrasi ke **Delphi Modern (11.x Alexandria / 12.x Athens)** menawarkan keuntungan *time-to-market* tercepat karena mempertahankan bahasa pemrograman Object Pascal yang sama, struktur form VCL yang serupa, serta kompatibilitas pustaka FastReport. Namun demikian, terdapat sejumlah risiko teknis mendasar akibat perbedaan arsitektur runtime compiler antara Delphi 5/7 (rilis 1999–2002) dan Delphi modern (64-bit, LLVM, Unicode).

---

## 2. Matriks Analisis Risiko Teknis

| Faktor Risiko | Probabilitas | Tingkat Dampak | Kategori Masalah | Deskripsi Risiko |
| :--- | :---: | :---: | :--- | :--- |
| **Breaking Change: UnicodeString (UTF-16)** | **Pasti (100%)** | **Kritis** | Compiler / Runtime | Perubahan representasi `Char` dan `String` dari 1-byte (Ansi) menjadi 2-byte (UTF-16) merusak seluruh modul enkripsi, kompresi, dan kalkulasi ukuran buffer pointer. |
| **Pustaka Biner 32-bit (.obj) C Obsolete** | **Pasti (100%)** | **Tinggi** | Linker / Toolchain | Berkas `compress.obj`, `deflate.obj`, dll. berformat Borland OMF 32-bit tidak dapat di-link ke target kompilasi 64-bit (Win64). |
| **Inkompatibilitas kbmMemTable v5.00** | **Tinggi** | **Kritis** | Pihak Ketiga | Versi 5.00 tidak mengenali compiler modern. Biaya lisensi upgrade atau refactoring ke `TFDMemTable` (FireDAC). |
| **DFM Raksasa (88 MB) Crash di IDE** | **Tinggi** | **Tinggi** | Tooling / IDE | DFM 88 MB berisi ribuan baris heksadesimal FastReport berpotensi menyebabkan *Out of Memory* pada IDE Delphi modern saat membuka form designer. |
| **Pustaka Visual Obsolete (BvComponents, GPanel)** | **Tinggi** | **Sedang** | UI / VCL | `TbvDBGrid`, `GPanel`, dan `AHMTLabel` tidak memiliki installer resmi untuk Delphi 12. |
| **Deprecations Driver OLE DB SQL Server** | **Sedang** | **Sedang** | Database Access | Driver `SQLOLEDB.1` sudah dihentikan dukungannya oleh Microsoft, memicu masalah pada Windows 11 terbaru. |
| **Perilaku Pointer & Memory Alignment Win64** | **Tinggi** | **Tinggi** | Low-Level Code | Manipulasi pointer bertipe `Cardinal`/`Integer` pada `NCONN` dan `NCrypt` menyebabkan *Access Violation* pada build 64-bit (`NativeInt`). |

---

## 3. Analisis Mendalam Isu-Isu Kritis

### A. Masalah Unicode (AnsiString vs UnicodeString)
Pada Delphi 5 dan 7:
- `SizeOf(Char) = 1` byte. `String = AnsiString`.
- Kode kriptografi dan hashing pada `NCrypt.pas` dan `NZip.pas` banyak melakukan konversi tipe langsung (*typecasting*) pointer buffer:
  ```pascal
  // Cuplikan Nzip.pas:63-64
  SetLength(s, outBytes);
  moveI32(pointer(outBuf)^, pointer(s)^, outBytes);
  ```
- Pada Delphi Modern:
  - `SizeOf(Char) = 2` byte (UTF-16). `String = UnicodeString`.
  - Operasi di atas akan mengalokasikan memori sebesar `outBytes * 2` dan menyalin byte mentah ke dalam karakter UTF-16 ganjil, yang mengakibatkan rusaknya data (*data corruption*) dan kegagalan dekripsi file `.POS` dan `conf.bns`.
- **Solusi Mitigasi**: Wajib me-refactor seluruh penanganan buffer biner menggunakan `TBytes`, `RawByteString`, atau `AnsiString` dengan codepage CP_ACP secara eksplisit.

---

### B. Penghapusan Berkas Objek C 32-bit (`.obj`)
Modul `NZip.pas` saat ini me-link berkas objek C lawas:
```pascal
{$L adler32.obj}
{$L compress.obj}
{$L crc32.obj}
{$L deflate.obj}
{$L trees.obj}
```
- Berkas objek ini dikompilasi dengan Borland C++ Builder dalam format OMF (*Object Module Format*) 32-bit.
- Linker Win64 Delphi menggunakan format COFF (*Common Object File Format*). Linker akan menolak berkas tersebut.
- **Solusi Mitigasi**: Hapus berkas `.obj` tersebut dan ganti seluruh dependensi `NZip` dengan unit bawaan Delphi modern: `System.ZLib`.

---

### C. Refactoring In-Memory Table: `kbmMemTable` vs `TFDMemTable`
- `kbmMemTable v5.00` adalah komponen pihak ketiga berbayar yang tidak kompatibel dengan Delphi 11/12.
- **Rekomendasi Modernisasi**:
  - Hindari membeli lisensi baru kbmMemTable.
  - Alihkan (*refactor*) seluruh dataset in-memory ke **`TFDMemTable`** yang merupakan komponen standar bawaan FireDAC di Delphi modern.
  - `TFDMemTable` mendukung penyimpanan struktur tabel, index lokal, serta serialisasi native ke format XML dan JSON biner (Stream).

---

### D. Penanganan DFM Raksasa (`Utama.dfm` = 88 MB)
- Penyimpanan 9 objek laporan FastReport lengkap dengan gambar logo biner di dalam DFM membuat form sangat rapuh dan memperlambat pembukaan proyek di IDE Delphi modern.
- **Solusi Mitigasi**:
  1. Ekstrak seluruh definisi laporan dari DFM ke berkas mandiri `.fr3` di folder `reports/`.
  2. Muat laporan saat runtime menggunakan perintah:
     ```pascal
     frxReport.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'reports\frDanom.fr3');
     ```
  3. Bersihkan definisi laporan dari DFM sehingga ukuran `Utama.dfm` turun dari 88 MB menjadi < 500 KB.

---

### E. Driver Basis Data: Dari `SQLOLEDB` ke FireDAC / MSOLEDBSQL
- `ULogin.dfm` menggunakan koneksi: `Provider=SQLOLEDB.1`. Provider OLE DB lawas ini tidak mendukung enkripsi TLS modern (TLS 1.2 / 1.3) yang diterapkan pada Windows Server dan SQL Server terbaru.
- **Solusi Mitigasi**:
  - Ganti `TADOConnection` dengan `TFDConnection` (FireDAC) menggunakan driver `MSSQL`.
  - FireDAC mendukung koneksi langsung berkinerja tinggi ke Microsoft SQL Server tanpa lapisan perantara OLE DB yang kedaluwarsa.

---

## 4. Rencana Kerja & Estimasi Upaya (*Effort Estimation*)

Jika diputuskan untuk tetap menggunakan Delphi Modern (Delphi 12 Athens):

| Tahapan Migrasi | Estimasi Upaya | Tingkat Kompleksitas |
| :--- | :---: | :---: |
| 1. Pembersihan DFM 88 MB & Ekstraksi Template FastReport | 3 Hari Kerja | Sedang |
| 2. Perbaikan Kode Unicode (`AnsiString`, `TBytes`, Pointer Casts) | 5 Hari Kerja | Tinggi |
| 3. Migrasi Kompresi ke `System.ZLib` & Kriptografi Modern | 3 Hari Kerja | Sedang |
| 4. Migrasi `kbmMemTable` ke `TFDMemTable` (FireDAC) | 7 Hari Kerja | Tinggi |
| 5. Penggantian Komponen Visual UI (`TbvDBGrid`, `TdxButton`, `GPanel`) | 5 Hari Kerja | Sedang |
| 6. Uji Kompatibilitas RAWPrinter pada Driver Windows 11 64-bit | 2 Hari Kerja | Rendah |
| 7. Pengujian Regresi Siklus Cetak Lapangan & Validasi Data POS | 5 Hari Kerja | Sedang |
| **Total Estimasi Upaya** | **30 Hari Kerja** | **Tinggi** |

