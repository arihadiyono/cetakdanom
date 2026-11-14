namespace CetakDanom.Domain.Entities;

/// <summary>
/// Profil Petugas Loket Pos hasil autentikasi.
/// Berdasarkan format string pipa Delphi: IdPetugas|Nippos|Nama|Nopend|Kantor|Jabatan.
/// </summary>
public class Petugas
{
    public string IdPetugas { get; set; } = string.Empty;
    public string Nippos { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public string Nopend { get; set; } = string.Empty;
    public string Kantor { get; set; } = string.Empty;
    public string Jabatan { get; set; } = string.Empty;
    public DateTime LoginTime { get; set; } = DateTime.Now;

    public string RingkasanProfil => $"{Nama} ({Nippos}) - {Jabatan} [{Kantor} / {Nopend}]";
}
