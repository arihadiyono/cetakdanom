using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

public interface IAuthenticationService
{
    Task<LoginResult> LoginAsync(LoginRequest request);
    Petugas? CurrentPetugas { get; }
    bool IsAuthenticated { get; }
    void Logout();
}
