using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

public interface IPrintService
{
    Task<PrintPreviewDocument> PrepareDanomPrintPreviewAsync(IReadOnlyList<PenerimaBansos> records, string infoWilayah, Petugas? petugas);
    Task<PrintPreviewDocument> PrepareBuktiTerimaPrintPreviewAsync(PenerimaBansos record, string tahap, Petugas? petugas);
    Task<PrintPreviewDocument> PrepareSuratPernyataanPrintPreviewAsync(PenerimaBansos record, Petugas? petugas);
}
