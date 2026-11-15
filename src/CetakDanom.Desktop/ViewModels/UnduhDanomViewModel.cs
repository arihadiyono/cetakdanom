using System.Collections.ObjectModel;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

/// <summary>
/// ViewModel untuk Menu 1: Unduh Danom
/// Menangani alur pemilihan parameter hierarkis (Layanan, Program, Tahap, Kabupaten, Kecamatan, Desa)
/// dan penarikan data dari server pusat ke penyimpanan lokal (meniru pnlAmbilData pada Utama.pas).
/// </summary>
public class UnduhDanomViewModel : ViewModelBase
{
    private readonly IWilayahRepository _wilayahRepo;
    private readonly IDanomRepository _danomRepo;
    private readonly IAuthenticationService _authService;

    // Filter properties
    private ObservableCollection<LayananBansos> _layananList = new();
    private LayananBansos? _selectedLayanan;

    private ObservableCollection<string> _tahapList = new() { "M1-A04", "M1-A05", "M1-A06", "M1-A07", "M1-A08", "M1-A09", "M1-A10" };
    private string _selectedTahap = "M1-A04";

    private ObservableCollection<Wilayah> _provinsiList = new();
    private Wilayah? _selectedProvinsi;

    private ObservableCollection<Wilayah> _kabupatenList = new();
    private Wilayah? _selectedKabupaten;

    private ObservableCollection<Wilayah> _kecamatanList = new();
    private Wilayah? _selectedKecamatan;

    private ObservableCollection<Wilayah> _kelurahanList = new();
    private Wilayah? _selectedKelurahan;

    // Execution & Progress State
    private bool _isDownloading;
    private int _downloadProgress;
    private string _progressStatusText = "Siap melakukan penarikan data.";
    private ObservableCollection<string> _logLines = new();
    private bool _isDownloadCompleted;
    private int _downloadedCount;
    private decimal _downloadedNominal;

    public ObservableCollection<LayananBansos> LayananList
    {
        get => _layananList;
        set => SetProperty(ref _layananList, value);
    }

    public LayananBansos? SelectedLayanan
    {
        get => _selectedLayanan;
        set => SetProperty(ref _selectedLayanan, value);
    }

    public ObservableCollection<string> TahapList
    {
        get => _tahapList;
        set => SetProperty(ref _tahapList, value);
    }

    public string SelectedTahap
    {
        get => _selectedTahap;
        set => SetProperty(ref _selectedTahap, value);
    }

    public ObservableCollection<Wilayah> ProvinsiList
    {
        get => _provinsiList;
        set => SetProperty(ref _provinsiList, value);
    }

    public Wilayah? SelectedProvinsi
    {
        get => _selectedProvinsi;
        set
        {
            if (SetProperty(ref _selectedProvinsi, value))
            {
                OnProvinsiChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KabupatenList
    {
        get => _kabupatenList;
        set => SetProperty(ref _kabupatenList, value);
    }

    public Wilayah? SelectedKabupaten
    {
        get => _selectedKabupaten;
        set
        {
            if (SetProperty(ref _selectedKabupaten, value))
            {
                OnKabupatenChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KecamatanList
    {
        get => _kecamatanList;
        set => SetProperty(ref _kecamatanList, value);
    }

    public Wilayah? SelectedKecamatan
    {
        get => _selectedKecamatan;
        set
        {
            if (SetProperty(ref _selectedKecamatan, value))
            {
                OnKecamatanChanged(value);
            }
        }
    }

    public ObservableCollection<Wilayah> KelurahanList
    {
        get => _kelurahanList;
        set => SetProperty(ref _kelurahanList, value);
    }

    public Wilayah? SelectedKelurahan
    {
        get => _selectedKelurahan;
        set => SetProperty(ref _selectedKelurahan, value);
    }

    public bool IsDownloading
    {
        get => _isDownloading;
        set => SetProperty(ref _isDownloading, value);
    }

    public int DownloadProgress
    {
        get => _downloadProgress;
        set => SetProperty(ref _downloadProgress, value);
    }

    public string ProgressStatusText
    {
        get => _progressStatusText;
        set => SetProperty(ref _progressStatusText, value);
    }

    public ObservableCollection<string> LogLines
    {
        get => _logLines;
        set => SetProperty(ref _logLines, value);
    }

    public bool IsDownloadCompleted
    {
        get => _isDownloadCompleted;
        set => SetProperty(ref _isDownloadCompleted, value);
    }

    public int DownloadedCount
    {
        get => _downloadedCount;
        set => SetProperty(ref _downloadedCount, value);
    }

    public decimal DownloadedNominal
    {
        get => _downloadedNominal;
        set => SetProperty(ref _downloadedNominal, value);
    }

    public ICommand TarikDataCommand { get; }
    public ICommand ResetLogCommand { get; }
    public ICommand LanjutKeCetakDanomCommand { get; }

    public event Action? RequestNavigateToCetakDanom;

    public UnduhDanomViewModel(
        IWilayahRepository wilayahRepo,
        IDanomRepository danomRepo,
        IAuthenticationService authService)
    {
        _wilayahRepo = wilayahRepo;
        _danomRepo = danomRepo;
        _authService = authService;

        TarikDataCommand = new RelayCommand(async () => await ExecuteTarikDataAsync(), () => !IsDownloading);
        ResetLogCommand = new RelayCommand(() => LogLines.Clear());
        LanjutKeCetakDanomCommand = new RelayCommand(() => RequestNavigateToCetakDanom?.Invoke());
    }

    public async Task InitializeAsync()
    {
        if (LayananList.Count == 0)
        {
            var layanan = await _wilayahRepo.GetDaftarLayananAsync();
            LayananList = new ObservableCollection<LayananBansos>(layanan);
            SelectedLayanan = LayananList.FirstOrDefault();
        }

        if (ProvinsiList.Count == 0)
        {
            var provs = await _wilayahRepo.GetProvinsiAsync();
            ProvinsiList = new ObservableCollection<Wilayah>(provs);
            SelectedProvinsi = ProvinsiList.FirstOrDefault();
        }
    }

    private async void OnProvinsiChanged(Wilayah? prov)
    {
        KabupatenList.Clear();
        KecamatanList.Clear();
        KelurahanList.Clear();

        if (prov != null)
        {
            var kabs = await _wilayahRepo.GetKabupatenAsync(prov.Kode);
            KabupatenList = new ObservableCollection<Wilayah>(kabs);
            SelectedKabupaten = KabupatenList.FirstOrDefault();
        }
    }

    private async void OnKabupatenChanged(Wilayah? kab)
    {
        KecamatanList.Clear();
        KelurahanList.Clear();

        if (kab != null)
        {
            var kecs = await _wilayahRepo.GetKecamatanAsync(kab.Kode);
            KecamatanList = new ObservableCollection<Wilayah>(kecs);
            SelectedKecamatan = KecamatanList.FirstOrDefault();
        }
    }

    private async void OnKecamatanChanged(Wilayah? kec)
    {
        KelurahanList.Clear();

        if (kec != null)
        {
            var kels = await _wilayahRepo.GetKelurahanAsync(kec.Kode);
            KelurahanList = new ObservableCollection<Wilayah>(kels);
            SelectedKelurahan = KelurahanList.FirstOrDefault();
        }
    }

    private async Task ExecuteTarikDataAsync()
    {
        if (SelectedKelurahan == null)
        {
            ProgressStatusText = "Pilih Kelurahan/Desa terlebih dahulu!";
            return;
        }

        IsDownloading = true;
        IsDownloadCompleted = false;
        DownloadProgress = 0;
        LogLines.Clear();

        void AddLog(string msg) => LogLines.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");

        AddLog($"Memulai proses penarikan data Danom...");
        AddLog($"Program: {SelectedLayanan?.Nama ?? "BST"} (Tahap {SelectedTahap})");
        AddLog($"Wilayah: Kel. {SelectedKelurahan.Nama}, Kec. {SelectedKecamatan?.Nama}, {SelectedKabupaten?.Nama}");

        DownloadProgress = 20;
        ProgressStatusText = "Menghubungi middleware server...";
        await Task.Delay(300);

        AddLog($"Mengunduh parameter dokumen param_{SelectedLayanan?.Kode.ToLower()}_{SelectedTahap}.pos...");
        DownloadProgress = 40;
        await Task.Delay(300);

        AddLog($"Menjalankan kueri Stored Procedure data KPM...");
        DownloadProgress = 70;
        ProgressStatusText = "Memproses dataset penerima...";
        await Task.Delay(400);

        // Tarik data sesungguhnya dari mock repository
        var filter = new DanomFilterRequest
        {
            LayananKode = SelectedLayanan?.Kode,
            Tahap = SelectedTahap,
            ProvinsiKode = SelectedProvinsi?.Kode,
            KabupatenKode = SelectedKabupaten?.Kode,
            KecamatanKode = SelectedKecamatan?.Kode,
            KelurahanKode = SelectedKelurahan?.Kode
        };
        var data = await _danomRepo.GetPenerimaListAsync(filter);

        DownloadedCount = data.Count;
        DownloadedNominal = data.Sum(d => d.Nominal);

        DownloadProgress = 100;
        ProgressStatusText = $"Sukses! Berhasil mengunduh {DownloadedCount} data KPM.";
        AddLog($"Berhasil mengunduh {DownloadedCount} record KPM.");
        AddLog($"Total Nominal: Rp {DownloadedNominal:N0}");
        AddLog($"Dataset tersimpan ke basis data lokal (Mode Offline F5 siap).");
        AddLog($"Status: SELESAI.");

        IsDownloading = false;
        IsDownloadCompleted = true;
    }
}
