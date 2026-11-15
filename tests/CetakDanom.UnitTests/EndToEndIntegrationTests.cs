using CetakDanom.Application.DTOs;
using CetakDanom.Infrastructure.Api;
using Xunit;

namespace CetakDanom.UnitTests;

public class EndToEndIntegrationTests
{
    private readonly CetakDanomApiClient _client = new();

    [Fact]
    public async Task Test1_GoApi_HealthCheck_IsConnectedToSqlServer()
    {
        var isHealthy = await _client.CheckHealthAsync();
        Assert.True(isHealthy, "Go REST API should be running at http://localhost:8080 and connected to SQL Server (DB_BLT).");
    }

    [Fact]
    public async Task Test2_GoApi_Reference_ReturnsRealLayananAndKabupaten()
    {
        var layanan = await _client.GetLayananAsync();
        Assert.NotEmpty(layanan);
        Assert.Contains(layanan, l => !string.IsNullOrEmpty(l.Kode));

        var kab = await _client.GetKabupatenAsync();
        Assert.NotEmpty(kab);
        Assert.Contains(kab, k => k.Nama.Contains("BANDUNG") || k.Kode == "3273");
    }

    [Fact]
    public async Task Test3_GoApi_GetDanomList_ReturnsActualSQLServerData()
    {
        // Kelurahan Cijerah, Batch M1-A04, Project SPK1
        var result = await _client.GetDanomListAsync("3273151001", "M1-A04", "SPK1");

        Assert.NotNull(result);
        Assert.Equal(67, result.TotalKpm); // Exact verified count in T_PENERIMA_SPK_MB1
        Assert.Equal(40200000m, result.TotalNominal);
        Assert.NotEmpty(result.Records);

        var first = result.Records.First();
        Assert.Equal("3273151001", first.IdKelurahan);
        Assert.Equal("CIJERAH", first.Kelurahan);
        Assert.Equal(16, first.Nik.Length);
        Assert.Equal(600000m, first.Nominal);
        Assert.NotEmpty(first.Nama);
        Assert.NotEmpty(first.Barcode1);
    }

    [Fact]
    public async Task Test4_GoApi_InquiryNik_ReturnsActualRecipientForCds()
    {
        // Inquiry NIK: 1116054107500066 (SARIANA - MEKAR WANGI, BANDUNG)
        var recipient = await _client.InquiryNikAsync("1116054107500066");

        Assert.NotNull(recipient);
        Assert.Equal("000", recipient.IdResponse);
        Assert.Equal("1116054107500066", recipient.Nik);
        Assert.Equal("SARIANA", recipient.Nama);
        Assert.Equal(600000m, recipient.Nominal);
        Assert.Equal("MEKAR WANGI", recipient.NmDesaDtks);
        Assert.Equal("KOTA BANDUNG", recipient.NmKabDtks);
    }

    [Fact]
    public async Task Test5_WpfApiDanomRepository_FetchesAndCachesActualData()
    {
        var repo = new ApiDanomRepository(_client);
        var filter = new DanomFilterRequest
        {
            KelurahanKode = "3273151001",
            Tahap = "M1-A04",
            LayananKode = "SPK1"
        };

        var records = await repo.GetPenerimaListAsync(filter);
        Assert.Equal(67, records.Count);

        var summary = await repo.GetSummaryAsync(filter);
        Assert.Equal(67, summary.TotalRecords);
        Assert.Equal(40200000m, summary.TotalNominal);
        Assert.Equal(67, summary.SiapCetakCount);
        Assert.Equal(0, summary.SudahCetakCount);

        // Test marking as printed in current session
        var firstId = records.First().IdPelanggan;
        await repo.UpdateStatusCetakDanomAsync(new[] { firstId });

        var updatedSummary = await repo.GetSummaryAsync(filter);
        Assert.Equal(1, updatedSummary.SudahCetakCount);
        Assert.Equal(66, updatedSummary.SiapCetakCount);
    }
}
