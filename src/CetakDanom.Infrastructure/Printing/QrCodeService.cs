using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Rules;
using QRCoder;

namespace CetakDanom.Infrastructure.Printing;

/// <summary>
/// Layanan pembuatan dan validasi QR Code / Barcode 2D kuitansi.
/// Menghasilkan format string pipa 6 segmen persis sesuai kontrak FastReport eksisting:
/// Copy(ID_PELANGGAN,1,19) + Tahap + '|' + NIK + '|' + NAMA + '|' + ALAMAT_KTP + '|' + ALAMAT + '|' + BSU
/// Menggunakan QRCoder dengan Error Correction Level Medium (ECCLevel.M).
/// </summary>
public class QrCodeService : IQrCodeService
{
    public string GeneratePayload(
        string idPelanggan,
        string tahap,
        string nik,
        string nama,
        string alamatKtp,
        string alamat,
        decimal nominal)
    {
        return QrPayloadRules.BuildPayload(idPelanggan, tahap, nik, nama, alamatKtp, alamat, nominal);
    }

    public (bool IsValid, string Message, string[] Segments) ValidatePayload(string payload)
    {
        return QrPayloadRules.ValidatePayload(payload);
    }

    public byte[] GenerateQrCodePng(string payload, int pixelsPerModule = 10)
    {
        using var qrGenerator = new QRCodeGenerator();
        using var qrCodeData = qrGenerator.CreateQrCode(payload, QRCodeGenerator.ECCLevel.M);
        var qrCode = new PngByteQRCode(qrCodeData);
        return qrCode.GetGraphic(pixelsPerModule);
    }
}
