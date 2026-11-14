using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

public interface IDanomRepository
{
    Task<IReadOnlyList<PenerimaBansos>> GetPenerimaListAsync(DanomFilterRequest filter);
    Task<DanomSummaryDto> GetSummaryAsync(DanomFilterRequest filter);
    Task<bool> UpdateStatusCetakDanomAsync(IEnumerable<string> idPelangganList);
    Task<bool> UpdateStatusCetakBuktiAsync(IEnumerable<string> idPelangganList);
}
