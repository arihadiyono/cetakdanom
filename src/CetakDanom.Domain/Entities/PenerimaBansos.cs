namespace CetakDanom.Domain.Entities;

public enum StatusCetak
{
    BelumCetak,
    SudahCetak
}

/// <summary>
/// Representasi data penerima bantuan sosial (KPM) dalam alur kerja Danom FDPOS.
/// </summary>
public class PenerimaBansos
{
    public string IdPelanggan { get; set; } = string.Empty;
    public string Tahap { get; set; } = "1";
    public string Nik { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public string Alamat { get; set; } = string.Empty;
    public string AlamatKtp { get; set; } = string.Empty;
    public string Provinsi { get; set; } = string.Empty;
    public string Kabupaten { get; set; } = string.Empty;
    public string Kecamatan { get; set; } = string.Empty;
    public string Kelurahan { get; set; } = string.Empty;
    public decimal Nominal { get; set; } = 600000m;
    public string Danom { get; set; } = string.Empty;
    public string Batch { get; set; } = "BATCH-01";
    public string Percentile { get; set; } = "1";
    public string Regional { get; set; } = "REGIONAL IV";
    public string Nopend { get; set; } = "40000";
    public string NamaKantor { get; set; } = "KCU BANDUNG 40000";

    public StatusCetak StatusDanom { get; set; } = StatusCetak.BelumCetak;
    public StatusCetak StatusBuktiTerima { get; set; } = StatusCetak.BelumCetak;
    public DateTime? WaktuCetakDanom { get; set; }
    public DateTime? WaktuCetakBukti { get; set; }

    public string NominalFormatted => Nominal.ToString("N0", new System.Globalization.CultureInfo("id-ID"));

    public string StatusDanomDisplay => StatusDanom == StatusCetak.SudahCetak ? "SUDAH CETAK" : "SIAP CETAK";
    public string StatusBuktiDisplay => StatusBuktiTerima == StatusCetak.SudahCetak ? "SUDAH BAYAR" : "BELUM BAYAR";
}
