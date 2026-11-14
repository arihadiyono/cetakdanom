using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.DTOs;

public class BnbaExportRequest
{
    public IReadOnlyList<PenerimaBansos> Records { get; set; } = Array.Empty<PenerimaBansos>();
    public string TargetDirectory { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
}

public class BnbaExportResult
{
    public bool IsSuccess { get; set; }
    public string Message { get; set; } = string.Empty;
    public string FullFilePath { get; set; } = string.Empty;
    public int ExportedRecordCount { get; set; }
    public long FileSizeBytes { get; set; }

    public static BnbaExportResult Success(string filePath, int count, long bytes) =>
        new()
        {
            IsSuccess = true,
            Message = $"Ekspor BNBA berhasil dibuat: {count} baris data.",
            FullFilePath = filePath,
            ExportedRecordCount = count,
            FileSizeBytes = bytes
        };

    public static BnbaExportResult Failed(string message) =>
        new()
        {
            IsSuccess = false,
            Message = message
        };
}
