namespace CetakDanom.Domain.Entities;

public class LayananBansos
{
    public string Kode { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public string Deskripsi { get; set; } = string.Empty;
    public decimal DefaultNominal { get; set; } = 600000m;
    public List<string> DaftarTahap { get; set; } = new() { "1", "2", "3", "4" };

    public override string ToString() => $"{Kode} - {Nama}";
}
