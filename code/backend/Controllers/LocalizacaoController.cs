// Controllers/LocalizacaoController.cs
using Microsoft.AspNetCore.Mvc;
using BemNaHoraAPI.Services;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LocalizacaoController : ControllerBase
    {
        private readonly OpenStreetMapService _osmService;

        public LocalizacaoController(OpenStreetMapService osmService)
        {
            _osmService = osmService;
        }

        // === Geocodificar endereço ===
        [HttpGet("geocodificar")]
        public async Task<IActionResult> Geocodificar([FromQuery] string endereco)
        {
            try
            {
                var resultado = await _osmService.GeocodificarEnderecoAsync(endereco);

                if (resultado == null)
                    return NotFound(new { error = "Endereço não encontrado" });

                return Ok(resultado);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Geocodificação reversa ===
        [HttpGet("endereco")]
        public async Task<IActionResult> ObterEndereco([FromQuery] double latitude, [FromQuery] double longitude)
        {
            try
            {
                var endereco = await _osmService.GeocodificarReversoAsync(latitude, longitude);
                return Ok(new { endereco });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Calcular rota ===
        [HttpGet("rota")]
        public async Task<IActionResult> CalcularRota(
            [FromQuery] double latOrigem,
            [FromQuery] double lonOrigem,
            [FromQuery] double latDestino,
            [FromQuery] double lonDestino)
        {
            try
            {
                var rota = await _osmService.CalcularRotaAsync(latOrigem, lonOrigem, latDestino, lonDestino);

                if (rota == null)
                    return NotFound(new { error = "Rota não encontrada" });

                return Ok(rota);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Calcular distância direta ===
        [HttpGet("distancia")]
        public IActionResult CalcularDistancia(
            [FromQuery] double lat1,
            [FromQuery] double lon1,
            [FromQuery] double lat2,
            [FromQuery] double lon2)
        {
            try
            {
                var distancia = _osmService.CalcularDistanciaDireta(lat1, lon1, lat2, lon2);
                return Ok(new { distanciaKm = Math.Round(distancia, 2) });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Salvar localização do usuário ===
        [HttpPost("salvar")]
        public IActionResult SalvarLocalizacao([FromBody] SalvarLocalizacaoRequest request)
        {
            try
            {
                _osmService.SalvarLocalizacao(
                    request.UsuarioId,
                    request.Endereco,
                    request.Latitude,
                    request.Longitude
                );

                return Ok(new { message = "Localização salva com sucesso" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Buscar localizações do usuário ===
        [HttpGet("usuario/{usuarioId}")]
        public IActionResult ObterLocalizacoesUsuario(string usuarioId)
        {
            try
            {
                var localizacoes = _osmService.ObterLocalizacoesUsuario(usuarioId);
                return Ok(localizacoes);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // === Buscar localizações próximas ===
        [HttpGet("proximas")]
        public IActionResult BuscarProximas(
            [FromQuery] double latitude,
            [FromQuery] double longitude,
            [FromQuery] double raioKm = 5)
        {
            try
            {
                var localizacoes = _osmService.BuscarLocalizacoesProximas(latitude, longitude, raioKm);
                return Ok(localizacoes);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }

    public class SalvarLocalizacaoRequest
    {
        public string UsuarioId { get; set; } = string.Empty;
        public string Endereco { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }
}
