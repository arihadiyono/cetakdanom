using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;
using CetakDanom.Infrastructure.Mock;
using CetakDanom.Infrastructure.Printing;
using Xunit;

namespace CetakDanom.UnitTests;

public class SuratAndCdsTests
{
    private readonly QrCodeService _qrService = new();

    [Fact]
    public async Task SuratService_GetAvailableParameters_ReturnsExpectedList()
    {
        var service = new MockSuratService(_qrService);
        var list = await service.GetAvailableParametersAsync();

        Assert.NotEmpty(list);
        Assert.Contains(list, p => p.ProjectCode == "BST" && p.FileName.Contains("param_bst_1.pos"));
        Assert.Contains(list, p => p.ProjectCode == "PKH");
        Assert.Contains(list, p => p.ProjectCode == "BLT");
        Assert.Contains(list, p => p.ProjectCode == "SEM");
    }

    [Fact]
    public async Task SuratService_PrepareSuratPrintPreview_ContainsParameterClausesAndKpmInfo()
    {
        var service = new MockSuratService(_qrService);
        var param = await service.LoadParameterAsync("BST", "1");

        var kpm = new PenerimaBansos
        {
            IdPelanggan = "12345",
            Nik = "3201012304850001",
            Nama = "AHMAD SURYANA",
            Alamat = "JL. MERDEKA NO. 14",
            Kelurahan = "CIBINONG",
            Kecamatan = "CIBINONG",
            Kabupaten = "BOGOR",
            Nominal = 600000m,
            Danom = "000001"
        };

        var petugas = new Petugas
        {
            Nama = "BUDI PETUGAS",
            Nippos = "987654321",
            Kantor = "KCU BOGOR",
            Nopend = "16000"
        };

        var doc = await service.PrepareSuratPrintPreviewAsync(kpm, param, petugas);

        Assert.NotNull(doc);
        Assert.Equal(DocumentType.SuratPemberitahuan, doc.DocType);
        Assert.Contains("AHMAD SURYANA", doc.FormattedContent);
        Assert.Contains("3201012304850001", doc.FormattedContent);
        Assert.Contains(param.JudulSurat, doc.FormattedContent);
        Assert.Contains("param_bst_1.pos", doc.FormattedContent);
        Assert.True(doc.QrPayloadValid);
    }

    [Fact]
    public async Task CdsBltService_InquiryNik_PreRegistered_ReturnsCorrectData()
    {
        var service = new MockCdsBltService(_qrService);
        var result = await service.InquiryNikAsync("3201012304850001");

        Assert.NotNull(result);
        Assert.Equal("000", result.IdResponse);
        Assert.Equal("AHMAD SURYANA", result.Nama);
        Assert.Equal("3201012304850001", result.Nik);
        Assert.Equal(600000m, result.Nominal);
        Assert.Equal("CIBINONG", result.NmDesaDtks);
    }

    [Fact]
    public async Task CdsBltService_InquiryNik_ValidSixteenDigitDynamic_ReturnsSuccess()
    {
        var service = new MockCdsBltService(_qrService);
        var result = await service.InquiryNikAsync("3273012345678901");

        Assert.NotNull(result);
        Assert.Equal("000", result.IdResponse);
        Assert.Equal("3273012345678901", result.Nik);
        Assert.True(result.Nominal > 0);
    }

    [Fact]
    public async Task CdsBltService_InquiryNik_InvalidOrEmpty_ReturnsNull()
    {
        var service = new MockCdsBltService(_qrService);
        var rEmpty = await service.InquiryNikAsync("");
        var rInvalid = await service.InquiryNikAsync("123");

        Assert.Null(rEmpty);
        Assert.Null(rInvalid);
    }

    [Fact]
    public async Task CdsBltService_PrepareKuitansiCds_ValidatesSixSegmentQrPayload()
    {
        var service = new MockCdsBltService(_qrService);
        var kpm = await service.InquiryNikAsync("3201012304850001");
        Assert.NotNull(kpm);

        var petugas = new Petugas { Nama = "PETUGAS LOKET", Nopend = "40000" };
        var doc = await service.PrepareKuitansiCdsPrintPreviewAsync(kpm, petugas);

        Assert.NotNull(doc);
        Assert.Equal(DocumentType.KuitansiCds, doc.DocType);
        Assert.True(doc.QrPayloadValid);
        Assert.NotNull(doc.QrCodeImagePngBytes);
        Assert.Contains(kpm.Nama, doc.FormattedContent);
        Assert.Contains(kpm.Nik, doc.FormattedContent);
    }
}
