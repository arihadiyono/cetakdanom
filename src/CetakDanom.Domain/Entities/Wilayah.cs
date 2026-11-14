namespace CetakDanom.Domain.Entities;

public enum TingkatWilayah
{
    Provinsi,
    Kabupaten,
    Kecamatan,
    Kelurahan
}

public class Wilayah
{
    public string Kode { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public TingkatWilayah Tingkat { get; set; }
    public string? ParentKode { get; set; }

    public override string ToString() => Nama;
}
