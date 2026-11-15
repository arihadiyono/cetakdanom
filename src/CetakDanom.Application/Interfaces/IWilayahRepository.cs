using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

public class TahapBansosItem
{
    public string IdTahap { get; set; } = string.Empty;
    public string KetTahap { get; set; } = string.Empty;
    public string Display => string.IsNullOrWhiteSpace(KetTahap) ? IdTahap : $"{IdTahap} - {KetTahap}";
    public override string ToString() => Display;
}

public interface IWilayahRepository
{
    // Legacy / Generic methods
    Task<IReadOnlyList<LayananBansos>> GetDaftarLayananAsync();
    Task<IReadOnlyList<Wilayah>> GetProvinsiAsync();
    Task<IReadOnlyList<Wilayah>> GetKabupatenAsync(string provinsiKode);
    Task<IReadOnlyList<Wilayah>> GetKecamatanAsync(string kabupatenKode);
    Task<IReadOnlyList<Wilayah>> GetKelurahanAsync(string kecamatanKode);

    // Dynamic DB_BLT rules
    Task<IReadOnlyList<LayananBansos>> GetProjectsAsync(string jenisBansos);
    Task<IReadOnlyList<TahapBansosItem>> GetTahapAsync(string jenisBansos, string projectId);
    Task<IReadOnlyList<Wilayah>> GetAllKabupatenAsync();
    Task<IReadOnlyList<Wilayah>> GetKecamatanByKabupatenAsync(string kabupatenKode);
    Task<IReadOnlyList<Wilayah>> GetDesaByKecamatanAsync(string kecamatanKode, string kabupatenKode = "");
}
