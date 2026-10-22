using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using TecNM.Api.Core.Entities;
using TecNM.Api.Data;

namespace TecNM.Api.Modules.Auth;

public sealed record JwtSettings(
    string Issuer,
    string Audience,
    int LifetimeHours,
    SymmetricSecurityKey SigningKey);

public sealed class AuthService(
    TecNMDbContext dbContext,
    PasswordHasher<User> passwordHasher,
    JwtSettings jwtSettings)
{
    public async Task<AuthSession?> AuthenticateAsync(
        string username,
        string password,
        CancellationToken cancellationToken)
    {
        var normalizedUsername = username.Trim();
        var user = await dbContext.Users.SingleOrDefaultAsync(
            item => item.Username == normalizedUsername,
            cancellationToken);

        if (user is null || !user.IsActive)
        {
            return null;
        }

        var verification = passwordHasher.VerifyHashedPassword(user, user.Password, password);
        if (verification == PasswordVerificationResult.Failed)
        {
            return null;
        }

        var expiresAt = DateTimeOffset.UtcNow.AddHours(jwtSettings.LifetimeHours);
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim("username", user.Username),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(JwtRegisteredClaimNames.Name, user.Name),
            new Claim("role", user.Role)
        };
        var token = new JwtSecurityToken(
            issuer: jwtSettings.Issuer,
            audience: jwtSettings.Audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expiresAt.UtcDateTime,
            signingCredentials: new SigningCredentials(
                jwtSettings.SigningKey,
                SecurityAlgorithms.HmacSha256));

        return new AuthSession(
            ToResponse(user),
            new JwtSecurityTokenHandler().WriteToken(token),
            expiresAt);
    }

    public UserResponse? GetCurrentUser(ClaimsPrincipal principal)
    {
        var idValue = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
        var username = principal.FindFirst("username")?.Value;
        var email = principal.FindFirst(JwtRegisteredClaimNames.Email)?.Value;
        var name = principal.FindFirst(JwtRegisteredClaimNames.Name)?.Value;
        var role = principal.FindFirst("role")?.Value;

        if (!Guid.TryParse(idValue, out var id)
            || string.IsNullOrWhiteSpace(username)
            || string.IsNullOrWhiteSpace(email)
            || string.IsNullOrWhiteSpace(name)
            || role is not ("Admin" or "User"))
        {
            return null;
        }

        return new UserResponse(id, username, email, name, role);
    }

    private static UserResponse ToResponse(User user) =>
        new(user.Id, user.Username, user.Email, user.Name, user.Role);
}
