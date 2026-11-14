# Arsitektur Prototipe Desktop C# WPF (Fase 1) - CetakDanom FDPOS

Dokumen ini mendokumentasikan keputusan arsitektur, struktur proyek, pola desain (*design pattern*), dan strategi abstraksi data yang diimplementasikan pada **Prototipe Desktop C# .NET 8.0 LTS** untuk memodernisasi aplikasi warisan (*legacy*) CetakDanom Delphi.

---

## 1. Ringkasan Eksekutif & Prinsip Desain

Prototipe Fase 1 dibangun dengan fokus memvalidasi:
1. **Kelayakan UI Desktop Modern**: Antarmuka berbasis **WPF (.NET 8.0 LTS)** dengan palet korporat PT Pos Indonesia (oranye `#FF6600`, navy `#0F172A`, dan slate `#F1F5F9`), tata letak responsif, serta pemisahan murni antara tampilan dan logika.
2. **Keterpeliharaan Kode (*Maintainability*)**: Menggunakan arsitektur berlapis (*Layered Architecture*) yang mematuhi prinsip SOLID, *Clean Architecture*, dan *Inversion of Control* (IoC).
3. **Pemisahan Logika Bisnis (MVVM)**: Tidak ada aturan bisnis yang ditulis di *code-behind* XAML (`.xaml.cs`). Seluruh state, filter, kalkulasi nominal, dan orkestrasi perintah dikelola di *ViewModel* melalui *Data Binding* dan *RelayCommand*.
4. **Isolasi Middleware NCONN**: Middleware eksisting NCONN (protokol biner 2P) dan database SQL Server produksi sengaja **diabstraksikan dan disimulasikan** (*Mock Repository Pattern*). Hal ini mencegah ketergantungan dini sebelum mekanisme middleware produksi disetujui.

---

## 2. Struktur Solusi (*Solution Structure*)

Solusi Visual Studio `CetakDanom.sln` tersusun atas 5 proyek modular:

```text
CetakDanom.sln
│
├── src/
│   ├── CetakDanom.Domain/           [Class Library - net8.0]
│   │   ├── Entities/                (Petugas, Wilayah, LayananBansos, PenerimaBansos)
│   │   ├── Models/                  (BnbaRecord)
│   │   └── Rules/                   (QrPayloadRules)
│   │
│   ├── CetakDanom.Application/      [Class Library - net8.0]
│   │   ├── DTOs/                    (AuthDTOs, DanomDTOs, ExportDTOs, PrintDTOs)
│   │   └── Interfaces/              (IAuthenticationService, IWilayahRepository, 
│   │                                 IDanomRepository, IExportService, IPrintService, IQrCodeService)
│   │
│   ├── CetakDanom.Infrastructure/   [Class Library - net8.0]
│   │   ├── Mock/                    (MockAuthenticationService, MockWilayahRepository, MockDanomRepository)
│   │   ├── Export/                  (BnbaCsvExportService)
│   │   └── Printing/                (QrCodeService, MockPrintService)
│   │
│   └── CetakDanom.Desktop/          [WPF Application - net8.0-windows]
│       ├── Views/                   (LoginView, MainView, DashboardHomeView, DanomView, PrintPreviewView)
│       ├── ViewModels/              (ViewModelBase, LoginViewModel, MainViewModel, 
│       │                             DashboardHomeViewModel, DanomViewModel, PrintPreviewViewModel)
│       ├── Converters/              (ByteArrayToBitmapImageConverter, StatusToBrushConverter, dll.)
│       └── App.xaml / App.xaml.cs   (IoC ServiceContainer Setup & Application Lifecycle)
│
└── tests/
    └── CetakDanom.UnitTests/        [xUnit Project - net8.0]
        ├── QrPayloadTests.cs
        ├── BnbaExportTests.cs
        ├── WilayahAndAuthTests.cs
        └── DanomRepositoryTests.cs
```

---

## 3. Diagram Ketergantungan Antar-Lapisan (*Layer Dependency*)

```mermaid
graph TD
    Desktop[CetakDanom.Desktop (WPF UI)] --> Application[CetakDanom.Application (Interfaces & DTOs)]
    Desktop --> Domain[CetakDanom.Domain (Entities & Rules)]
    Desktop --> Infrastructure[CetakDanom.Infrastructure (Mock & Services)]
    Infrastructure --> Application
    Infrastructure --> Domain
    Application --> Domain
    UnitTests[CetakDanom.UnitTests (xUnit)] --> Domain
    UnitTests --> Application
    UnitTests --> Infrastructure
```

* **Domain**: Lapisan inti tanpa dependensi luar (*pure C#*). Menyimpan entitas bisnis (`PenerimaBansos`, `Petugas`, `Wilayah`), aturan kontrak QR Code (`QrPayloadRules`), dan skema 14 kolom BNBA (`BnbaRecord`).
* **Application**: Mendefinisikan kontrak interface (`IDanomRepository`, `IAuthenticationService`, dll.) dan objek transfer data (DTO).
* **Infrastructure**: Mengimplementasikan kontrak aplikasi. Pada Fase 1, lapisan ini memuat `Mock*` repository sintetis, engine ekspor CSV BNBA, generator QRCoder, dan document builder.
* **Desktop**: Presenter visual berbasis XAML dan ViewModel MVVM yang dirangkai melalui *Microsoft.Extensions.DependencyInjection*.

---

## 4. Pola Abstraksi Data (*Data Source Decoupling*)

Untuk memastikan aplikasi desktop dapat dialihkan dari mode prototipe (Mock) ke mode produksi tanpa menulis ulang UI atau ViewModel, seluruh akses data diproteksi oleh interface:

| Abstraksi Interface | Implementasi Fase 1 (Mock) | Rencana Implementasi Produksi (Fase Selanjutnya) |
| :--- | :--- | :--- |
| `IAuthenticationService` | `MockAuthenticationService` (Akun demo: demo, petugas01, supervisor) | `ApiAuthenticationService` (Panggilan REST API `/api/v1/auth/login` atau adapter SIKAP SP) |
| `IWilayahRepository` | `MockWilayahRepository` (Hierarki Jabar/DKI statis in-memory) | `ApiWilayahRepository` (Panggilan `/api/v1/wilayah/kelurahan` via cache SQLite lokal) |
| `IDanomRepository` | `MockDanomRepository` (Dataset KPM sintetis dengan pencarian/filter) | `ApiDanomRepository` (Panggilan Go API / query lokal terenkripsi pengganti `.POS`) |
| `IExportService` | `BnbaCsvExportService` (14 kolom, `;`, backtick NIK/Danom) | `BnbaCsvExportService` (Tetap sama, format telah terbukti valid dan terverifikasi unit test) |
| `IQrCodeService` | `QrCodeService` (QRCoder ECC Level M, 6 segmen terpisah pipa) | `QrCodeService` (Tetap sama, mematuhi kontrak scanner loket) |
| `IPrintService` | `MockPrintService` (Monospace paper preview, aturan 20 baris) | `DirectRawPrintService` (P/Invoke `winspool.drv` ESC/P untuk Passbook IBM/Epson) |

---

## 5. Konfigurasi Dependency Injection (`App.xaml.cs`)

Pengikatan komponen dilakukan saat inisialisasi aplikasi (`OnStartup`):

```csharp
private void ConfigureServices(IServiceCollection services)
{
    // Abstraksi Data (Singleton Mock in-memory)
    services.AddSingleton<IAuthenticationService, MockAuthenticationService>();
    services.AddSingleton<IWilayahRepository, MockWilayahRepository>();
    services.AddSingleton<IDanomRepository, MockDanomRepository>();
    services.AddTransient<IExportService, BnbaCsvExportService>();
    services.AddSingleton<IQrCodeService, QrCodeService>();
    services.AddTransient<IPrintService, MockPrintService>();

    // ViewModels
    services.AddTransient<LoginViewModel>();
    services.AddTransient<DashboardHomeViewModel>();
    services.AddTransient<DanomViewModel>();
    services.AddTransient<PrintPreviewViewModel>();
    services.AddTransient<MainViewModel>();

    // Windows
    services.AddTransient<LoginView>();
    services.AddTransient<MainView>();
}
```

Ketika aplikasi beralih ke REST API Go atau SQL Server, pengembang hanya perlu mengganti baris registrasi:
```csharp
// Contoh transisi produksi kelak:
services.AddSingleton<IDanomRepository, RestApiDanomRepository>();
```
Seluruh tampilan UI, binding tabel, tombol cetak, dan ViewModel tidak memerlukan perubahan sebaris pun.
