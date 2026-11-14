using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.DTOs;

public class DanomFilterRequest
{
    public string? LayananKode { get; set; }
    public string? Tahap { get; set; }
    public string? ProvinsiKode { get; set; }
    public string? KabupatenKode { get; set; }
    public string? KecamatanKode { get; set; }
    public string? KelurahanKode { get; set; }
    public string? SearchTerm { get; set; } // Pencarian nama atau NIK
    public StatusCetak? StatusFilter { get; set; }
}

public class DanomSummaryDto
{
    public int TotalRecords { get; set; }
    public decimal TotalNominal { get; set; }
    public int SiapCetakCount { get; set; }
    public int SudahCetakCount { get; set; }

    public string TotalNominalFormatted =>
        TotalNominal.ToString("C0", new System.Globalization.CultureInfo("id-ID"));
}
