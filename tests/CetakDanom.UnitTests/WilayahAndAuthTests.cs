using CetakDanom.Application.DTOs;
using CetakDanom.Infrastructure.Mock;
using Xunit;

namespace CetakDanom.UnitTests;

public class WilayahAndAuthTests
{
    [Fact]
    public async Task WilayahRepository_ShouldReturnValidCascadingHierarchy()
    {
        // Arrange
        var repo = new MockWilayahRepository();

        // Act
        var provs = await repo.GetProvinsiAsync();
        Assert.NotEmpty(provs);
        var jabar = provs.FirstOrDefault(p => p.Kode == "32");
        Assert.NotNull(jabar);

        var kabs = await repo.GetKabupatenAsync(jabar.Kode);
        Assert.NotEmpty(kabs);
        var kotaBandung = kabs.FirstOrDefault(k => k.Kode == "3273");
        Assert.NotNull(kotaBandung);

        var kecs = await repo.GetKecamatanAsync(kotaBandung.Kode);
        Assert.NotEmpty(kecs);
        var coblong = kecs.FirstOrDefault(k => k.Kode == "327301");
        Assert.NotNull(coblong);

        var kels = await repo.GetKelurahanAsync(coblong.Kode);
        Assert.NotEmpty(kels);
        Assert.Contains(kels, k => k.Nama == "DAGO");
    }

    [Fact]
    public async Task AuthenticationService_DemoAccount_ShouldLoginSuccessfully()
    {
        // Arrange
        var authService = new MockAuthenticationService();

        // Act
        var result = await authService.LoginAsync(new LoginRequest
        {
            UserId = "demo",
            Password = "demo123"
        });

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal("000", result.StatusCode);
        Assert.NotNull(result.Petugas);
        Assert.Equal("40000", result.Petugas.Nopend);
        Assert.Equal("KCU BANDUNG", result.Petugas.Kantor);
        Assert.True(authService.IsAuthenticated);

        // Act: Logout
        authService.Logout();
        Assert.False(authService.IsAuthenticated);
        Assert.Null(authService.CurrentPetugas);
    }

    [Fact]
    public async Task AuthenticationService_WrongPassword_ShouldFail()
    {
        // Arrange
        var authService = new MockAuthenticationService();

        // Act
        var result = await authService.LoginAsync(new LoginRequest
        {
            UserId = "demo",
            Password = "wrongpassword"
        });

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("002", result.StatusCode);
        Assert.False(authService.IsAuthenticated);
    }
}
