using System.Windows.Input;
using CetakDanom.Application.DTOs;

namespace CetakDanom.Desktop.ViewModels;

public class PrintPreviewViewModel : ViewModelBase
{
    private PrintPreviewDocument? _document;
    private string _printFeedbackMessage = string.Empty;
    private bool _hasPrintFeedback;

    public PrintPreviewDocument? Document
    {
        get => _document;
        set
        {
            if (SetProperty(ref _document, value))
            {
                OnPropertyChanged(nameof(Title));
                OnPropertyChanged(nameof(Subtitle));
                OnPropertyChanged(nameof(HeaderInfo));
                OnPropertyChanged(nameof(FormattedContent));
                OnPropertyChanged(nameof(QrPayload));
                OnPropertyChanged(nameof(QrIsValid));
                OnPropertyChanged(nameof(QrValidationMessage));
                OnPropertyChanged(nameof(QrImageBytes));
                OnPropertyChanged(nameof(HasQrCode));
            }
        }
    }

    public string Title => Document?.Title ?? "Pratinjau Dokumen Cetak";
    public string Subtitle => Document?.Subtitle ?? string.Empty;
    public string HeaderInfo => Document?.HeaderInfo ?? string.Empty;
    public string FormattedContent => Document?.FormattedContent ?? string.Empty;
    public string QrPayload => Document?.QrCodePayloadSample ?? string.Empty;
    public bool QrIsValid => Document?.QrPayloadValid ?? false;
    public string QrValidationMessage => Document?.QrValidationMessage ?? string.Empty;
    public byte[]? QrImageBytes => Document?.QrCodeImagePngBytes;
    public bool HasQrCode => !string.IsNullOrWhiteSpace(QrPayload) && QrImageBytes != null;

    public string PrintFeedbackMessage
    {
        get => _printFeedbackMessage;
        set
        {
            SetProperty(ref _printFeedbackMessage, value);
            HasPrintFeedback = !string.IsNullOrWhiteSpace(value);
        }
    }

    public bool HasPrintFeedback
    {
        get => _hasPrintFeedback;
        set => SetProperty(ref _hasPrintFeedback, value);
    }

    public ICommand SimulatePrintCommand { get; }
    public ICommand BackCommand { get; }

    public event Action? RequestBack;

    public PrintPreviewViewModel()
    {
        SimulatePrintCommand = new RelayCommand(() =>
        {
            PrintFeedbackMessage = $"[SIMULASI CETAK LOKET] Perintah cetak '{Title}' berhasil dikirim ke antrean spooler printer. Dokumen siap diambil di baki printer.";
        });

        BackCommand = new RelayCommand(() =>
        {
            PrintFeedbackMessage = string.Empty;
            RequestBack?.Invoke();
        });
    }

    public void LoadDocument(PrintPreviewDocument doc)
    {
        PrintFeedbackMessage = string.Empty;
        Document = doc;
    }
}
