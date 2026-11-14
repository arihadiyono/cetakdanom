using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;
using CetakDanom.Infrastructure.Mock;
using Xunit;

namespace CetakDanom.UnitTests;

public class DanomRepositoryTests
{
    [Fact]
    public async Task DanomRepository_ShouldFilterByKelurahanDago()
    {
        // Arrange
        var repo = new MockDanomRepository();

        // Act
        var records = await repo.GetPenerimaListAsync(new DanomFilterRequest
        {
            KelurahanKode = "3273011001" // DAGO
        });

        // Assert
        Assert.NotEmpty(records);
        Assert.All(records, r => Assert.Equal("DAGO", r.Kelurahan));
    }

    [Fact]
    public async Task DanomRepository_SearchByNameOrNik_ShouldReturnMatchingRecords()
    {
        // Arrange
        var repo = new MockDanomRepository();

        // Act: Search for "BUDI"
        var records = await repo.GetPenerimaListAsync(new DanomFilterRequest
        {
            SearchTerm = "BUDI"
        });

        // Assert
        Assert.NotEmpty(records);
        Assert.All(records, r => Assert.Contains("BUDI", r.Nama, StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public async Task DanomRepository_GetSummary_ShouldCalculateAccurateTotals()
    {
        // Arrange
        var repo = new MockDanomRepository();

        // Act
        var summary = await repo.GetSummaryAsync(new DanomFilterRequest());

        // Assert
        Assert.True(summary.TotalRecords > 0);
        Assert.True(summary.TotalNominal > 0);
        Assert.Equal(summary.TotalRecords, summary.SiapCetakCount + summary.SudahCetakCount);
    }

    [Fact]
    public async Task DanomRepository_UpdateStatusCetakDanom_ShouldMarkRecordsAsSudahCetak()
    {
        // Arrange
        var repo = new MockDanomRepository();
        var allRecords = await repo.GetPenerimaListAsync(new DanomFilterRequest());
        var targetRecord = allRecords.First(r => r.StatusDanom == StatusCetak.BelumCetak);

        // Act
        bool updated = await repo.UpdateStatusCetakDanomAsync(new[] { targetRecord.IdPelanggan });
        var refreshed = await repo.GetPenerimaListAsync(new DanomFilterRequest { SearchTerm = targetRecord.Nik });

        // Assert
        Assert.True(updated);
        var found = refreshed.FirstOrDefault(r => r.IdPelanggan == targetRecord.IdPelanggan);
        Assert.NotNull(found);
        Assert.Equal(StatusCetak.SudahCetak, found.StatusDanom);
        Assert.NotNull(found.WaktuCetakDanom);
    }
}
