using System.Collections.ObjectModel;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

/// <summary>
/// ViewModel untuk Menu 1: Unduh Danom
/// Menangani alur pemilihan parameter hierarkis:
/// 1. Jenis Bansos ("NASIONAL", "LOKAL", "INSTANSI/LEMBAGA")
/// 2. Project / Nama Bantuan (refProject_NAS, refProject_KOTAKAB, refProject_INS)
/// 3. Tahap Penyaluran (TTAHAP_NAS, TTAHAP_KOTAKAB, TTAHAP_INS filter by id_project)
/// 4. Hierarki Wilayah Berjenjang: Kabupaten1 -> Kecamatan1 (filter KD_KABUPATEN) -> Desa1 (filter KD_KECAMATAN)
/// </summary>
public class UnduhDanomViewModel : ViewModelBase
{
    private readonly IWilayahRepository _wilayahRepo;
    private readonly IDanomRepository _danomRepo;
    private readonly IAuthenticationService _authService;

    // 1. Jenis Bansos (Hardcoded)
    private ObservableCollection<string> _jenisBansosList = new() { "NASIONAL", "LOKAL", "INSTANSI/LEMBAGA" };
    private string _selectedJenisBansos = "NASIONAL";

    // 2. Project / Nama Bantuan
    private ObservableCollection<LayananBansos> _projectList = new();
    private LayananBansos? _selectedProject;

    // 3. Tahap Penyaluran
    private ObservableCollection<TahapBansosItem> _tahapList = new();
    private TahapBansosItem? _selectedTahap;

    // 4. Hierarki Wilayah (Kabupaten -> Kecamatan -> Desa)
    private ObservableCollection<Wilayah> _kabupatenList = new();
    private Wilayah? _selectedKabupaten;

    private ObservableCollection<Wilayah> _kecamatanList = new();
    private Wilayah? _selectedKecamatan;

    private ObservableCollection<Wilayah> _desaList = new();
    private Wilayah? _selectedDesa;

    // Execution & Progress State
    private bool _isDownloading;
    private int _downloadProgress;
    private string _progressStatusText = "Siap melakukan penarikan data.";
    private ObservableCollection<string> _logLines = new();
    private bool _isDownloadCompleted;
    private int _downloadedCount;
    private decimal _downloadedNominal;

    // Properties
    public ObservableCollection<string> JenisBansosList
    {
        get => _jenisBansosList;
        set => SetProperty(ref _jenisBansosList, value);
    }

    public string SelectedJenisBansos
    {
        get => _selectedJenisBansos;
        set
        {
            if (SetProperty(ref _selectedJenisBansos, value))
            {
                _ = OnJenisBansosChangedAsync(value);
            }
        }
    }

    public ObservableCollection<LayananBansos> ProjectList
    {
        get => _projectList;
        set => SetProperty(ref _projectList, value);
    }

    public LayananBansos? SelectedProject
    {
        get => _selectedProject;
        set
        {
            if (SetProperty(ref _selectedProject, value))
            {
                _ = OnProjectChangedAsync(value);
            }
        }
    }

    public ObservableCollection<TahapBansosItem> TahapList
    {
        get => _tahapList;
        set => SetProperty(ref _tahapList, value);
    }

    public TahapBansosItem? SelectedTahap
    {
        get => _selectedTahap;
        set => SetProperty(ref _selectedTahap, value);
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

    public ObservableCollection<Wilayah> DesaList
    {
        get => _desaList;
        set => SetProperty(ref _desaList, value);
    }

    public Wilayah? SelectedDesa
    {
        get => _selectedDesa;
        set => SetProperty(ref _selectedDesa, value);
    }

    // Compat wrappers
    public ObservableCollection<LayananBansos> LayananList
    {
        get => ProjectList;
        set => ProjectList = value;
    }

    public LayananBansos? SelectedLayanan
    {
        get => SelectedProject;
        set => SelectedProject = value;
    }

    public ObservableCollection<Wilayah> KelurahanList
    {
        get => DesaList;
        set => DesaList = value;
    }

    public Wilayah? SelectedKelurahan
    {
        get => SelectedDesa;
        set => SelectedDesa = value;
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
        if (KabupatenList.Count == 0)
        {
            var kabs = await _wilayahRepo.GetAllKabupatenAsync();
            KabupatenList = new ObservableCollection<Wilayah>(kabs);
            SelectedKabupaten = KabupatenList.FirstOrDefault();
        }

        if (ProjectList.Count == 0)
        {
            await OnJenisBansosChangedAsync(SelectedJenisBansos);
        }
    }

    private async Task OnJenisBansosChangedAsync(string? jenis)
    {
        ProjectList.Clear();
        TahapList.Clear();
        SelectedProject = null;
        SelectedTahap = null;

        if (!string.IsNullOrEmpty(jenis))
        {
            var projects = await _wilayahRepo.GetProjectsAsync(jenis);
            ProjectList = new ObservableCollection<LayananBansos>(projects);
            SelectedProject = ProjectList.FirstOrDefault();
        }
    }

    private async Task OnProjectChangedAsync(LayananBansos? proj)
    {
        TahapList.Clear();
        SelectedTahap = null;

        if (proj != null && !string.IsNullOrEmpty(proj.Kode))
        {
            var tahaps = await _wilayahRepo.GetTahapAsync(SelectedJenisBansos, proj.Kode);
            TahapList = new ObservableCollection<TahapBansosItem>(tahaps);
            SelectedTahap = TahapList.FirstOrDefault();
        }
    }

    private async void OnKabupatenChanged(Wilayah? kab)
    {
        KecamatanList.Clear();
        DesaList.Clear();
        SelectedKecamatan = null;
        SelectedDesa = null;

        if (kab != null && !string.IsNullOrEmpty(kab.Kode))
        {
            var rawKode = kab.Kode.Split(' ')[0].Trim();
            var kecs = await _wilayahRepo.GetKecamatanByKabupatenAsync(rawKode);
            KecamatanList = new ObservableCollection<Wilayah>(kecs);
            SelectedKecamatan = KecamatanList.FirstOrDefault();
        }
    }

    private async void OnKecamatanChanged(Wilayah? kec)
    {
        DesaList.Clear();
        SelectedDesa = null;

        if (kec != null && !string.IsNullOrEmpty(kec.Kode))
        {
            var rawKecKode = kec.Kode.Split(' ')[0].Trim();
            var rawKabKode = SelectedKabupaten?.Kode.Split(' ')[0].Trim() ?? "";
            var desas = await _wilayahRepo.GetDesaByKecamatanAsync(rawKecKode, rawKabKode);
            DesaList = new ObservableCollection<Wilayah>(desas);
            SelectedDesa = DesaList.FirstOrDefault();
        }
    }

    private async Task ExecuteTarikDataAsync()
    {
        if (SelectedDesa == null)
        {
            ProgressStatusText = "Pilih Kelurahan/Desa terlebih dahulu!";
            return;
        }

        IsDownloading = true;
        IsDownloadCompleted = false;
        DownloadProgress = 0;
        LogLines.Clear();

        void AddLog(string msg) => LogLines.Add($"[{DateTime.Now:HH:mm:ss}] {msg}");

        var rawDesaKode = SelectedDesa.Kode.Split(' ')[0].Trim();
        var rawKecKode = SelectedKecamatan?.Kode.Split(' ')[0].Trim() ?? "";
        var rawKabKode = SelectedKabupaten?.Kode.Split(' ')[0].Trim() ?? "";
        var batchTahap = SelectedTahap?.IdTahap ?? "1";
        var projectKode = SelectedProject?.Kode ?? "SPK1";

        AddLog($"Memulai proses penarikan data Danom dari basis data DB_BLT...");
        AddLog($"Jenis Bansos: {SelectedJenisBansos} | Project: {SelectedProject?.Nama}");
        AddLog($"Tahap: {SelectedTahap?.Display} | Desa/Kel: {SelectedDesa.Nama}");
        AddLog($"Kecamatan: {SelectedKecamatan?.Nama} | Kabupaten: {SelectedKabupaten?.Nama}");

        DownloadProgress = 25;
        ProgressStatusText = "Menghubungi Go REST API (SQL Server DB_BLT)...";
        await Task.Delay(200);

        DownloadProgress = 50;
        ProgressStatusText = "Mengeksekusi query nominatif KPM...";

        var filter = new DanomFilterRequest
        {
            LayananKode = projectKode,
            Tahap = batchTahap,
            KabupatenKode = rawKabKode,
            KecamatanKode = rawKecKode,
            KelurahanKode = rawDesaKode
        };

        try
        {
            var data = await _danomRepo.GetPenerimaListAsync(filter);
            data ??= new List<PenerimaBansos>();

            DownloadedCount = data.Count;
            DownloadedNominal = data.Count > 0 ? data.Sum(d => d.Nominal) : 0m;

            DownloadProgress = 100;
            if (DownloadedCount == 0)
            {
                ProgressStatusText = "Tidak ada data penerima (0 KPM) untuk parameter yang dipilih.";
                AddLog($"DATA TIDAK ADA: Tidak ditemukan KPM pada basis data DB_BLT untuk Desa/Kel {SelectedDesa.Nama} ({rawDesaKode}), Batch {batchTahap}.");
                AddLog("Status: SELESAI (0 KPM).");
                IsDownloadCompleted = false;
            }
            else
            {
                ProgressStatusText = $"Sukses! Berhasil mengunduh {DownloadedCount} data KPM.";
                AddLog($"Berhasil mengunduh {DownloadedCount} record KPM.");
                AddLog($"Total Nominal: Rp {DownloadedNominal:N0}");
                AddLog("Data tersimpan ke memori & penyimpanan lokal (Mode Cetak Danom siap).");
                AddLog($"Status: SELESAI ({DownloadedCount} KPM).");
                IsDownloadCompleted = true;
            }
        }
        catch (Exception ex)
        {
            DownloadProgress = 0;
            ProgressStatusText = $"Gagal mengunduh: {ex.Message}";
            AddLog($"ERROR: {ex.Message}");
        }
        finally
        {
            IsDownloading = false;
        }
    }
}
