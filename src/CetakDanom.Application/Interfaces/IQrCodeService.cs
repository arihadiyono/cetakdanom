namespace CetakDanom.Application.Interfaces;

public interface IQrCodeService
{
    string GeneratePayload(string idPelanggan, string tahap, string nik, string nama, string alamatKtp, string alamat, decimal nominal);
    (bool IsValid, string Message, string[] Segments) ValidatePayload(string payload);
    byte[] GenerateQrCodePng(string payload, int pixelsPerModule = 10);
}
