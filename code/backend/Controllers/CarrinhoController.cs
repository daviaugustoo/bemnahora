using BemNaHoraAPI.Models;
using BemNaHoraAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace BemNaHoraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CarrinhoController : ControllerBase
    {
        private readonly CarrinhoService _service;
        private readonly ProdutoService _produtoService;

        public CarrinhoController(CarrinhoService service, ProdutoService produtoService)
        {
            _service = service;
            _produtoService = produtoService;
        }

        // ===== CRUD básico =====
        [HttpGet]
        public ActionResult<List<Carrinho>> GetAll() => _service.GetAll();

        [HttpGet("{id}")]
        public ActionResult<Carrinho> GetById(string id)
        {
            var carrinho = _service.GetById(id);
            return carrinho is null ? NotFound() : Ok(carrinho);
        }

        [HttpPost]
        public ActionResult Create([FromBody] Carrinho carrinho)
        {
            _service.Create(carrinho);
            return CreatedAtAction(nameof(GetById), new { id = carrinho.Id }, carrinho);
        }

        [HttpPut("{id}")]
        public ActionResult Update(string id, [FromBody] Carrinho carrinho)
        {
            var result = _service.Update(id, carrinho);
            return result ? NoContent() : NotFound();
        }

        [HttpDelete("{id}")]
        public ActionResult Delete(string id)
        {
            var result = _service.Delete(id);
            return result ? NoContent() : NotFound();
        }

        // ===== Manipulação de itens =====
        [HttpPost("{id}/itens")]
        public ActionResult AdicionarItem(string id, [FromBody] ItemCarrinho item)
        {
            try
            {
                if (item.Produto != null)
                {
                    _service.AdicionarItem(id, item.Produto, item.Quantidade);
                    return Ok();
                }

                if (!string.IsNullOrEmpty(item.ProdutoId))
                {
                    var produto = _produtoService.GetById(item.ProdutoId) ?? throw new Exception("Produto não encontrado.");
                    _service.AdicionarItem(id, produto, item.Quantidade);
                    return Ok();
                }

                return BadRequest("Informe o produto (objeto) ou produtoId no corpo da requisição.");
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }

        [HttpDelete("{id}/itens/{produtoId}")]
        public ActionResult RemoverItem(string id, string produtoId)
        {
            try
            {
                _service.RemoverItem(id, produtoId);
                return NoContent();
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }

        [HttpGet("{id}/total")]
        public ActionResult<double> CalcularTotal(string id)
        {
            try
            {
                var total = _service.CalcularTotal(id);
                return Ok(total);
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }

        [HttpPost("{id}/finalizar")]
        public ActionResult<Pedido> FinalizarCompra(string id)
        {
            try
            {
                var pedido = _service.FinalizarCompra(id);
                return Ok(pedido);
            }
            catch (Exception ex) { return BadRequest(ex.Message); }
        }
    }
}
