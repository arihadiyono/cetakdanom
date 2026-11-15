using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.DTOs;

/// <summary>
/// DTO untuk parameter surat pemberitahuan penerima bantuan sosial (menggantikan file param_xxx.pos).
/// Pada aplikasi Delphi lama:
/// Baris 1: Header / Judul Surat
/// Baris 2+: Isi / Klausul Teks Surat Pemberitahuan
/// </summary>
public class SuratParameterDto
{
    public string ProjectCode { get; set; } = string.Empty;
    public string Subfix { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string JudulSurat { get; set; } = string.Empty;
    public List<string> IsiTeksSurat { get; set; } = new();
    public string LogoFileName { get; set; } = "logo_perusahaan.jpg";
    public string LogoInstansiFileName { get; set; } = string.Empty;

    public string DisplayName => $"{ProjectCode} (Tahap {Subfix}) - {FileName}";
}

/// <summary>
/// DTO pratinjau surat pemberitahuan KPM dengan parameter yang telah terikat.
/// </summary>
public class SuratPemberitahuanDto
{
    public PenerimaBansos Penerima { get; set; } = null!;
    public SuratParameterDto Parameter { get; set; } = null!;
    public string NomorSurat { get; set; } = string.Empty;
    public DateTime TanggalSurat { get; set; } = DateTime.Now;
    public string JadwalPenyaluran { get; set; } = string.Empty;
    public string LokasiPenyaluran { get; set; } = string.Empty;
    public Petugas? Petugas { get; set; }
    public string FormattedPreview { get; set; } = string.Empty;
}
