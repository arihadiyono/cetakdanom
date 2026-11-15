using System.Collections.ObjectModel;
using System.Windows.Input;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Desktop.ViewModels;

/// <summary>
/// ViewModel untuk Menu 4: Cetak Danom Satuan
/// Meniru pola dan antarmuka aplikasi CDS.exe (Cetak Danom Satuan):
/// Inquiry NIK, menampilkan data KPM, pratinjau bukti terima, dan pencetakan kuitansi loket.
/// </summary>
public class CetakDanomSatuanViewModel : ViewModelBase
{
    private readonly ICdsBltService _cdsService;
    private readonly IAuthenticationService _authService;

    private string _inputNik = "3201012304850001";
    private bool _isLoading;
    private string _statusMessage = "Masukkan 16 digit NIK lalu klik 'Ambil Data'.";
    private bool _hasData;

    // Display Fields (Identik dengan form TForm1 pada CDS.exe)
    private string _labelNama = "-";
    private string _labelNik = "-";
    private string _labelBsu = "-";
    private string _labelNoVoucher = "-";
    private string _labelNmPerusahaan = "-";
    private string _labelAlamatPerusahaan = "-";
    private string _labelHeader = "-";
    private string _labelProv = "-";
    private string _labelKab = "-";
    private string _labelKec = "-";
    private string _labelKel = "-";

    private CdsBltRecipientDto? _currentRecipient;
    private ObservableCollection<CdsBltRecipientDto> _gridDataBt = new();

    public string InputNik
    {
        get => _inputNik;
        set => SetProperty(ref _inputNik, value);
    }

    public bool IsLoading
    {
        get => _isLoading;
        set => SetProperty(ref _isLoading, value);
    }

    public string StatusMessage
    {
        get => _statusMessage;
        set => SetProperty(ref _statusMessage, value);
    }

    public bool HasData
    {
        get => _hasData;
        set => SetProperty(ref _hasData, value);
    }

    public string LabelNama
    {
        get => _labelNama;
        set => SetProperty(ref _labelNama, value);
    }

    public string LabelNik
    {
        get => _labelNik;
        set => SetProperty(ref _labelNik, value);
    }

    public string LabelBsu
    {
        get => _labelBsu;
        set => SetProperty(ref _labelBsu, value);
    }

    public string LabelNoVoucher
    {
        get => _labelNoVoucher;
        set => SetProperty(ref _labelNoVoucher, value);
    }

    public string LabelNmPerusahaan
    {
        get => _labelNmPerusahaan;
        set => SetProperty(ref _labelNmPerusahaan, value);
    }

    public string LabelAlamatPerusahaan
    {
        get => _labelAlamatPerusahaan;
        set => SetProperty(ref _labelAlamatPerusahaan, value);
    }

    public string LabelHeader
    {
        get => _labelHeader;
        set => SetProperty(ref _labelHeader, value);
    }

    public string LabelProv
    {
        get => _labelProv;
        set => SetProperty(ref _labelProv, value);
    }

    public string LabelKab
    {
        get => _labelKab;
        set => SetProperty(ref _labelKab, value);
    }

    public string LabelKec
    {
        get => _labelKec;
        set => SetProperty(ref _labelKec, value);
    }

    public string LabelKel
    {
        get => _labelKel;
        set => SetProperty(ref _labelKel, value);
    }

    public ObservableCollection<CdsBltRecipientDto> GridDataBt
    {
        get => _gridDataBt;
        set => SetProperty(ref _gridDataBt, value);
    }

    public ICommand AmbilDataCommand { get; }
    public ICommand ResetCommand { get; }
    public ICommand PreviewBtCommand { get; }
    public ICommand CetakBtCommand { get; }

    public event Action<PrintPreviewDocument>? RequestPrintPreview;

    public CetakDanomSatuanViewModel(
        ICdsBltService cdsService,
        IAuthenticationService authService)
    {
        _cdsService = cdsService;
        _authService = authService;

        AmbilDataCommand = new RelayCommand(async () => await ExecuteAmbilDataAsync(), () => !IsLoading);
        ResetCommand = new RelayCommand(ExecuteReset);
        PreviewBtCommand = new RelayCommand(async () => await ExecutePreviewBtAsync(), () => HasData && _currentRecipient != null);
        CetakBtCommand = new RelayCommand(async () => await ExecuteCetakBtAsync(), () => HasData && _currentRecipient != null);
    }

    public async Task InitializeAsync()
    {
        // Default state
        ExecuteReset();
        InputNik = "3201012304850001";
        await Task.CompletedTask;
    }

    private async Task ExecuteAmbilDataAsync()
    {
        if (string.IsNullOrWhiteSpace(InputNik))
        {
            StatusMessage = "NIK Tidak Boleh Kosong!!";
            return;
        }

        IsLoading = true;
        StatusMessage = $"Menghubungi layanan CDS BLT untuk NIK: {InputNik.Trim()}...";

        await Task.Delay(300); // Simulasi latensi jaringan HTTP
        var recipient = await _cdsService.InquiryNikAsync(InputNik.Trim());

        if (recipient != null && recipient.IdResponse == "000")
        {
            _currentRecipient = recipient;
            LabelNama = recipient.Nama;
            LabelNik = recipient.Nik;
            LabelBsu = $"Rp {recipient.Nominal:N0}";
            LabelNoVoucher = recipient.NoVoucher;
            LabelNmPerusahaan = recipient.NamaPerusahaan;
            LabelAlamatPerusahaan = recipient.AlamatPerusahaan;
            LabelHeader = recipient.HeaderDanom;
            LabelProv = recipient.NmPropDtks;
            LabelKab = recipient.NmKabDtks;
            LabelKec = recipient.NmKecDtks;
            LabelKel = recipient.NmDesaDtks;

            GridDataBt = new ObservableCollection<CdsBltRecipientDto> { recipient };
            HasData = true;
            StatusMessage = $"Data KPM berhasil ditemukan ({recipient.Nama}). Tombol Preview dan Cetak aktif.";
        }
        else
        {
            ExecuteReset();
            StatusMessage = "Data Tidak Ada / Gagal Mendapatkan Respon!!";
        }

        IsLoading = false;
    }

    private void ExecuteReset()
    {
        _currentRecipient = null;
        GridDataBt.Clear();
        HasData = false;
        LabelNama = "-";
        LabelNik = "-";
        LabelBsu = "-";
        LabelNoVoucher = "-";
        LabelNmPerusahaan = "-";
        LabelAlamatPerusahaan = "-";
        LabelHeader = "-";
        LabelProv = "-";
        LabelKab = "-";
        LabelKec = "-";
        LabelKel = "-";
        StatusMessage = "Silakan masukkan NIK KPM penerima bantuan.";
    }

    private async Task ExecutePreviewBtAsync()
    {
        if (_currentRecipient == null) return;

        var doc = await _cdsService.PrepareKuitansiCdsPrintPreviewAsync(
            _currentRecipient,
            _authService.CurrentPetugas);

        RequestPrintPreview?.Invoke(doc);
    }

    private async Task ExecuteCetakBtAsync()
    {
        if (_currentRecipient == null) return;

        await Task.Delay(200);
        StatusMessage = $"Mencetak Kuitansi Tanda Terima ({_currentRecipient.Nama}) ke printer loket pos...";
    }
}
