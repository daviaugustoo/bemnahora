using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EntregasController : ControllerBase
    {
        private readonly EntregaService _service;

        public EntregasController(EntregaService service)
        {
            _service = service;
        }

        // ===== CRUD básico =====

        [HttpGet]
        public ActionResult<List<Entrega>> GetAll() => _service.GetAll();

        [HttpGet("{id}")]
        public ActionResult<Entrega> GetById(string id)
        {
            var entrega = _service.GetById(id);
            return entrega is null ? NotFound() : Ok(entrega);
        }

        [HttpPost]
        public ActionResult Create([FromBody] Entrega entrega)
        {
            _service.Create(entrega);
            return CreatedAtAction(nameof(GetById), new { id = entrega.Id }, entrega);
        }

        [HttpPut("{id}")]
        public ActionResult Update(string id, [FromBody] Entrega entrega)
        {
            var result = _service.Update(id, entrega);
            return result ? NoContent() : NotFound();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(string id)
        {
            var result = _service.Delete(id);
            return result ? NoContent() : NotFound();
        }

        // ===== Filtros / regras de negócio =====

        [HttpPut("{id}/status")]
        public ActionResult AlterarStatus(string id, [FromBody] StatusEntrega novoStatus)
        {
            try
            {
                _service.AlterarStatus(id, novoStatus);
                return NoContent();
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }

        [HttpGet("por-entregador/{entregadorId}")]
        public ActionResult<List<Entrega>> GetByEntregador(string entregadorId) =>
            _service.GetByEntregador(entregadorId);

        [HttpGet("por-distribuidora/{distribuidoraId}")]
        public ActionResult<List<Entrega>> GetByDistribuidora(string distribuidoraId) =>
            _service.GetByDistribuidora(distribuidoraId);

        [HttpGet("por-consumidor/{consumidorId}")]
        public ActionResult<List<Entrega>> GetByConsumidor(string consumidorId) =>
            _service.GetByConsumidor(consumidorId);

        [HttpGet("por-status/{status}")]
        public ActionResult<List<Entrega>> GetByStatus(StatusEntrega status) =>
            _service.GetByStatus(status);

        [HttpGet("por-periodo")]
        public ActionResult<List<Entrega>> GetByPeriodo([FromQuery] DateTime inicio, [FromQuery] DateTime fim) =>
            _service.GetByPeriodo(inicio, fim);
    }
}
