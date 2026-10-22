namespace TecNM.Api.Modules.Auth;

public sealed record LoginRequest(
    string? Username,
    string? Password);

public sealed record UserResponse(
    Guid Id,
    string Username,
    string Email,
    string Name,
    string Role);

public sealed record AuthSession(
    UserResponse User,
    string Token,
    DateTimeOffset ExpiresAt);
