using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Mock;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Menyimpan dataset sintetis penerima bansos (KPM) in-memory untuk memvalidasi alur Danom, BNBA, dan cetak.
/// Tidak ada koneksi ke database SQL Server produksi.
/// </summary>
public class MockDanomRepository : IDanomRepository
{
    private readonly List<PenerimaBansos> _dataset = new();

    public MockDanomRepository()
    {
        InitializeSyntheticData();
    }

    private void InitializeSyntheticData()
    {
        var sampleNames = new[]
        {
            "BUDI SANTOSO", "SITI AMINAH", "AGUS SETIAWAN", "DEWI LESTARI",
            "JOKO WIDODO", "RATNA SARI", "HENDRA WIJAYA", "NURUL HIDAYAH",
            "BAMBANG PAMUNGKAS", "ENDANG SUPRIATNA", "YAYAT RUHIYAT", "CECEP GORLOM",
            "ASEP SUNANDAR", "DEDEH ROSIDAH", "UJANG KURNIA", "ENENG NURHAYATI",
            "IWAN FALSAFAH", "RINA NOSE", "TATANG SUTARNA", "MAMAN ABDURRAHMAN",
            "DADANG KURNIA", "NINA HERLINA", "DODI SUPRIADI", "LIA YULIANI",
            "WAWAN SETIAWAN", "ELI SUHAELI", "ACENG FIKRI", "IMAS MASITOH",
            "TOTO SUPRAPTO", "IDA FARIDA", "DENI KAGUR", "ENI NURAINI"
        };

        var sampleStreets = new[]
        {
            "JL. IR. H. DJUANDA NO.", "JL. DAGO BARAT RT 03/05 NO.", "JL. CISITU LAMA NO.", "JL. DIPATIUKUR NO.",
            "JL. SARIJADI BLOK 8 NO.", "JL. GEGERKALONG HILIR NO.", "JL. SETIABUDHI NO.", "JL. SUKASARI II NO."
        };

        int idCounter = 1;

        // Buat data untuk Kelurahan DAGO (3273011001)
        for (int i = 0; i < 25; i++)
        {
            string name = sampleNames[i % sampleNames.Length];
            string street = sampleStreets[i % sampleStreets.Length] + (10 + i);
            string nik = $"327301{1001900000 + i:D10}";
            string idPelanggan = $"BST3273011001{idCounter:D6}";

            _dataset.Add(new PenerimaBansos
            {
                IdPelanggan = idPelanggan,
                Tahap = "1",
                Nik = nik,
                Nama = name,
                Alamat = street,
                AlamatKtp = street,
                Provinsi = "JAWA BARAT",
                Kabupaten = "KOTA BANDUNG",
                Kecamatan = "COBLONG",
                Kelurahan = "DAGO",
                Nominal = 600000m,
                Danom = $"{idCounter:D4}",
                Batch = "BATCH-01",
                Percentile = ((i % 4) + 1).ToString(),
                Regional = "REGIONAL IV",
                Nopend = "40000",
                NamaKantor = "KCU BANDUNG 40000",
                StatusDanom = (i < 5) ? StatusCetak.SudahCetak : StatusCetak.BelumCetak,
                StatusBuktiTerima = (i < 2) ? StatusCetak.SudahCetak : StatusCetak.BelumCetak,
                WaktuCetakDanom = (i < 5) ? DateTime.Now.AddDays(-1) : null,
                WaktuCetakBukti = (i < 2) ? DateTime.Now.AddHours(-3) : null
            });
            idCounter++;
        }

        // Buat data untuk Kelurahan LEBAKGEDE (3273011002)
        for (int i = 0; i < 15; i++)
        {
            string name = sampleNames[(i + 5) % sampleNames.Length];
            string street = "JL. LEBAKGEDE NO. " + (20 + i);
            string nik = $"327301{1002900000 + i:D10}";
            string idPelanggan = $"BST3273011002{idCounter:D6}";

            _dataset.Add(new PenerimaBansos
            {
                IdPelanggan = idPelanggan,
                Tahap = "1",
                Nik = nik,
                Nama = name,
                Alamat = street,
                AlamatKtp = street,
                Provinsi = "JAWA BARAT",
                Kabupaten = "KOTA BANDUNG",
                Kecamatan = "COBLONG",
                Kelurahan = "LEBAKGEDE",
                Nominal = 600000m,
                Danom = $"{idCounter:D4}",
                Batch = "BATCH-01",
                Percentile = "2",
                Regional = "REGIONAL IV",
                Nopend = "40000",
                NamaKantor = "KCU BANDUNG 40000",
                StatusDanom = StatusCetak.BelumCetak,
                StatusBuktiTerima = StatusCetak.BelumCetak
            });
            idCounter++;
        }

        // Buat data untuk Kelurahan GEGERKALONG (3273021001)
        for (int i = 0; i < 15; i++)
        {
            string name = sampleNames[(i + 10) % sampleNames.Length];
            string street = "JL. GEGERKALONG GIRANG NO. " + (5 + i);
            string nik = $"327302{1001900000 + i:D10}";
            string idPelanggan = $"BST3273021001{idCounter:D6}";

            _dataset.Add(new PenerimaBansos
            {
                IdPelanggan = idPelanggan,
                Tahap = "1",
                Nik = nik,
                Nama = name,
                Alamat = street,
                AlamatKtp = street,
                Provinsi = "JAWA BARAT",
                Kabupaten = "KOTA BANDUNG",
                Kecamatan = "SUKASARI",
                Kelurahan = "GEGERKALONG",
                Nominal = 600000m,
                Danom = $"{idCounter:D4}",
                Batch = "BATCH-02",
                Percentile = "1",
                Regional = "REGIONAL IV",
                Nopend = "40000",
                NamaKantor = "KCU BANDUNG 40000",
                StatusDanom = StatusCetak.BelumCetak,
                StatusBuktiTerima = StatusCetak.BelumCetak
            });
            idCounter++;
        }
    }

    public Task<IReadOnlyList<PenerimaBansos>> GetPenerimaListAsync(DanomFilterRequest filter)
    {
        IEnumerable<PenerimaBansos> query = _dataset;

        if (!string.IsNullOrWhiteSpace(filter.KelurahanKode))
        {
            // Ambil nama kelurahan atau kode
            if (filter.KelurahanKode == "3273011001") query = query.Where(k => k.Kelurahan == "DAGO");
            else if (filter.KelurahanKode == "3273011002") query = query.Where(k => k.Kelurahan == "LEBAKGEDE");
            else if (filter.KelurahanKode == "3273021001") query = query.Where(k => k.Kelurahan == "GEGERKALONG");
        }
        else if (!string.IsNullOrWhiteSpace(filter.KecamatanKode))
        {
            if (filter.KecamatanKode == "327301") query = query.Where(k => k.Kecamatan == "COBLONG");
            else if (filter.KecamatanKode == "327302") query = query.Where(k => k.Kecamatan == "SUKASARI");
        }

        if (!string.IsNullOrWhiteSpace(filter.Tahap))
        {
            query = query.Where(k => k.Tahap == filter.Tahap);
        }

        if (filter.StatusFilter.HasValue)
        {
            query = query.Where(k => k.StatusDanom == filter.StatusFilter.Value);
        }

        if (!string.IsNullOrWhiteSpace(filter.SearchTerm))
        {
            string term = filter.SearchTerm.Trim().ToLowerInvariant();
            query = query.Where(k =>
                k.Nama.ToLowerInvariant().Contains(term) ||
                k.Nik.Contains(term) ||
                k.IdPelanggan.ToLowerInvariant().Contains(term) ||
                k.Alamat.ToLowerInvariant().Contains(term));
        }

        return Task.FromResult<IReadOnlyList<PenerimaBansos>>(query.OrderBy(k => k.Danom).ToList());
    }

    public Task<DanomSummaryDto> GetSummaryAsync(DanomFilterRequest filter)
    {
        var recordsTask = GetPenerimaListAsync(filter);
        var records = recordsTask.Result;

        var summary = new DanomSummaryDto
        {
            TotalRecords = records.Count,
            TotalNominal = records.Sum(r => r.Nominal),
            SiapCetakCount = records.Count(r => r.StatusDanom == StatusCetak.BelumCetak),
            SudahCetakCount = records.Count(r => r.StatusDanom == StatusCetak.SudahCetak)
        };

        return Task.FromResult(summary);
    }

    public Task<bool> UpdateStatusCetakDanomAsync(IEnumerable<string> idPelangganList)
    {
        var set = new HashSet<string>(idPelangganList);
        foreach (var item in _dataset.Where(k => set.Contains(k.IdPelanggan)))
        {
            item.StatusDanom = StatusCetak.SudahCetak;
            item.WaktuCetakDanom = DateTime.Now;
        }
        return Task.FromResult(true);
    }

    public Task<bool> UpdateStatusCetakBuktiAsync(IEnumerable<string> idPelangganList)
    {
        var set = new HashSet<string>(idPelangganList);
        foreach (var item in _dataset.Where(k => set.Contains(k.IdPelanggan)))
        {
            item.StatusBuktiTerima = StatusCetak.SudahCetak;
            item.WaktuCetakBukti = DateTime.Now;
        }
        return Task.FromResult(true);
    }
}
