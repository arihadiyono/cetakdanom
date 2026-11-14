using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;
using CetakDanom.Domain.Models;
using CetakDanom.Infrastructure.Export;
using Xunit;

namespace CetakDanom.UnitTests;

public class BnbaExportTests
{
    [Fact]
    public void BnbaRecord_Header_HasExact14ColumnsMatchingDelphi()
    {
        // Act
        string header = BnbaRecord.HeaderLine;
        string[] columns = header.Split(';');

        // Assert
        Assert.Equal(14, columns.Length);
        Assert.Equal("BST", columns[0]);
        Assert.Equal("REGIONAL", columns[1]);
        Assert.Equal("KANTOR", columns[2]);
        Assert.Equal("PROVINSI", columns[3]);
        Assert.Equal("KABUPATEN", columns[4]);
        Assert.Equal("KECAMATAN", columns[5]);
        Assert.Equal("DESA/KELURAHAN", columns[6]);
        Assert.Equal("BATCH", columns[7]);
        Assert.Equal("NAMA", columns[8]);
        Assert.Equal("NOMINAL", columns[9]);
        Assert.Equal("NIK", columns[10]);
        Assert.Equal("ALAMAT", columns[11]);
        Assert.Equal("DANOM", columns[12]);
        Assert.Equal("PERCENTILE", columns[13]);
    }

    [Fact]
    public void BnbaRecord_ToCsvRow_MustPrefixNikAndDanomWithBacktick()
    {
        // Arrange
        var record = new BnbaRecord
        {
            Bst = "BST001",
            Regional = "REGIONAL IV",
            Kantor = "40000-KCU BANDUNG",
            Provinsi = "JAWA BARAT",
            Kabupaten = "KOTA BANDUNG",
            Kecamatan = "COBLONG",
            DesaKelurahan = "DAGO",
            Batch = "BATCH-01",
            Nama = "BUDI SANTOSO",
            Nominal = "600000",
            Nik = "3273011001900001", // raw 16-digit numeric string
            Alamat = "JL. DAGO NO. 10",
            Danom = "0001",             // raw danom number
            Percentile = "1"
        };

        // Act
        string csvRow = record.ToCsvRow();
        string[] fields = csvRow.Split(';');

        // Assert
        Assert.StartsWith("`3273011001900001", fields[10]); // NIK column must have backtick!
        Assert.StartsWith("`0001", fields[12]);             // Danom column must have backtick!
    }

    [Fact]
    public async Task BnbaExportService_ShouldCreateCsvFileAndValidateCount()
    {
        // Arrange
        var service = new BnbaCsvExportService();
        string testDir = Path.Combine(Path.GetTempPath(), "CetakDanom_Test_" + Guid.NewGuid().ToString("N"));

        var sampleRecords = new List<PenerimaBansos>
        {
            new() { IdPelanggan = "ID001", Nik = "3273011001900001", Nama = "BUDI", Alamat = "ALAMAT 1", Danom = "0001", Nominal = 600000m },
            new() { IdPelanggan = "ID002", Nik = "3273011001900002", Nama = "SITI", Alamat = "ALAMAT 2", Danom = "0002", Nominal = 600000m }
        };

        var request = new BnbaExportRequest
        {
            Records = sampleRecords,
            TargetDirectory = testDir,
            FileName = "TEST_BNBA.csv"
        };

        try
        {
            // Act
            var result = await service.ExportBnbaCsvAsync(request);

            // Assert
            Assert.True(result.IsSuccess);
            Assert.Equal(2, result.ExportedRecordCount);
            Assert.True(File.Exists(result.FullFilePath));

            string[] lines = await File.ReadAllLinesAsync(result.FullFilePath);
            Assert.Equal(3, lines.Length); // 1 header + 2 data rows
            Assert.Equal(BnbaRecord.HeaderLine, lines[0]);
            Assert.Contains("`3273011001900001", lines[1]);
            Assert.Contains("`0001", lines[1]);
        }
        finally
        {
            if (Directory.Exists(testDir))
            {
                Directory.Delete(testDir, true);
            }
        }
    }
}
