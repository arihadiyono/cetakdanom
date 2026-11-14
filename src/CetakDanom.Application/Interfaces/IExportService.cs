using CetakDanom.Application.DTOs;

namespace CetakDanom.Application.Interfaces;

public interface IExportService
{
    Task<BnbaExportResult> ExportBnbaCsvAsync(BnbaExportRequest request);
}
