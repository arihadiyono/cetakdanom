using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Api;

public class ApiWilayahRepository : IWilayahRepository
{
    private readonly CetakDanomApiClient _client;

    public ApiWilayahRepository(CetakDanomApiClient client)
    {
        _client = client;
    }

    public async Task<IReadOnlyList<LayananBansos>> GetDaftarLayananAsync()
    {
        try
        {
            var apiList = await _client.GetLayananAsync();
            if (apiList.Count > 0)
            {
                return apiList.Select(l => new LayananBansos
                {
                    Kode = l.Kode,
                    Nama = l.Nama,
                    Deskripsi = string.IsNullOrWhiteSpace(l.HeaderDanom) ? l.Nama : l.HeaderDanom,
                    DefaultNominal = 600000m,
                    DaftarTahap = new List<string> { "M1-A04", "M1-A05", "M1-A06", "M1-A09", "M1-A10" }
                }).ToList();
            }
        }
        catch
        {
            // Fallback gracefully
        }

        // Default if offline
        return new List<LayananBansos>
        {
            new() { Kode = "SPK1", Nama = "SEMBAKO & PKH 2023", Deskripsi = "Bantuan Sembako dan PKH Kemensos", DefaultNominal = 600000m },
            new() { Kode = "BMA", Nama = "BLT BBM, SEMBAKO & PKH", Deskripsi = "Bantuan Langsung Tunai BBM & Sembako", DefaultNominal = 600000m },
            new() { Kode = "PBP1", Nama = "PBP CADANGAN BERAS", Deskripsi = "Pangan Bantuan Pangan Beras", DefaultNominal = 300000m }
        };
    }

    public Task<IReadOnlyList<Wilayah>> GetProvinsiAsync()
    {
        // Standard Indonesian provinces supported by CetakDanom
        var provs = new List<Wilayah>
        {
            new() { Kode = "32", Nama = "JAWA BARAT", Tingkat = TingkatWilayah.Provinsi },
            new() { Kode = "31", Nama = "DKI JAKARTA", Tingkat = TingkatWilayah.Provinsi },
            new() { Kode = "33", Nama = "JAWA TENGAH", Tingkat = TingkatWilayah.Provinsi },
            new() { Kode = "35", Nama = "JAWA TIMUR", Tingkat = TingkatWilayah.Provinsi }
        };
        return Task.FromResult<IReadOnlyList<Wilayah>>(provs);
    }

    public async Task<IReadOnlyList<Wilayah>> GetKabupatenAsync(string provinsiKode)
    {
        var kabs = await _client.GetKabupatenAsync();
        var filtered = kabs.Where(k => string.IsNullOrEmpty(provinsiKode) || k.Kode.StartsWith(provinsiKode))
                           .Select(k => new Wilayah
                           {
                               Kode = k.Kode,
                               Nama = k.Nama,
                               Tingkat = TingkatWilayah.Kabupaten,
                               ParentKode = provinsiKode
                           }).ToList();

        if (filtered.Count == 0 && kabs.Count > 0)
        {
            return kabs.Take(10).Select(k => new Wilayah
            {
                Kode = k.Kode,
                Nama = k.Nama,
                Tingkat = TingkatWilayah.Kabupaten,
                ParentKode = provinsiKode
            }).ToList();
        }

        return filtered;
    }

    public async Task<IReadOnlyList<Wilayah>> GetKecamatanAsync(string kabupatenKode)
    {
        var kecs = await _client.GetKecamatanAsync(kabupatenKode);
        return kecs.Select(k => new Wilayah
        {
            Kode = k.Kode,
            Nama = k.Nama,
            Tingkat = TingkatWilayah.Kecamatan,
            ParentKode = kabupatenKode
        }).ToList();
    }

    public async Task<IReadOnlyList<Wilayah>> GetKelurahanAsync(string kecamatanKode)
    {
        var kels = await _client.GetKelurahanAsync(kecamatanKode);
        return kels.Select(k => new Wilayah
        {
            Kode = k.Kode,
            Nama = k.Nama,
            Tingkat = TingkatWilayah.Kelurahan,
            ParentKode = kecamatanKode
        }).ToList();
    }
}
