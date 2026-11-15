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

    public async Task<IReadOnlyList<LayananBansos>> GetProjectsAsync(string jenisBansos)
    {
        try
        {
            var apiList = await _client.GetProjectsAsync(jenisBansos);
            return apiList.Select(p => new LayananBansos
            {
                Kode = p.IdProject,
                Nama = $"{p.IdProject} - {p.Deskripsi}",
                Deskripsi = p.Deskripsi,
                DefaultNominal = 600000m
            }).ToList();
        }
        catch
        {
            return new List<LayananBansos>();
        }
    }

    public async Task<IReadOnlyList<TahapBansosItem>> GetTahapAsync(string jenisBansos, string projectId)
    {
        try
        {
            var apiList = await _client.GetTahapAsync(jenisBansos, projectId);
            return apiList.Select(t => new TahapBansosItem
            {
                IdTahap = t.IdTahap,
                KetTahap = t.KetTahap
            }).ToList();
        }
        catch
        {
            return new List<TahapBansosItem>();
        }
    }

    public async Task<IReadOnlyList<Wilayah>> GetAllKabupatenAsync()
    {
        try
        {
            var kabs = await _client.GetAllKabupatenAsync();
            return kabs.Select(k => new Wilayah
            {
                Kode = k.Kode,
                Nama = $"{k.Kode} - {k.Nama}",
                Tingkat = TingkatWilayah.Kabupaten
            }).ToList();
        }
        catch
        {
            return new List<Wilayah>();
        }
    }

    public async Task<IReadOnlyList<Wilayah>> GetKecamatanByKabupatenAsync(string kabupatenKode)
    {
        try
        {
            var kecs = await _client.GetKecamatanByKabupatenAsync(kabupatenKode);
            return kecs.Select(k => new Wilayah
            {
                Kode = k.Kode,
                Nama = $"{k.Kode} - {k.Nama}",
                Tingkat = TingkatWilayah.Kecamatan,
                ParentKode = kabupatenKode
            }).ToList();
        }
        catch
        {
            return new List<Wilayah>();
        }
    }

    public async Task<IReadOnlyList<Wilayah>> GetDesaByKecamatanAsync(string kecamatanKode, string kabupatenKode = "")
    {
        try
        {
            var desas = await _client.GetDesaByKecamatanAsync(kecamatanKode, kabupatenKode);
            return desas.Select(d => new Wilayah
            {
                Kode = d.Kode,
                Nama = $"{d.Kode} - {d.Nama}",
                Tingkat = TingkatWilayah.Kelurahan,
                ParentKode = kecamatanKode
            }).ToList();
        }
        catch
        {
            return new List<Wilayah>();
        }
    }

    // ----------------------------------------------------------------------
    // Backward-compatible methods
    // ----------------------------------------------------------------------
    public async Task<IReadOnlyList<LayananBansos>> GetDaftarLayananAsync()
    {
        return await GetProjectsAsync("NASIONAL");
    }

    public Task<IReadOnlyList<Wilayah>> GetProvinsiAsync()
    {
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
        var kabs = await GetAllKabupatenAsync();
        if (string.IsNullOrEmpty(provinsiKode)) return kabs;
        var filtered = kabs.Where(k => k.Kode.StartsWith(provinsiKode)).ToList();
        return filtered.Count > 0 ? filtered : kabs;
    }

    public Task<IReadOnlyList<Wilayah>> GetKecamatanAsync(string kabupatenKode)
    {
        return GetKecamatanByKabupatenAsync(kabupatenKode);
    }

    public Task<IReadOnlyList<Wilayah>> GetKelurahanAsync(string kecamatanKode)
    {
        return GetDesaByKecamatanAsync(kecamatanKode, "");
    }
}
