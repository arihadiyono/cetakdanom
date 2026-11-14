using CetakDanom.Domain.Rules;
using Xunit;

namespace CetakDanom.UnitTests;

public class QrPayloadTests
{
    [Fact]
    public void BuildPayload_ShouldGenerateStrictSixPipeSegments()
    {
        // Arrange
        string idPelanggan = "BST3273011001000001"; // 19 chars
        string tahap = "1";
        string nik = "3273011001900001";
        string nama = "BUDI SANTOSO";
        string alamatKtp = "JL. DAGO NO. 10";
        string alamat = "JL. DAGO NO. 10";
        decimal nominal = 600000m;

        // Act
        string payload = QrPayloadRules.BuildPayload(idPelanggan, tahap, nik, nama, alamatKtp, alamat, nominal);

        // Assert
        Assert.NotNull(payload);
        string[] segments = payload.Split('|');
        Assert.Equal(6, segments.Length);

        // Segmen 1: ID_PELANGGAN_19DIGIT + TAHAP
        Assert.Equal("BST32730110010000011", segments[0]);
        // Segmen 2: NIK (16 digit)
        Assert.Equal("3273011001900001", segments[1]);
        // Segmen 3: NAMA
        Assert.Equal("BUDI SANTOSO", segments[2]);
        // Segmen 4: ALAMAT_KTP
        Assert.Equal("JL. DAGO NO. 10", segments[3]);
        // Segmen 5: ALAMAT
        Assert.Equal("JL. DAGO NO. 10", segments[4]);
        // Segmen 6: BSU / NOMINAL
        Assert.Equal("600,000", segments[5]);
    }

    [Fact]
    public void BuildPayload_ShouldSanitizeStrayPipesInAddressAndName_PreservingSixSegments()
    {
        // Arrange: Input text contains accidental stray pipes
        string idPelanggan = "BST3273011001000002";
        string tahap = "1";
        string nik = "3273011001900002";
        string namaWithPipe = "SITI | AMINAH";
        string alamatWithPipes = "JL. MERDEKA | NO. 45 | RT 02";
        decimal nominal = 300000m;

        // Act
        string payload = QrPayloadRules.BuildPayload(idPelanggan, tahap, nik, namaWithPipe, alamatWithPipes, alamatWithPipes, nominal);

        // Assert: Scanner parsing must NOT split into 8 or 9 segments! It must strictly remain 6 segments!
        string[] segments = payload.Split('|');
        Assert.Equal(6, segments.Length);

        // Verify the stray pipe was replaced with space in the fields
        Assert.Equal("SITI   AMINAH", segments[2]);
        Assert.Equal("JL. MERDEKA   NO. 45   RT 02", segments[3]);
    }

    [Fact]
    public void ValidatePayload_WithValidPayload_ReturnsTrue()
    {
        // Arrange
        string payload = "BST32730110010000011|3273011001900001|BUDI SANTOSO|JL. DAGO NO. 10|JL. DAGO NO. 10|600,000";

        // Act
        var (isValid, message, segments) = QrPayloadRules.ValidatePayload(payload);

        // Assert
        Assert.True(isValid);
        Assert.Equal(6, segments.Length);
    }

    [Fact]
    public void ValidatePayload_WithFewerSegments_ReturnsFalse()
    {
        // Arrange: Only 4 segments
        string invalidPayload = "BST32730110010000011|3273011001900001|BUDI SANTOSO|600,000";

        // Act
        var (isValid, message, segments) = QrPayloadRules.ValidatePayload(invalidPayload);

        // Assert
        Assert.False(isValid);
        Assert.Contains("Pelanggaran kontrak payload QR Code", message);
    }

    [Fact]
    public void ValidatePayload_WithInvalidNik_ReturnsFalse()
    {
        // Arrange: NIK is not 16 digits
        string invalidPayload = "BST32730110010000011|327301ABC|BUDI SANTOSO|JL. DAGO|JL. DAGO|600,000";

        // Act
        var (isValid, message, segments) = QrPayloadRules.ValidatePayload(invalidPayload);

        // Assert
        Assert.False(isValid);
        Assert.Contains("Segmen 2 (NIK) tidak valid", message);
    }
}
