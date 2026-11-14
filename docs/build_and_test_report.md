# Laporan Kompilasi & Pengujian Unit (Build and Test Report) - Fase 1

Dokumen ini memuat catatan resmi hasil kompilasi (*build verification*) dan eksekusi pengujian otomatis (*automated unit tests*) untuk solusi **CetakDanom.sln**.

---

## 1. Lingkungan Kompilasi (*Build Environment*)

* **Sistem Operasi**: Windows 10/11 Pro (x64)
* **SDK .NET**: Version **8.0.428** (LTS)
* **Runtime**: .NET Core 8.0.34 / WindowsDesktop.App 8.0.34
* **MSBuild Version**: 17.11.71
* **Arsitektur Target**: `x64`
* **Solusi**: `D:\CetakDanom\CetakDanom.sln`

---

## 2. Hasil Kompilasi Solusi (*Build Verification*)

Perintah:
```powershell
dotnet build "d:\CetakDanom\CetakDanom.sln"
```

**Ringkasan Status Kompilasi Proyek:**

| Nama Proyek | Framework Target | Jenis Keluaran | Lokasi Berkas Biner | Status Kompilasi |
| :--- | :--- | :--- | :--- | :---: |
| `CetakDanom.Domain` | `net8.0` | Class Library | `src\CetakDanom.Domain\bin\Debug\net8.0\CetakDanom.Domain.dll` | **LULUS (0 Error)** |
| `CetakDanom.Application` | `net8.0` | Class Library | `src\CetakDanom.Application\bin\Debug\net8.0\CetakDanom.Application.dll` | **LULUS (0 Error)** |
| `CetakDanom.Infrastructure` | `net8.0` | Class Library | `src\CetakDanom.Infrastructure\bin\Debug\net8.0\CetakDanom.Infrastructure.dll` | **LULUS (0 Error)** |
| `CetakDanom.Desktop` | `net8.0-windows` | WPF Executable | `src\CetakDanom.Desktop\bin\Debug\net8.0-windows\CetakDanom.Desktop.exe` | **LULUS (0 Error)** |
| `CetakDanom.UnitTests` | `net8.0` | xUnit Test Assembly| `tests\CetakDanom.UnitTests\bin\Debug\net8.0\CetakDanom.UnitTests.dll` | **LULUS (0 Error)** |

**Kompilasi Akhir**:
* **0 Peringatan (*Warnings*)**
* **0 Kesalahan (*Errors*)**
* **Durasi Kompilasi**: 9.06 detik

---

## 3. Hasil Pengujian Unit Otomatis (*Unit Test Results*)

Perintah:
```powershell
dotnet test "d:\CetakDanom\CetakDanom.sln" --logger "console;verbosity=detailed"
```

**Ringkasan Eksekusi Pengujian**:
* **Total Pengujian**: **15 Test Cases**
* **Pengujian Lulus (*Passed*)**: **15** (100%)
* **Pengujian Gagal (*Failed*)**: **0**
* **Total Waktu Eksekusi**: 1,16 detik

### Rincian Kasus Uji per Domain:

#### A. Domain QR Code & Delimiter Pipa (`QrPayloadTests`)
1. `BuildPayload_ShouldGenerateStrictSixPipeSegments` [LULUS - 1 ms]: Memastikan payload Barcode 2D terbagi tepat menjadi 6 segmen berpemisah pipa (`|`).
2. `BuildPayload_ShouldSanitizeStrayPipesInAddressAndName_PreservingSixSegments` [LULUS - 8 ms]: Menguji neutralisasi karakter pipa liar di dalam teks alamat ("JL. MERDEKA | NO. 45") agar jumlah segmen tetap presisi 6 kolom saat diparsing scanner loket.
3. `ValidatePayload_WithValidPayload_ReturnsTrue` [LULUS - 19 ms]: Memvalidasi payload sah menghasilkan status valid.
4. `ValidatePayload_WithFewerSegments_ReturnsFalse` [LULUS - <1 ms]: Memastikan payload dengan segmen kurang (<6) ditolak oleh sistem.
5. `ValidatePayload_WithInvalidNik_ReturnsFalse` [LULUS - <1 ms]: Memastikan payload dengan NIK non-numerik atau bukan 16 digit ditolak.

#### B. Domain Ekspor BNBA CSV (`BnbaExportTests`)
6. `BnbaRecord_Header_HasExact14ColumnsMatchingDelphi` [LULUS - <1 ms]: Memverifikasi bahwa header berkas CSV tepat memiliki 14 nama kolom standar Delphi.
7. `BnbaRecord_ToCsvRow_MustPrefixNikAndDanomWithBacktick` [LULUS - 8 ms]: Memverifikasi bahwa baris CSV menambahkan tanda kutip backtick (`` ` ``) pada field NIK dan Danom.
8. `BnbaExportService_ShouldCreateCsvFileAndValidateCount` [LULUS - 71 ms]: Menguji pembuatan fisik berkas CSV ke direktori lokal, memvalidasi integritas baris data dan ukuran berkas.

#### C. Domain Wilayah & Autentikasi (`WilayahAndAuthTests`)
9. `WilayahRepository_ShouldReturnValidCascadingHierarchy` [LULUS - 13 ms]: Memverifikasi relasi hierarkis Provinsi Jawa Barat -> Kota Bandung -> Coblong -> Dago.
10. `AuthenticationService_DemoAccount_ShouldLoginSuccessfully` [LULUS - 10 ms]: Menguji keberhasilan login akun demo `demo`/`demo123`, verifikasi profil petugas, NOPEND, dan status autentikasi.
11. `AuthenticationService_WrongPassword_ShouldFail` [LULUS - 1 ms]: Menguji penolakan login saat kata sandi salah.

#### D. Domain Pengelolaan Danom (`DanomRepositoryTests`)
12. `DanomRepository_ShouldFilterByKelurahanDago` [LULUS - 3 ms]: Menguji filter data berdasarkan kode kelurahan Dago.
13. `DanomRepository_SearchByNameOrNik_ShouldReturnMatchingRecords` [LULUS - 1 ms]: Menguji pencarian teks bebas substring nama KPM ("BUDI").
14. `DanomRepository_GetSummary_ShouldCalculateAccurateTotals` [LULUS - 7 ms]: Menguji kalkulasi metrik ringkasan Total KPM dan Total Rupiah.
15. `DanomRepository_UpdateStatusCetakDanom_ShouldMarkRecordsAsSudahCetak` [LULUS - 20 ms]: Menguji transisi status cetak dari `BelumCetak` ke `SudahCetak` berserta penanda waktu audit.
