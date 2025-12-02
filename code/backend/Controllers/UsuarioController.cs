using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class UsuarioController : ControllerBase
{
    private readonly UsuarioService _service;

    public UsuarioController(UsuarioService service)
    {
        _service = service;
    }

    [HttpPost("entregador")]
    public IActionResult CriarEntregador([FromBody] Entregador entregador)
    {
        _service.CreateEntregador(entregador);
        return Ok("Entregador criado com sucesso");
    }

    [HttpPost("distribuidora")]
    public IActionResult CriarDistribuidora([FromBody] Distribuidora distribuidora)
    {
        _service.CreateDistribuidora(distribuidora);
        return Ok("Distribuidora criada com sucesso");
    }

    [HttpPost("consumidor")]
    public IActionResult CriarConsumidor([FromBody] Consumidor consumidor)
    {
        _service.CreateConsumidor(consumidor);
        return Ok("Consumidor criado com sucesso");
    }

    [HttpGet("{id}")]
    public IActionResult GetById(string id)
    {
        var usuario = _service.GetById(id);
        if (usuario == null)
            return NotFound();

        return Ok(usuario);
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        var usuarios = _service.GetAll();
        return Ok(usuarios);
    }

    [HttpDelete("{id}")]
    public IActionResult Delete(string id)
    {
        var sucesso = _service.Delete(id);
        if (!sucesso)
            return NotFound("Usuário não encontrado.");

        return NoContent();
    }

}
