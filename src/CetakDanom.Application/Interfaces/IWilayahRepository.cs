using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

public interface IWilayahRepository
{
    Task<IReadOnlyList<LayananBansos>> GetDaftarLayananAsync();
    Task<IReadOnlyList<Wilayah>> GetProvinsiAsync();
    Task<IReadOnlyList<Wilayah>> GetKabupatenAsync(string provinsiKode);
    Task<IReadOnlyList<Wilayah>> GetKecamatanAsync(string kabupatenKode);
    Task<IReadOnlyList<Wilayah>> GetKelurahanAsync(string kecamatanKode);
}
