using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PedidoController : ControllerBase
    {
        private readonly PedidoService _service;
        private readonly PagamentoService _pagamentoService;

        public PedidoController(PedidoService service, PagamentoService pagamentoService)
        {
            _service = service;
            _pagamentoService = pagamentoService;
        }

        // ===== CRUD básico =====
        [HttpGet]
        public ActionResult<List<Pedido>> GetAll() => _service.GetAll();

        [HttpGet("{id}")]
        public ActionResult<Pedido> GetById(string id)
        {
            var pedido = _service.GetById(id);
            return pedido is null ? NotFound() : Ok(pedido);
        }
    
        [HttpPost]
        public ActionResult Create([FromBody] Pedido pedido)
        {
            _service.Create(pedido);
            return CreatedAtAction(nameof(GetById), new { id = pedido.Id }, pedido);
        }

        [HttpPut("{id}")]
        public ActionResult Update(string id, [FromBody] Pedido pedido)
        {
            var result = _service.Update(id, pedido);
            return result ? NoContent() : NotFound();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(string id)
        {
            var result = _service.Delete(id);
            return result ? NoContent() : NotFound();
        }

        // ===== Métodos de negócio =====
        [HttpPut("{id}/status")]
        public ActionResult AlterarStatus(string id, [FromBody] StatusPedido novoStatus)
        {
            try
            {
                _service.AlterarStatus(id, novoStatus);
                return NoContent();
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }

        [HttpPost("{id}/pagamento")]
        public async Task<ActionResult> ProcessarPagamento(string id)
        {
            try
            {
                var preference = await _pagamentoService.CriarPreferenciaPorPedidoAsync(id, "https://localhost:7118");

                if (preference == null)
                    return BadRequest("Falha ao criar preferência de pagamento.");

                return Ok(preference);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

    }
}
