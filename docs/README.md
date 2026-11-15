# Dokumentasi Reverse Engineering & Analisis Modernisasi CetakDanom (FDPOS)

Dokumentasi ini disusun sebagai hasil analisis menyeluruh (*comprehensive reverse engineering*) terhadap repositori aplikasi **CetakDanom / FDPOS (Fund Distribution PT Pos Indonesia)** berbasis Borland Delphi 5 dan Delphi 7 untuk kepentingan modernisasi sistem perangkat lunak.

---

## 1. Daftar Dokumen Hasil Analisis

Seluruh temuan telah dianalisis dan disimpan ke dalam berkas Markdown terpisah per topik di dalam folder `/docs`:

| No | Dokumen | Topik Pembahasan |
| :---: | :--- | :--- |
| **01** | [01. Ringkasan Eksekutif & Pemahaman Project](file:///d:/CetakDanom/docs/01_ringkasan_eksekutif_dan_pemahaman_project.md) | Ikhtisar sistem, sejarah pengembangan PT Pos Indonesia, domain bantuan sosial (BST, BPNT, Sembako, BLT, YAPI), serta struktur repositori. |
| **02** | [02. Identifikasi Arsitektur Aplikasi](file:///d:/CetakDanom/docs/02_arsitektur_aplikasi.md) | Topologi arsitektur 2-Tier/3-Tier hibrida, dual-mode execution (Online vs Mode Lokal F5), layering, dan *state machine* pemindahan folder berkas. |
| **03** | [03. Identifikasi Database & Model Data](file:///d:/CetakDanom/docs/03_identifikasi_database.md) | RDBMS Microsoft SQL Server (`fd_db_dev_bsm`), katalog lengkap Stored Procedures `SIKAP_*`, skema tabel in-memory Danom, format ekspor BNBA, dan profil `conf.bns`. |
| **04** | [04. Identifikasi Mekanisme Middleware](file:///d:/CetakDanom/docs/04_mekanisme_middleware.md) | Middleware proprietary `NCONN.pas` (Protokol 2P & Dynamic DLL Dispatching), enkripsi `NCrypt` (Blowfish & MD5), kompresi `NZip` (ZLibEx), sesi `NSession`, serta integrasi REST API Gateway WSO2. |
| **05** | [05. Inventaris Seluruh Form](file:///d:/CetakDanom/docs/05_inventaris_seluruh_form.md) | Rincian 21 form (5 Form Aplikasi Utama: Login, Utama, Konfigurasi Server, QuickReport, Updater; serta 16 Form Pustaka & Desainer). |
| **06** | [06. Inventaris Komponen Pihak Ketiga](file:///d:/CetakDanom/docs/06_inventaris_komponen_pihak_ketiga.md) | Analisis komponen VCL eksternal: FastReport (4 & 6.6.12), kbmMemTable v5.00, DCPcrypt, ZLibEx, Indy, RAWPrinter, DevExpress, NextSuite, JVCL, dan BvComponents. |
| **07** | [07. Peta Ketergantungan Antar Modul](file:///d:/CetakDanom/docs/07_dependency_map.md) | Diagram dependensi antar-proyek, graf ketergantungan antar-unit Pascal (`uses`), serta daftar integrasi Win32 API native. |
| **08** | [08. Aturan Bisnis Utama (Business Rules)](file:///d:/CetakDanom/docs/08_business_rules.md) | Logika bisnis autentikasi, proteksi cetak ganda, aturan tanda petik NIK pada BNBA CSV, susunan payload QR Code kuitansi, rumus CDS BLT, dan syarat program Sembako. |
| **09** | [09. Analisis Risiko Migrasi ke Delphi Modern](file:///d:/CetakDanom/docs/09_risiko_migrasi_delphi_modern.md) | Evaluasi migrasi ke Delphi 11/12 (isu Unicode UTF-16, file C `.obj` 32-bit, DFM 88 MB, lisensi kbmMemTable, dan transisi ke FireDAC). |
| **10** | [10. Analisis Risiko Migrasi ke C# .NET](file:///d:/CetakDanom/docs/10_risiko_migrasi_csharp_dotnet.md) | Evaluasi migrasi ke C# .NET 8/9 (WPF/Avalonia, Dapper SQL Server, penggantian kbmMemTable dengan SQLite, QuestPDF, dan WinSpool P/Invoke passbook). |
| **11** | [11. Analisis Risiko Migrasi ke Tauri](file:///d:/CetakDanom/docs/11_risiko_migrasi_tauri.md) | Evaluasi migrasi ke Tauri v2 + Rust (presisi cetak web vs headless PDF, penanganan passbook ESC/P via FFI, konektivitas database, dan learning curve Rust). |
| **12** | [12. Rencana Implementasi & Timeline Migrasi C# + Go](file:///d:/CetakDanom/docs/12_rencana_migrasi_dan_timeline_csharp_go.md) | Panduan langkah demi langkah implementasi teknis, pemetaan fitur Delphi ke C# dan Go API, serta jadwal kerja (timeline 8 minggu). |
| **13** | [13. Matriks Traceability & Analisis Kesenjangan (Gap Analysis)](file:///d:/CetakDanom/docs/13_matriks_traceability_dan_gap_analysis.md) | Matriks pemetaan Form Delphi → Use Case → Go Endpoint → Stored Procedure, serta analisis gap kritis (Login, Danom, BNBA, CDS BLT, QR Code, Printing, Hak Akses). |
| **14** | [14. Analisis Teknis Binary & Reverse Engineering Middleware](file:///d:/CetakDanom/docs/14_analisis_middleware_naszsvr_dan_srvconf.md) | Dekompilasi & reverse engineering biner `NasZSvr.exe` (ASPack 2.12, Windows Service `NasSvc`, Indy 10 port 1973, kueri auth `TPETUGAS`, secret seed Blowfish harian) dan `SrvConf.exe` (GUI admin, enkripsi `NasSrv.conf` key 39-char, kontrol SCM `net start/stop`). |
| **15** | [15. Analisis Biner CDS.exe & Integrasi WSO2](file:///d:/CetakDanom/docs/15_analisis_aplikasi_cds_dan_integrasi_wso2.md) | Dekompilasi & reverse engineering biner `CDS.exe` (ASPack 2.12, OEP `0x006BF79C`, Cetak Danom Satuan), dekonstruksi endpoint WSO2 Gateway `http://10.33.41.252:8280/cds_blt/getData2`, serta strategi penggantian ke Go API modern. |
| **16** | [Spesifikasi Kontrak API (api-contract.md)](file:///d:/CetakDanom/docs/api-contract.md) | Kontrak API final untuk seluruh endpoint: URL, Method, Auth, Request/Response DTO, Validasi, Error, Stored Procedure, dan Business Rule. |
| **17** | [OpenAPI 3.0.3 YAML Specification (openapi.yaml)](file:///d:/CetakDanom/docs/openapi.yaml) | Spesifikasi standar Swagger 3.0 / OpenAPI 3.0.3 machine-readable untuk integrasi generator klien/server. |
| **18** | [Katalog Data Transfer Object (dto-catalog.md)](file:///d:/CetakDanom/docs/dto-catalog.md) | Definisi lengkap seluruh struktur DTO Request & Response beserta pemetaan tipe data C#, Go, Delphi, dan SQL Server. |
| **19** | [Aturan Validasi Lengkap (validation-rules.md)](file:///d:/CetakDanom/docs/validation-rules.md) | Aturan validasi field, kontrak payload barcode pipa inter-aplikasi, aturan backtick CSV Excel, hashing MD5 raw, dan katalog kode error standar. |
| **20** | [Arsitektur Prototipe Desktop C# (prototype_architecture.md)](file:///d:/CetakDanom/docs/prototype_architecture.md) | Arsitektur solusi C# .NET 8 WPF, pemisahan lapisan (Domain, Application, Infrastructure, Desktop), pola MVVM, dan strategi abstraksi Mock Repository. |
| **21** | [Status Implementasi Fitur (feature_implementation_status.md)](file:///d:/CetakDanom/docs/feature_implementation_status.md) | Status rinci implementasi fitur prototipe: Login, Dashboard, Cascading Wilayah, Grid Danom, Ekspor BNBA, Pratinjau Dokumen, dan QR Code. |
| **22** | [Pemetaan Aturan Bisnis (business_rule_mapping.md)](file:///d:/CetakDanom/docs/business_rule_mapping.md) | Matriks keterlacakan aturan bisnis Delphi warisan terhadap C# WPF: Preservasi backtick BNBA, aturan 20 baris Danom, dan delimitasi pipa QR Code. |
| **23** | [Spesifikasi Data Tiruan (mock_data_specification.md)](file:///d:/CetakDanom/docs/mock_data_specification.md) | Dokumentasi 100% data sintetis tanpa PII produksi: Akun demo, program bansos (BST/PKH/Sembako), hierarki wilayah Jabar/DKI, dan 55 data KPM tiruan. |
| **24** | [Analisis Kesenjangan & Batasan (known_gaps.md)](file:///d:/CetakDanom/docs/known_gaps.md) | Kesenjangan teknis Fase 1: Isolasi NCONN, simulasi autentikasi, bypass printer fisik passbook ESC/P, dan rencana transisi ke database terenkripsi SQLite. |
| **25** | [Laporan Kompilasi & Pengujian Unit (build_and_test_report.md)](file:///d:/CetakDanom/docs/build_and_test_report.md) | Laporan resmi kompilasi .NET 8.0 SDK (0 Error, 0 Warning) dan hasil eksekusi 21 pengujian unit otomatis xUnit (100% Passed). |
| **26** | [Rekomendasi Tahap Lanjutan (next_phase_recommendations.md)](file:///d:/CetakDanom/docs/next_phase_recommendations.md) | Panduan teknis Fase 2: Opsi integrasi REST API Go vs driver NCONN, database lokal SQLite terenkripsi, driver WinSpool passbook, dan roadmap implementasi. |

---

## 2. Matriks Perbandingan Tiga Jalur Modernisasi

| Parameter Evaluasi | Opsi A: Delphi Modern (11/12) | Opsi B: C# (.NET 8/9) | Opsi C: Tauri (Rust + Web) |
| :--- | :---: | :---: | :---: |
| **Keselarasan Ekosistem PT Pos** | Sedang | **Sangat Tinggi (Enterprise Win)** | Sedang |
| **Kematangan Akses SQL Server** | Tinggi (FireDAC) | **Sangat Tinggi (Dapper / SqlClient)** | Sedang (ODBC / Tiberius) |
| **Dukungan Cetak Presisi (Danom)** | **Sangat Tinggi (FastReport VCL)** | **Tinggi (QuestPDF / FastReport .NET)** | Rendah s.d Sedang (Web Print bermasalah) |
| **Dukungan Printer Passbook / RAW** | Tinggi (Native Spooler) | **Tinggi (WinSpool P/Invoke)** | Sedang (Perlu C-FFI Rust) |
| **Keandalan Offline / Local Cache** | Sedang (TFDMemTable) | **Sangat Tinggi (SQLite / EF Core)** | Tinggi (Rusqlite) |
| **Ketersediaan SDM Developer** | Rendah (Komunitas menyusut) | **Sangat Tinggi (Melimpah)** | Rendah (Rust langka & mahal) |
| **Modernitas Antarmuka (UI/UX)** | Sedang (VCL Style) | **Tinggi (WPF / Fluent / Avalonia)** | **Sangat Tinggi (Modern Web/Tailwind)** |
| **Ukuran Biner & Resource RAM** | Sangat Ringan (~15 MB) | Ringan (~30-50 MB Native AOT) | **Sangat Ringan (<15 MB)** |
| **Estimasi Beban Kerja Migrasi** | ~30 Hari Kerja | ~40 Hari Kerja | ~55 Hari Kerja |
| **Tingkat Risiko Proyek Keseluruhan**| **Sedang** | **Paling Rendah (Recommended)** | **Tinggi** |

---

## 3. Rekomendasi Strategis Modernisasi

### Rekomendasi Utama: Migrasi ke C# (.NET 8/9)
Direkomendasikan sebagai pilihan strategis jangka panjang:
1. **Arsitektur Target**: **WPF / Avalonia UI** dengan arsitektur MVVM bersih.
2. **Database & API**: **Dapper** langsung memanggil Stored Procedure SQL Server yang sudah ada, dan `HttpClient` untuk gateway WSO2 CDS BLT.
3. **Penyimpanan Lokal**: Menggantikan berkas `.POS` flat-file dengan basis data lokal **SQLite (terenkripsi)**.
4. **Pencetakan**: Menggunakan **QuestPDF** untuk menghasilkan berkas PDF kuitansi ber-QR Code dengan tata letak presisi tinggi, dan kelas pembantu **`RawPrinterHelper`** untuk printer passbook IBM 9068A / Epson LQ-300.
5. **Ekosistem SDM**: Menjamin kemudahan pemeliharaan (*maintainability*) oleh tim pengembang internal korporat PT Pos Indonesia.

### Opsi Taktis Alternatif: Delphi 12 Athens
Jika terdapat batasan waktu yang sangat ketat (*urgent deployment*) dan organisasi ingin mempertahankan investasi template FastReport yang sudah ada:
- Lakukan refactoring pembersihan DFM 88 MB (pindahkan template ke file eksternal `.fr3`).
- Alihkan kompresi ke `System.ZLib` dan ganti `kbmMemTable` ke `TFDMemTable`.
- Perbaiki seluruh penanganan pointer buffer `AnsiString` &rarr; `TBytes`.

