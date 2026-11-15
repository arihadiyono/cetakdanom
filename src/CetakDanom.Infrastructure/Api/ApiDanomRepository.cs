using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Api;

public class ApiDanomRepository : IDanomRepository
{
    private readonly CetakDanomApiClient _client;
    private readonly List<PenerimaBansos> _localCache = new();

    public ApiDanomRepository(CetakDanomApiClient client)
    {
        _client = client;
    }

    public async Task<IReadOnlyList<PenerimaBansos>> GetPenerimaListAsync(DanomFilterRequest filter)
    {
        var kelId = filter.KelurahanKode ?? "3273151001";
        var batch = filter.Tahap ?? "M1-A04";
        var projectId = filter.LayananKode ?? "SPK1";
        var sort = "Nama";
        var search = filter.SearchTerm ?? "";

        var result = await _client.GetDanomListAsync(
            kelId,
            batch,
            projectId,
            sort,
            search,
            "NASIONAL",
            0,
            0
        );

        _localCache.Clear();

        var rawRecords = result?.Records ?? new List<ApiDanomRecipientDto>();

        var records = rawRecords.Select(r => new PenerimaBansos
        {
            IdPelanggan = r.IdPelanggan,
            Nik = r.Nik,
            Nama = r.Nama,
            Alamat = r.Alamat,
            AlamatKtp = r.AlamatKtp,
            Nominal = r.Nominal,
            Danom = r.IdPelanggan,
            Batch = r.Batch,
            Tahap = r.Batch,
            Kelurahan = r.Kelurahan,
            Kecamatan = r.Kecamatan,
            Kabupaten = r.Kabupaten,
            Provinsi = r.Provinsi,
            Regional = r.Regional,
            Nopend = r.Kantor,
            NamaKantor = r.Kprk,
            StatusDanom = r.StatusDanom == "SudahCetak" ? StatusCetak.SudahCetak : StatusCetak.BelumCetak
        }).ToList();

        if (filter.StatusFilter.HasValue)
        {
            records = records.Where(r => r.StatusDanom == filter.StatusFilter.Value).ToList();
        }

        _localCache.AddRange(records);
        return records;
    }

    public async Task<DanomSummaryDto> GetSummaryAsync(DanomFilterRequest filter)
    {
        if (_localCache.Count == 0)
        {
            await GetPenerimaListAsync(filter);
        }

        return new DanomSummaryDto
        {
            TotalRecords = _localCache.Count,
            TotalNominal = _localCache.Sum(r => r.Nominal),
            SiapCetakCount = _localCache.Count(r => r.StatusDanom == StatusCetak.BelumCetak),
            SudahCetakCount = _localCache.Count(r => r.StatusDanom == StatusCetak.SudahCetak)
        };
    }

    public Task<bool> UpdateStatusCetakDanomAsync(IEnumerable<string> idPelangganList)
    {
        var idSet = new HashSet<string>(idPelangganList);
        foreach (var rec in _localCache.Where(r => idSet.Contains(r.IdPelanggan)))
        {
            rec.StatusDanom = StatusCetak.SudahCetak;
            rec.WaktuCetakDanom = DateTime.Now;
        }
        return Task.FromResult(true);
    }

    public Task<bool> UpdateStatusCetakBuktiAsync(IEnumerable<string> idPelangganList)
    {
        var idSet = new HashSet<string>(idPelangganList);
        foreach (var rec in _localCache.Where(r => idSet.Contains(r.IdPelanggan)))
        {
            rec.StatusBuktiTerima = StatusCetak.SudahCetak;
            rec.WaktuCetakBukti = DateTime.Now;
        }
        return Task.FromResult(true);
    }
}
