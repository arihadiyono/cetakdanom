using System.Text;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;
using CetakDanom.Domain.Rules;

namespace CetakDanom.Infrastructure.Api;

public class ApiCdsBltService : ICdsBltService
{
    private readonly CetakDanomApiClient _client;
    private readonly IQrCodeService _qrCodeService;

    public ApiCdsBltService(CetakDanomApiClient client, IQrCodeService qrCodeService)
    {
        _client = client;
        _qrCodeService = qrCodeService;
    }

    public async Task<CdsBltRecipientDto?> InquiryNikAsync(string nik, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(nik) || nik.Trim().Length < 16)
        {
            return null;
        }

        var result = await _client.InquiryNikAsync(nik.Trim(), cancellationToken);
        return result;
    }

    public Task<PrintPreviewDocument> PrepareKuitansiCdsPrintPreviewAsync(CdsBltRecipientDto recipient, Petugas? petugas)
    {
        var nopend = petugas?.Nopend ?? "40000";
        var kantor = petugas?.Kantor ?? "KCU BANDUNG";
        var namaPetugas = petugas?.Nama ?? "OPERATOR LOKET";

        var nominalFormatted = recipient.Nominal.ToString("N0", new System.Globalization.CultureInfo("id-ID"));

        var alamatLengkap = $"{recipient.AlamatDtks}, KEL. {recipient.NmDesaDtks}, KEC. {recipient.NmKecDtks}, {recipient.NmKabDtks}";

        // QR Code 6 segmen berpemisah pipa
        var qrPayload = _qrCodeService.GeneratePayload(
            recipient.IdPelanggan,
            "1",
            recipient.Nik,
            recipient.Nama,
            recipient.AlamatDtks,
            alamatLengkap,
            recipient.Nominal
        );

        var (isValid, message, segments) = _qrCodeService.ValidatePayload(qrPayload);
        var qrPngBytes = _qrCodeService.GenerateQrCodePng(qrPayload, 8);

        var sb = new StringBuilder();
        sb.AppendLine("================================================================================");
        sb.AppendLine("              PT POS INDONESIA (PERSERO) - BUKTI PEMBAYARAN BANSOS              ");
        sb.AppendLine("                       KUITANSI TANDA TERIMA OPERASIONAL LOKET                  ");
        sb.AppendLine("================================================================================");
        sb.AppendLine($"No. Voucher    : {recipient.NoVoucher}");
        sb.AppendLine($"Tanggal Trans  : {DateTime.Now:dd/MM/yyyy HH:mm:ss}");
        sb.AppendLine($"Kantor Bayar   : {kantor} (NOPEND: {nopend})");
        sb.AppendLine($"Kasir/Petugas  : {namaPetugas}");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"ID Pelanggan   : {recipient.IdPelanggan}");
        sb.AppendLine($"NIK            : {recipient.Nik}");
        sb.AppendLine($"Nama KPM       : {recipient.Nama}");
        sb.AppendLine($"Alamat DTKS    : {recipient.AlamatDtks}");
        sb.AppendLine($"Wilayah        : {recipient.NmDesaDtks} - {recipient.NmKecDtks} - {recipient.NmKabDtks}");
        sb.AppendLine($"Provinsi       : {recipient.NmPropDtks}");
        sb.AppendLine($"Pemberi Bantuan: {recipient.NamaPerusahaan}");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"JUMLAH DITERIMA: Rp {nominalFormatted},-");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine("BARCODE 2D SCANNER VERIFICATION (FORMAT PIPA 6-SEGMEN):");
        sb.AppendLine($"[ {qrPayload} ]");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine("Tanda Tangan Penerima,                     Petugas Pembayar,");
        sb.AppendLine("");
        sb.AppendLine("");
        sb.AppendLine($"( {recipient.Nama} )                       ( {namaPetugas} )");
        sb.AppendLine("================================================================================");

        var doc = new PrintPreviewDocument
        {
            Title = "Kuitansi Tanda Terima Penerima Bansos (CDS)",
            Subtitle = $"{recipient.Nama} - NIK: {recipient.Nik}",
            HeaderInfo = $"KANTOR: {kantor} | VOUCHER: {recipient.NoVoucher} | TGL: {DateTime.Now:dd/MM/yyyy}",
            DocType = DocumentType.KuitansiCds,
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = qrPayload,
            QrPayloadValid = isValid,
            QrValidationMessage = message,
            QrCodeImagePngBytes = qrPngBytes
        };

        return Task.FromResult(doc);
    }
}
