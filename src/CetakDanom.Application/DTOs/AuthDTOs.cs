using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.DTOs;

public class LoginRequest
{
    public string UserId { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string AppVersion { get; set; } = "5.0.0-PROTOTYPE";
}

public class LoginResult
{
    public bool IsSuccess { get; set; }
    public string Message { get; set; } = string.Empty;
    public Petugas? Petugas { get; set; }
    public string StatusCode { get; set; } = "999";

    public static LoginResult Success(Petugas petugas) =>
        new() { IsSuccess = true, Message = "Login berhasil.", Petugas = petugas, StatusCode = "000" };

    public static LoginResult Failed(string message, string statusCode = "001") =>
        new() { IsSuccess = false, Message = message, StatusCode = statusCode };
}
