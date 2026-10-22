using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace TecNM.Api.Modules.Auth;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(AuthService authService) : ControllerBase
{
    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult<UserResponse>> Login(
        [FromBody] LoginRequest? request,
        CancellationToken cancellationToken)
    {
        if (request is null
            || string.IsNullOrWhiteSpace(request.Username)
            || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest();
        }

        var session = await authService.AuthenticateAsync(
            request.Username,
            request.Password,
            cancellationToken);
        if (session is null)
        {
            return Unauthorized(new { message = "Usuario o contraseña incorrectos." });
        }

        Response.Cookies.Append(
            "auth_token",
            session.Token,
            CreateCookieOptions(session.ExpiresAt, httpOnly: true));
        Response.Cookies.Append(
            "session_exp",
            session.ExpiresAt.ToUnixTimeSeconds().ToString(CultureInfo.InvariantCulture),
            CreateCookieOptions(session.ExpiresAt, httpOnly: false));

        return Ok(session.User);
    }

    [Authorize]
    [HttpGet("me")]
    public ActionResult<UserResponse> Me()
    {
        var user = authService.GetCurrentUser(User);
        return user is null ? Unauthorized() : Ok(user);
    }

    [AllowAnonymous]
    [HttpPost("logout")]
    public IActionResult Logout()
    {
        Response.Cookies.Delete("auth_token", CreateDeleteCookieOptions(httpOnly: true));
        Response.Cookies.Delete("session_exp", CreateDeleteCookieOptions(httpOnly: false));
        return NoContent();
    }

    private static CookieOptions CreateCookieOptions(DateTimeOffset expiresAt, bool httpOnly) => new()
    {
        HttpOnly = httpOnly,
        Secure = true,
        SameSite = SameSiteMode.Lax,
        Path = "/",
        Expires = expiresAt,
        IsEssential = true
    };

    private static CookieOptions CreateDeleteCookieOptions(bool httpOnly) => new()
    {
        HttpOnly = httpOnly,
        Secure = true,
        SameSite = SameSiteMode.Lax,
        Path = "/",
        IsEssential = true
    };
}
