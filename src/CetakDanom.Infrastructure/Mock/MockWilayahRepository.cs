using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Mock;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Menyediakan data hierarki wilayah administratif untuk cascading dropdown (Provinsi -> Kabupaten -> Kecamatan -> Kelurahan).
/// </summary>
public class MockWilayahRepository : IWilayahRepository
{
    private static readonly List<LayananBansos> LayananList = new()
    {
        new LayananBansos { Kode = "BST", Nama = "Bantuan Sosial Tunai (Kemensos)", Deskripsi = "Penyaluran dana tunai Kemensos RI", DefaultNominal = 600000m },
        new LayananBansos { Kode = "PKH", Nama = "Program Keluarga Harapan", Deskripsi = "Bantuan bersyarat keluarga prasejahtera", DefaultNominal = 750000m },
        new LayananBansos { Kode = "SEMBAKO", Nama = "Program Sembako / BPNT", Deskripsi = "Bantuan pangan non-tunai / tunai sembako", DefaultNominal = 400000m },
        new LayananBansos { Kode = "BLT_BBM", Nama = "BLT Pengalihan Subsidi BBM", Deskripsi = "Kompensasi penyesuaian harga BBM", DefaultNominal = 300000m }
    };

    private static readonly List<Wilayah> WilayahList = new()
    {
        // Provinsi
        new Wilayah { Kode = "32", Nama = "JAWA BARAT", Tingkat = TingkatWilayah.Provinsi, ParentKode = null },
        new Wilayah { Kode = "31", Nama = "DKI JAKARTA", Tingkat = TingkatWilayah.Provinsi, ParentKode = null },

        // Kabupaten/Kota - Jawa Barat (32)
        new Wilayah { Kode = "3273", Nama = "KOTA BANDUNG", Tingkat = TingkatWilayah.Kabupaten, ParentKode = "32" },
        new Wilayah { Kode = "3277", Nama = "KOTA CIMAHI", Tingkat = TingkatWilayah.Kabupaten, ParentKode = "32" },
        new Wilayah { Kode = "3204", Nama = "KABUPATEN BANDUNG", Tingkat = TingkatWilayah.Kabupaten, ParentKode = "32" },

        // Kabupaten/Kota - DKI Jakarta (31)
        new Wilayah { Kode = "3171", Nama = "KOTA JAKARTA PUSAT", Tingkat = TingkatWilayah.Kabupaten, ParentKode = "31" },
        new Wilayah { Kode = "3174", Nama = "KOTA JAKARTA SELATAN", Tingkat = TingkatWilayah.Kabupaten, ParentKode = "31" },

        // Kecamatan - Kota Bandung (3273)
        new Wilayah { Kode = "327301", Nama = "COBLONG", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3273" },
        new Wilayah { Kode = "327302", Nama = "SUKASARI", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3273" },
        new Wilayah { Kode = "327303", Nama = "ANDIR", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3273" },
        new Wilayah { Kode = "327304", Nama = "CICENDO", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3273" },

        // Kecamatan - Kota Cimahi (3277)
        new Wilayah { Kode = "327701", Nama = "CIMAHI UTARA", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3277" },
        new Wilayah { Kode = "327702", Nama = "CIMAHI TENGAH", Tingkat = TingkatWilayah.Kecamatan, ParentKode = "3277" },

        // Kelurahan - Coblong (327301)
        new Wilayah { Kode = "3273011001", Nama = "DAGO", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327301" },
        new Wilayah { Kode = "3273011002", Nama = "LEBAKGEDE", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327301" },
        new Wilayah { Kode = "3273011003", Nama = "SADANG SERANG", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327301" },
        new Wilayah { Kode = "3273011004", Nama = "SEKELOA", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327301" },

        // Kelurahan - Sukasari (327302)
        new Wilayah { Kode = "3273021001", Nama = "GEGERKALONG", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327302" },
        new Wilayah { Kode = "3273021002", Nama = "ISOLA", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327302" },
        new Wilayah { Kode = "3273021003", Nama = "SARIJADI", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327302" },

        // Kelurahan - Cimahi Utara (327701)
        new Wilayah { Kode = "3277011001", Nama = "CIBABAT", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327701" },
        new Wilayah { Kode = "3277011002", Nama = "CIPAGERAN", Tingkat = TingkatWilayah.Kelurahan, ParentKode = "327701" }
    };

    public Task<IReadOnlyList<LayananBansos>> GetDaftarLayananAsync() =>
        Task.FromResult<IReadOnlyList<LayananBansos>>(LayananList);

    public Task<IReadOnlyList<Wilayah>> GetProvinsiAsync() =>
        Task.FromResult<IReadOnlyList<Wilayah>>(WilayahList.Where(w => w.Tingkat == TingkatWilayah.Provinsi).ToList());

    public Task<IReadOnlyList<Wilayah>> GetKabupatenAsync(string provinsiKode) =>
        Task.FromResult<IReadOnlyList<Wilayah>>(WilayahList.Where(w => w.Tingkat == TingkatWilayah.Kabupaten && w.ParentKode == provinsiKode).ToList());

    public Task<IReadOnlyList<Wilayah>> GetKecamatanAsync(string kabupatenKode) =>
        Task.FromResult<IReadOnlyList<Wilayah>>(WilayahList.Where(w => w.Tingkat == TingkatWilayah.Kecamatan && w.ParentKode == kabupatenKode).ToList());

    public Task<IReadOnlyList<Wilayah>> GetKelurahanAsync(string kecamatanKode) =>
        Task.FromResult<IReadOnlyList<Wilayah>>(WilayahList.Where(w => w.Tingkat == TingkatWilayah.Kelurahan && w.ParentKode == kecamatanKode).ToList());
}
