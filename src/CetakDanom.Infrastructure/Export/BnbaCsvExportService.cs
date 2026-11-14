using System.Text;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Models;

namespace CetakDanom.Infrastructure.Export;

/// <summary>
/// Layanan ekspor berkas CSV By Name By Address (BNBA).
/// Mengimplementasikan aturan format warisan Delphi (14 kolom, pemisah titik koma, dan prefix backtick untuk NIK & Danom).
/// </summary>
public class BnbaCsvExportService : IExportService
{
    public async Task<BnbaExportResult> ExportBnbaCsvAsync(BnbaExportRequest request)
    {
        if (request.Records == null || request.Records.Count == 0)
        {
            return BnbaExportResult.Failed("Tidak ada baris data penerima bansos untuk diekspor ke BNBA.");
        }

        if (string.IsNullOrWhiteSpace(request.TargetDirectory))
        {
            return BnbaExportResult.Failed("Direktori tujuan penyimpanan berkas BNBA belum ditentukan.");
        }

        try
        {
            if (!Directory.Exists(request.TargetDirectory))
            {
                Directory.CreateDirectory(request.TargetDirectory);
            }

            string baseFileName = string.IsNullOrWhiteSpace(request.FileName)
                ? $"BNBA_EXPORT_{DateTime.Now:yyyyMMdd_HHmmss}.csv"
                : (request.FileName.EndsWith(".csv", StringComparison.OrdinalIgnoreCase) ? request.FileName : $"{request.FileName}.csv");

            string fullPath = Path.Combine(request.TargetDirectory, baseFileName);

            var sb = new StringBuilder();
            sb.AppendLine(BnbaRecord.HeaderLine);

            int exportedCount = 0;
            foreach (var r in request.Records)
            {
                var row = new BnbaRecord
                {
                    Bst = r.IdPelanggan,
                    Regional = r.Regional,
                    Kantor = $"{r.Nopend}-{r.NamaKantor}",
                    Provinsi = r.Provinsi,
                    Kabupaten = r.Kabupaten,
                    Kecamatan = r.Kecamatan,
                    DesaKelurahan = r.Kelurahan,
                    Batch = r.Batch,
                    Nama = r.Nama,
                    Nominal = r.Nominal.ToString("0"),
                    Nik = r.Nik,
                    Alamat = r.Alamat,
                    Danom = r.Danom,
                    Percentile = r.Percentile
                };

                sb.AppendLine(row.ToCsvRow());
                exportedCount++;
            }

            // Simpan dengan encoding UTF-8 (atau Windows-1252 ANSI jika diperlukan integrasi sistem lawas)
            await File.WriteAllTextAsync(fullPath, sb.ToString(), Encoding.UTF8);

            var fileInfo = new FileInfo(fullPath);

            // Validasi jumlah record
            if (exportedCount != request.Records.Count)
            {
                return BnbaExportResult.Failed($"Verifikasi gagal: Jumlah baris data diekspor ({exportedCount}) berbeda dengan data input ({request.Records.Count}).");
            }

            return BnbaExportResult.Success(fullPath, exportedCount, fileInfo.Length);
        }
        catch (Exception ex)
        {
            return BnbaExportResult.Failed($"Gagal mengekspor file BNBA: {ex.Message}");
        }
    }
}
