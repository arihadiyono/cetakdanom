using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.DTOs;

public enum DocumentType
{
    DaftarNominatif,
    BuktiTerimaKuitansi,
    SuratPernyataan,
    SuratPemberitahuan,
    KuitansiCds
}

public class PrintPreviewDocument
{
    public DocumentType DocType { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Subtitle { get; set; } = string.Empty;
    public string HeaderInfo { get; set; } = string.Empty;
    public IReadOnlyList<PenerimaBansos> Records { get; set; } = Array.Empty<PenerimaBansos>();
    public string FormattedContent { get; set; } = string.Empty;
    public string QrCodePayloadSample { get; set; } = string.Empty;
    public bool QrPayloadValid { get; set; }
    public string QrValidationMessage { get; set; } = string.Empty;
    public byte[]? QrCodeImagePngBytes { get; set; }
}
