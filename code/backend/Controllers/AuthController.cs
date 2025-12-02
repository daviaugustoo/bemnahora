using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly UsuarioService _usuarioService;
    private readonly IConfiguration _config;

    public AuthController(UsuarioService usuarioService, IConfiguration config)
    {
        _usuarioService = usuarioService;
        _config = config;
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginRequest req)
    {
        var usuario = _usuarioService.GetByUsername(req.Username);
        if (usuario == null || usuario.PasswordHash != req.Password)
            return Unauthorized();

        var claims = new[]
        {
            new Claim(ClaimTypes.Name, usuario.Username),
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds
        );

        return Ok(new { 
            user = usuario,
            token = new JwtSecurityTokenHandler().WriteToken(token) 
            });
    }
}
